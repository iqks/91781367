// 原生 zsign 签名桥接：把 C++ 签名库封装成 C 函数供 Swift 调用
#import <Foundation/Foundation.h>
#include "SignBridge.h"

#include "common.h"
#include "bundle.h"
#include "archive.h"
#include "openssl.h"

#include "third-party/minizip/unzip.h"

#include <vector>
#include <string>
#include <cstring>

// 诊断日志：写入 App Documents 沙盒，闪退后重开 App 即可读取
static void zlog_debug(const char* fmt, ...) {
    @autoreleasepool {
        NSString* docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString* path = [docs stringByAppendingPathComponent:@"zsign_debug.log"];
        NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
        if (!fh) {
            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
            fh = [NSFileHandle fileHandleForWritingAtPath:path];
        }
        if (!fh) return;
        va_list args;
        va_start(args, fmt);
        NSString* msg = [[NSString alloc] initWithFormat:[NSString stringWithUTF8String:fmt] arguments:args];
        va_end(args);
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"HH:mm:ss.SSS";
        NSString* line = [NSString stringWithFormat:@"[%@] %@\n", [df stringFromDate:[NSDate date]], msg];
        [fh seekToEndOfFile];
        NSData* data = [line dataUsingEncoding:NSUTF8StringEncoding];
        [fh writeData:data];
        [fh synchronizeFile];
        [fh closeFile];
    }
}

// 读取 IPA 内 Payload/*.app/Info.plist 原始字节
int zsign_ipa_info(const char* ipaPath, char* dataBuf, int* dataLen) {
    @autoreleasepool {
        if (!ipaPath || !dataBuf || !dataLen || *dataLen <= 0) return -1;
        unzFile zf = unzOpen(ipaPath);
        if (!zf) return -2;
        int found = 0;
        if (unzGoToFirstFile(zf) == UNZ_OK) {
            do {
                char name[1024];
                if (unzGetCurrentFileInfo(zf, NULL, name, sizeof(name), NULL, 0, NULL, 0) == UNZ_OK) {
                    std::string p = name;
                    size_t n = p.size();
                    // 匹配 Payload/xxx.app/Info.plist
                    if (n > 12 && p.compare(0, 8, "Payload/") == 0 &&
                        p.compare(n - 12, 12, ".app/Info.plist") == 0) {
                        if (unzOpenCurrentFile(zf) == UNZ_OK) {
                            int total = 0;
                            char buf[65536];
                            int r;
                            int cap = *dataLen;
                            while ((r = unzReadCurrentFile(zf, buf, sizeof(buf))) > 0) {
                                int room = cap - total;
                                if (room <= 0) break;
                                int c = (r < room) ? r : room;
                                memcpy(dataBuf + total, buf, c);
                                total += c;
                                if (total >= cap) break;
                            }
                            unzCloseCurrentFile(zf);
                            *dataLen = total;
                            found = 1;
                            break;
                        }
                    }
                }
            } while (unzGoToNextFile(zf) == UNZ_OK);
        }
        unzClose(zf);
        return found ? 0 : -3;
    }
}

int zsign_sign(const char* inIpa, const char* outIpa, const char* p12Path, const char* pwd, const char* provPath, char* errBuf, int errLen) {
    @autoreleasepool {
        zlog_debug("=== zsign_sign 开始 ===");
        if (!inIpa || !outIpa || !p12Path || !provPath) {
            zlog_debug("参数错误 inIpa=%p outIpa=%p p12=%p prov=%p", inIpa, outIpa, p12Path, provPath);
            if (errBuf && errLen > 0) snprintf(errBuf, errLen, "参数错误");
            return -5;
        }
        zlog_debug("输入 IPA: %s", inIpa);
        zlog_debug("P12: %s", p12Path);
        zlog_debug("Prov: %s", provPath);
        try {
            // 独立工作目录，避免并发冲突
            NSString* tmpBase = [NSTemporaryDirectory() stringByAppendingPathComponent:@"zsign_work"];
            NSFileManager* fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:tmpBase error:nil];
            [fm createDirectoryAtPath:tmpBase withIntermediateDirectories:YES attributes:nil error:nil];
            zlog_debug("工作目录: %@", tmpBase);

            std::string folder = tmpBase.UTF8String;

            // 1. 解压 IPA
            zlog_debug("步骤1 开始解压 IPA...");
            if (!Zip::Extract(inIpa, folder.c_str())) {
                zlog_debug("步骤1 失败: 解压 IPA 失败");
                if (errBuf && errLen > 0) snprintf(errBuf, errLen, "解压 IPA 失败");
                return -1;
            }
            zlog_debug("步骤1 OK 解压完成");

            // 2. 加载证书（P12 + 描述文件）
            zlog_debug("步骤2 开始加载证书...");
            ZSignAsset zsa;
            if (!zsa.Init("", p12Path, provPath, "", (pwd ? pwd : ""), false, false, false)) {
                zlog_debug("步骤2 失败: 证书加载失败");
                if (errBuf && errLen > 0) snprintf(errBuf, errLen, "证书加载失败，请检查密码");
                return -2;
            }
            zlog_debug("步骤2 OK 证书加载成功");

            // 3. 签名 Bundle
            zlog_debug("步骤3 开始签名 Bundle...");
            ZBundle bundle;
            std::vector<std::string> emptyDylibs;
            std::vector<std::string> emptyRemove;
            if (!bundle.SignFolder(&zsa, folder, "", "", "", emptyDylibs, emptyRemove, true, false, false)) {
                zlog_debug("步骤3 失败: 签名失败");
                if (errBuf && errLen > 0) snprintf(errBuf, errLen, "签名失败");
                return -3;
            }
            zlog_debug("步骤3 OK 签名完成");

            // 4. 重新打包为 IPA
            zlog_debug("步骤4 开始打包 IPA...");
            if (!Zip::Archive(folder, outIpa, 9)) {
                zlog_debug("步骤4 失败: 打包失败");
                if (errBuf && errLen > 0) snprintf(errBuf, errLen, "打包失败");
                return -4;
            }
            zlog_debug("步骤4 OK 打包完成: %s", outIpa);
            zlog_debug("=== zsign_sign 成功 ===");
            return 0;
        } catch (const std::exception& e) {
            zlog_debug("C++ 异常: %s", e.what());
            if (errBuf && errLen > 0) snprintf(errBuf, errLen, "签名引擎异常: %s", e.what());
            return -6;
        } catch (...) {
            zlog_debug("未知 C++ 异常");
            if (errBuf && errLen > 0) snprintf(errBuf, errLen, "签名引擎异常");
            return -6;
        }
    }
}
