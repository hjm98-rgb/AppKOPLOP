#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 用设备自带的 AOSKit 在本地生成 anisette 数据（不需要任何第三方服务器）
NSDictionary<NSString *, id> *_Nullable KOPLocalAnisette(void);

/// 用 AOSKit 解码 anisette 服务器下发的 provisioning 数据
NSDictionary<NSString *, id> *_Nullable KOPDecodeProvisioning(NSData *provisioning);

NS_ASSUME_NONNULL_END
