//
//  Created by ktiays on 2022/4/19.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#import <objc/runtime.h>

#import "ObjectiveJSEngine.h"
#import "OJSSugar.h"
#import "OJSProxyBuilder.h"
#import "OJSMsgSendableProxyBuilder.h"
#import "LKPRuntimeUtility.h"

extern NSString * ojs_descriptionOfJSValue(JSValue * value) {
    if ([value isObject]) {
        __auto_type proxy = value.ojs_proxyObject;
        if ([proxy isKindOfClass:OJSProxyObject.class]) {
            return [proxy.object debugDescription];
        }
    } else {
        return [value debugDescription];
    }
    return nil;
}

@interface OJSInteropHelper : NSObject <OJSInteropHelperExports>
@end

@implementation OJSInteropHelper

- (JSValue *)classFromString:(NSString *)className {
    Class aClass = NSClassFromString(className);
    JSContext *context = CURRENT_JSCONTEXT;
    if (!aClass) return $null;
    return [OJSMsgSendableProxyBuilder builderWithObject:aClass inContext:context].jsValue;
}

- (JSValue *)debugDescriptionOfObject:(JSValue *)objectValue {
    JSContext *context = CURRENT_JSCONTEXT;
    return $(ojs_descriptionOfJSValue(objectValue));
}

- (nullable JSValue *)dynamicCastAddressToObject:(NSString *)address {
    NSScanner *scanner = [NSScanner scannerWithString:address];
    unsigned long long addressValue;
    [scanner scanHexLongLong:&addressValue];
    JSContext *context = CURRENT_JSCONTEXT;
    if (!__pointer_is_valid_objc_object((void *) addressValue)) {
        NSString *errorMessage = [NSString stringWithFormat:@"Unable to cast %@ to object.", address];
        context.exception = $error(errorMessage);
        return nil;
    }
    id object = (__bridge id) ((void *) addressValue);
    return [OJSMsgSendableProxyBuilder builderWithObject:object inContext:context].jsValue;
}

- (JSValue *)makeCGPointWithX:(double)x y:(double)y {
    return [JSValue valueWithPoint:CGPointMake(x, y) inContext:CURRENT_JSCONTEXT];
}

- (JSValue *)makeCGSizeWithWidth:(double)width height:(double)height {
    return [JSValue valueWithSize:CGSizeMake(width, height) inContext:CURRENT_JSCONTEXT];
}

- (JSValue *)makeCGRectWithX:(double)x y:(double)y width:(double)width height:(double)height {
    return [JSValue valueWithRect:CGRectMake(x, y, width, height) inContext:CURRENT_JSCONTEXT];
}

- (JSValue *)makeCGRectWithOrigin:(JSValue *)originValue size:(JSValue *)sizeValue {
    CGPoint origin = [originValue toPoint];
    CGSize size = [sizeValue toSize];
    return [JSValue valueWithRect:CGRectMake(origin.x, origin.y, size.width, size.height)
                        inContext:CURRENT_JSCONTEXT];
}

- (JSValue *)makeNSRangeWithLocation:(NSUInteger)location length:(NSUInteger)length {
    return [JSValue valueWithRange:NSMakeRange(location, length) inContext:CURRENT_JSCONTEXT];
}

@end

@implementation ObjectiveJSEngine {
    JSContext *_context;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _context = [[JSContext alloc] init];
        _context.name = @"OJSEngine";
        [self _prepareContext];
    }
    return self;
}

- (JSContext *)context {
    return _context;
}

#pragma mark - Private Methods

- (void)_prepareContext {
    OJSInteropHelper *interopHelper = [[OJSInteropHelper alloc] init];
    [_context.globalObject setObject:interopHelper forKeyedSubscript:@"ObjC"];
}

@end
