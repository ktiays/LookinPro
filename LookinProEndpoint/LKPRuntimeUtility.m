//
//  Created by ktiays on 2022/4/21.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#import "LKPRuntimeUtility.h"

extern void lkp_interceptMethod(Class cls, SEL sel, LKPMethodInterceptor interceptor) {
    Method origMeth = class_getInstanceMethod(cls, sel);
    IMP origIMP = method_getImplementation(origMeth);
    
    IMP newIMP = imp_implementationWithBlock(interceptor(origIMP));
    
    if (class_addMethod(cls, sel, newIMP, method_getTypeEncoding(origMeth))) {
        return;
    }
    
    method_setImplementation(origMeth, newIMP);
}

extern void lkp_classAddMethod(Class cls, SEL sel, id block, const char *typeEncoding) {
    class_addMethod(cls, sel, imp_implementationWithBlock(block), typeEncoding);
}
