//
//  Created by ktiays on 2022/4/21.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

#define OBJCClass(__CLASS_NAME__) objc_getClass(#__CLASS_NAME__)
#define Selector(__SEL_NAME__) sel_registerName(#__SEL_NAME__)

NS_ASSUME_NONNULL_BEGIN

typedef _Nonnull id(^LKPMethodInterceptor)(IMP origIMP);

extern void lkp_interceptMethod(Class cls, SEL sel, LKPMethodInterceptor interceptor);

extern void lkp_classAddMethod(Class cls, SEL sel, id block, const char *typeEncoding);

NS_ASSUME_NONNULL_END
