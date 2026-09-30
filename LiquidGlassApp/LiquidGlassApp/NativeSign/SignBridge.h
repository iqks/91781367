#ifndef SignBridge_h
#define SignBridge_h

#ifdef __cplusplus
extern "C" {
#endif

// 原生 zsign 签名入口（替代网页 wasm 签名，速度快）
// 参数: 输入IPA路径, 输出IPA路径, P12证书路径, 证书密码, 描述文件路径
// 返回值: 0=成功; -1=解压失败; -2=证书加载失败; -3=签名失败; -4=打包失败; -5=参数错误
int zsign_sign(const char* inIpa, const char* outIpa, const char* p12Path, const char* pwd, const char* provPath, char* errBuf, int errLen);

// 读取 IPA 内 Payload/*.app/Info.plist 的原始字节（供 Swift 用 PropertyListSerialization 解析应用名/版本/包名）
// dataLen 输入=缓冲大小，输出=实际数据长度；返回 0=成功，-1=参数错误，-2=打不开IPA，-3=未找到Info.plist
int zsign_ipa_info(const char* ipaPath, char* dataBuf, int* dataLen);

#ifdef __cplusplus
}
#endif

#endif /* SignBridge_h */
