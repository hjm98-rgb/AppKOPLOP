#import "AnisetteLocal.h"
#import <objc/message.h>
#import <dlfcn.h>

static void *AOSHandle = NULL;
static BOOL AOSLoaded = NO;

static BOOL KOPLoadAOS(void) {
    if (AOSLoaded) return AOSHandle != NULL;
    AOSLoaded = YES;
    const char *paths[] = {
        "/System/Library/PrivateFrameworks/AOSKit.framework/AOSKit",
        "/System/Library/PrivateFrameworks/AOSKit.framework/AOSKit.framework/AOSKit"
    };
    for (int i = 0; i < 2; i++) {
        AOSHandle = dlopen(paths[i], RTLD_NOW);
        if (AOSHandle) break;
    }
    return AOSHandle != NULL;
}

static id KOPNewProvisioningController(void) {
    if (!KOPLoadAOS()) return nil;
    Class cls = NSClassFromString(@"AKAnisetteProvisioningController");
    if (!cls) return nil;
    id allocated = ((id (*)(id, SEL))objc_msgSend)((id)cls, @selector(alloc));
    id controller = ((id (*)(id, SEL))objc_msgSend)(allocated, @selector(init));
    return controller;
}

static NSDictionary<NSString *, id> *KOPFieldsFromAnisetteObject(id object) {
    if (!object) return nil;
    NSString *machineID = nil;
    NSString *otp = nil;
    NSString *localUserID = nil;
    NSNumber *routingInfo = nil;

    @try {
        machineID = [object valueForKey:@"machineID"];
        otp = [object valueForKey:@"oneTimePassword"];
        localUserID = [object valueForKey:@"localUserID"];
        routingInfo = [object valueForKey:@"routingInfo"];
    } @catch (__unused NSException *exception) {
        return nil;
    }

    if (machineID.length == 0 || otp.length == 0) return nil;

    return @{
        @"machineID": machineID,
        @"oneTimePassword": otp,
        @"localUserID": localUserID ?: @"",
        @"routingInfo": routingInfo ?: @(0)
    };
}

NSDictionary<NSString *, id> *KOPLocalAnisette(void) {
    @try {
        id controller = KOPNewProvisioningController();
        if (!controller) return nil;

        NSError *error = nil;
        SEL selector = NSSelectorFromString(@"anisetteDataWithError:");
        if ([controller respondsToSelector:selector]) {
            id data = ((id (*)(id, SEL, NSError **))objc_msgSend)(controller, selector, &error);
            NSDictionary *fields = KOPFieldsFromAnisetteObject(data);
            if (fields) return fields;
        }

        if ([controller respondsToSelector:NSSelectorFromString(@"anisetteData")]) {
            id data = ((id (*)(id, SEL))objc_msgSend)(controller, NSSelectorFromString(@"anisetteData"));
            return KOPFieldsFromAnisetteObject(data);
        }
        return nil;
    } @catch (__unused NSException *exception) {
        return nil;
    }
}

NSDictionary<NSString *, id> *KOPDecodeProvisioning(NSData *provisioning) {
    if (provisioning.length == 0) return nil;
    @try {
        id controller = KOPNewProvisioningController();
        if (!controller) return nil;

        SEL selector = NSSelectorFromString(@"anisetteDataWithProvisioningData:error:");
        if ([controller respondsToSelector:selector]) {
            NSError *error = nil;
            id data = ((id (*)(id, SEL, NSData *, NSError **))objc_msgSend)(controller, selector, provisioning, &error);
            return KOPFieldsFromAnisetteObject(data);
        }
        return nil;
    } @catch (__unused NSException *exception) {
        return nil;
    }
}
