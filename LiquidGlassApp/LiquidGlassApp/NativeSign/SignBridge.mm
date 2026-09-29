// 原生 zsign 签名桥接：把 C++ 签名库封装成 C 函数供 Swift 调用
#import <Foundation/Foundation.h>
#include "SignBridge.h"

#include "common.h"
#include "bundle.h"
#include "archive.h"
#include "openssl.h"

#include <vector>
#include <string>

int zsign_sign(const char* inIpa, const char* outIpa, const char* p12Path, const char* pwd, const char* provPath, char* errBuf, int errLen) {
    @autoreleasepool {
        if (!inIpa || !outIpa || !p12Path || !provPath) {
            if (errBuf && errLen > 0) snprintf(errBuf, errLen, "参数错误");
            return -5;
        }
        try {
            // 独立工作目录，避免并发冲突
            NSString* tmpBase = [NSTemporaryDirectory() stringByAppendingPathComponent:@"zsign_work"];
            NSFileManager* fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:tmpBase error:nil];
            [fm createDirectoryAtPath:tmpBase withIntermediateDirectories:YES attributes:nil error:nil];

            std::string folder = tmpBase.UTF8String;

            // 1. 解压 IPA
            if (!Zip::Extract(inIpa, folder.c_str())) {
                if (errBuf && errLen > 0) snprintf(errBuf, errLen, "解压 IPA 失败");
                return -1;
            }

            // 2. 加载证书（P12 + 描述文件）
            ZSignAsset zsa;
            if (!zsa.Init("", p12Path, provPath, "", (pwd ? pwd : ""), false, false, false)) {
                if (errBuf && errLen > 0) snprintf(errBuf, errLen, "证书加载失败，请检查密码");
                return -2;
            }

            // 3. 签名 Bundle
            ZBundle bundle;
            std::vector<std::string> emptyDylibs;
            std::vector<std::string> emptyRemove;
            if (!bundle.SignFolder(&zsa, folder, "", "", "", emptyDylibs, emptyRemove, true, false, false)) {
                if (errBuf && errLen > 0) snprintf(errBuf, errLen, "签名失败");
                return -3;
            }

            // 4. 重新打包为 IPA
            if (!Zip::Archive(folder, outIpa, 9)) {
                if (errBuf && errLen > 0) snprintf(errBuf, errLen, "打包失败");
                return -4;
            }
            return 0;
        } catch (...) {
            if (errBuf && errLen > 0) snprintf(errBuf, errLen, "签名引擎异常");
            return -6;
        }
    }
}
