//
//  Created by Yuxin Chen on 2022/4/19.
//  Copyright (c) 2022 Yuxin Chen. All rights reserved.
// 

#import "OJSProxyBuilder.h"
#import "OJSSugar.h"

@implementation OJSProxyBuilder {
    JSContext *_context;
}

- (instancetype)initWithObject:(id)object inContext:(JSContext *)context {
    self = [super init];
    if (self) {
        _object = [OJSProxyObject proxyWithObject:object];
        _context = context;
    }
    return self;
}

- (nullable JSValue *)jsValue {
    if (!_context) return nil;
    JSContext *context = _context;
    if (!_object) return $null;
    
    __auto_type constructor = [context evaluateScript:@"Proxy"];
    NSDictionary *handler = @{
        @"get": ^JSValue * _Nullable (JSValue *target, JSValue *key) {
            NSString *propertyName = [key toString];
            if ([propertyName isKindOfClass:NSString.class] && [propertyName isEqualToString:@"self"]) {
                return $([target toObject]);
            }
            if (self->_get) {
                return self->_get(target, key);
            }
            return nil;
        },
    };
    return [constructor constructWithArguments:@[$(_object), $(handler)]];
}

@end
