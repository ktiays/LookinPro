//
//  Created by ktiays on 2022/4/19.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#import "OJSProxyObject.h"

@interface OJSProxyObject ()

@property (nonatomic, readwrite) id object;

@end

@implementation OJSProxyObject

- (instancetype)initWithObject:(id)object {
    if (!object) return nil;
    
    self = [super init];
    if (self) {
        _object = object;
    }
    return self;
}

+ (instancetype)proxyWithObject:(id)object {
    return [[self alloc] initWithObject:object];
}

@end

@implementation JSValue (OJSProxy)

- (OJSProxyObject *)ojs_proxyObject {
    return (OJSProxyObject *) [[self valueForProperty:@"self"] toObject];
}

@end
