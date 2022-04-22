//
//  Created by Yuxin Chen on 2022/4/19.
//  Copyright (c) 2022 Yuxin Chen. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "OJSProxyObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface OJSProxyBuilder : NSObject

@property (nonatomic, readonly) OJSProxyObject *object;

@property (nonatomic, copy) JSValue * _Nullable (^get)(JSValue *target, JSValue *key);

@property (nonatomic, nullable, readonly) JSValue *jsValue;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithObject:(id)object inContext:(JSContext *)context NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
