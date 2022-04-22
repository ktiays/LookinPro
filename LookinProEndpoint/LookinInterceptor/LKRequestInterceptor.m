//
//  Created by ktiays on 2022/4/21.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#import "LKRequestInterceptor.h"
#import "LKPRuntimeUtility.h"
#import "ObjectiveJSEngine.h"

#define LK_INVOKE_METHOD_MSG_TYPE 206

@implementation LKRequestInterceptor {
    id _requestHandler;
    ObjectiveJSEngine *_ojsEngine;
}

+ (void)load {
    lkp_interceptMethod(OBJCClass(LKS_RequestHandler), Selector(handleRequestType:tag:object:), ^id (IMP origIMP) {
        return ^(id _self, uint32_t requestType, uint32_t tag, id object) {
            if (requestType == LK_INVOKE_METHOD_MSG_TYPE) {
                __auto_type interceptor = [LKRequestInterceptor sharedInstance];
                JSValue *result = [interceptor->_ojsEngine.context evaluateScript:object[@"text"]];
                [interceptor __sendInvokeMethodResponse:@{
                    @"description": ojs_descriptionOfJSValue(result) ?: @"",
                } tag:tag];
            }
            ((void (*)(id, SEL, uint32_t, uint32_t, id)) origIMP)(_self, nil, requestType, tag, object);
        };
    });
}

+ (instancetype)sharedInstance {
    static LKRequestInterceptor *interceptor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interceptor = [LKRequestInterceptor new];
        [interceptor _setupRequestHandler];
        [interceptor _setupOJSEngine];
    });
    return interceptor;
}

- (void)_setupRequestHandler {
    id connectionManager = [OBJCClass(LKS_ConnectionManager) sharedInstance];
    _requestHandler = [connectionManager valueForKey:@"requestHandler"];
}

- (void)_setupOJSEngine {
    _ojsEngine = [ObjectiveJSEngine new];
}

- (void)__sendInvokeMethodResponse:(NSObject *)data tag:(uint32_t)tag {
    if (!_requestHandler) return;
    
    Method method = class_getInstanceMethod(OBJCClass(LKS_RequestHandler), Selector(_submitResponseWithData:requestType:tag:));
    IMP imp = method_getImplementation(method);
    ((void (*)(id, SEL, NSObject *, uint32_t, uint32_t)) imp)(_requestHandler, nil, data, LK_INVOKE_METHOD_MSG_TYPE, tag);
}

@end

#undef LK_INVOKE_METHOD_MSG_TYPE
