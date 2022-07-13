//
//  Created by ktiays on 2022/4/21.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

#import <malloc/malloc.h>
#import <mach/mach.h>

#import "LKPRuntimeUtility.h"

inline bool is_tagged_pointer(const void * ptr) {
    const auto tag_mask = (1UL << 63);
    return ((uintptr_t) ptr & tag_mask) == tag_mask;
}

inline bool is_ext_tagged_pointer(const void * ptr) {
    const auto ext_tag_mask = (0xfUL << 60);
    return ((uintptr_t) ptr & ext_tag_mask) == ext_tag_mask;
}

extern "C" {

void lkp_interceptMethod(Class cls, SEL sel, LKPMethodInterceptor interceptor) {
    Method origMeth = class_getInstanceMethod(cls, sel);
    IMP origIMP = method_getImplementation(origMeth);
    
    IMP newIMP = imp_implementationWithBlock(interceptor(origIMP));
    
    if (class_addMethod(cls, sel, newIMP, method_getTypeEncoding(origMeth))) {
        return;
    }
    
    method_setImplementation(origMeth, newIMP);
}

void lkp_classAddMethod(Class cls, SEL sel, id block, const char *typeEncoding) {
    class_addMethod(cls, sel, imp_implementationWithBlock(block), typeEncoding);
}

BOOL __pointer_is_readable(const void * ptr) {
    kern_return_t error = KERN_SUCCESS;
    
    vm_size_t vmsize;
#if __arm64e__
    // On arm64e, we need to strip the PAC from the pointer so the adress is readable.
    vm_address_t address = (vm_address_t) ptrauth_strip(ptr, ptrauth_key_function_pointer);
#else
    vm_address_t address = (vm_address_t) ptr;
#endif
    vm_region_basic_info_data_t info;
    mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
    memory_object_name_t object;
    
    error = vm_region_64(
                         mach_task_self(),
                         &address,
                         &vmsize,
                         VM_REGION_BASIC_INFO,
                         (vm_region_info_t) &info,
                         &info_count,
                         &object
                         );
    
    if (error != KERN_SUCCESS) {
        return NO;
    } else if (!(BOOL) (info.protection & VM_PROT_READ)) {
        return NO;
    }
    
#if __arm64e__
    address = (vm_address_t) ptrauth_strip(ptr, ptrauth_key_function_pointer);
#else
    address = (vm_address_t) ptr;
#endif
    
    // Read the memory
    vm_size_t size = 0;
    char buf[sizeof(uintptr_t)];
    error = vm_read_overwrite(mach_task_self(), address, sizeof(uintptr_t), (vm_address_t) buf, &size);
    
    return (error == KERN_SUCCESS);
}

BOOL __pointer_is_valid_objc_object(const void * ptr) {
    uintptr_t pointer = (uintptr_t) ptr;
    
    if (!ptr) {
        return NO;
    }
    
#if __LP64__
    if (is_tagged_pointer(ptr) || is_ext_tagged_pointer(ptr)) {
        return YES;
    }
#endif
    
    if ((pointer % sizeof(uintptr_t)) != 0) {
        return NO;
    }
    
    if ((pointer & 0xffff800000000000) != 0) {
        return NO;
    }
    
    // Make sure dereferencing this address won't crash.
    if (!__pointer_is_readable(ptr)) {
        return NO;
    }
    
    Class cls = object_getClass((__bridge id)ptr);
    if (!cls || !__pointer_is_readable((__bridge void *) cls)) {
        return NO;
    }

    Class metaclass = object_getClass(cls);
    if (!metaclass || !__pointer_is_readable((__bridge void *) metaclass)) {
        return NO;
    }
    
    if (!object_isClass(cls)) {
        return NO;
    }
    
    ssize_t instanceSize = class_getInstanceSize(cls);
    if (malloc_size(ptr) < instanceSize) {
        return NO;
    }
    
    return YES;
}

}
