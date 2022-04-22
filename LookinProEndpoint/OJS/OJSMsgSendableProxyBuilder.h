//
//  Created by Yuxin Chen on 2022/4/19.
//  Copyright (c) 2022 Yuxin Chen. All rights reserved.
// 

#import <Foundation/Foundation.h>

#import "OJSProxyBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface OJSMsgSendableProxyBuilder : NSObject

+ (OJSProxyBuilder *)builderWithObject:(id)object inContext:(nonnull JSContext *)context;

@end

NS_ASSUME_NONNULL_END
