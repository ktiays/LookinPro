//
//  Created by ktiays on 2022/4/22.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#import "LKAppInfoInterceptor.h"
#import "LKPRuntimeUtility.h"
#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif

static void *lookin_app_info_device_color_key = &lookin_app_info_device_color_key;

#if __has_include(<UIKit/UIKit.h>)

@interface UIDevice (LKAppInfoInterceptor)

- (id)_deviceInfoForKey:(CFStringRef)key;

- (NSNumber *)deviceColor;

- (NSString *)marketingName;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation UIDevice (LKAppInfoInterceptor)

- (NSNumber *)deviceColor {
    return [self _deviceInfoForKey:(__bridge CFStringRef) @"DeviceColor"];
}

- (NSString *)marketingName {
    return [self _deviceInfoForKey:(__bridge CFStringRef) @"marketing-name"];
}

@end
#pragma clang diagnostic pop

#endif

@implementation LKAppInfoInterceptor

+ (void)load {
    lkp_interceptMethod(OBJCClass(LookinAppInfo), @selector(encodeWithCoder:), ^id _Nonnull(IMP _Nonnull origIMP) {
        return ^void (id _self, NSCoder *aCoder) {
            ((id (*)(id, SEL, NSCoder *)) origIMP)(_self, nil, aCoder);
#if __has_include(<UIKit/UIKit.h>)
            UIDevice *currentDevice = [UIDevice currentDevice];
            [aCoder encodeInteger:[[currentDevice deviceColor] integerValue] forKey:@"deviceColor"];
            [aCoder encodeObject:[currentDevice marketingName] forKey:@"marketingName"];
#endif
        };
    });
}

@end
