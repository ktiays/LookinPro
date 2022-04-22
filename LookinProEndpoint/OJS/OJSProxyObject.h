//
//  Created by ktiays on 2022/4/19.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface OJSProxyObject : NSObject

@property (nonatomic, readonly) id object;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithObject:(id)object NS_DESIGNATED_INITIALIZER;

+ (instancetype)proxyWithObject:(id)object;

@end

@interface JSValue (OJSProxy)

- (OJSProxyObject *)ojs_proxyObject;

@end

NS_ASSUME_NONNULL_END
