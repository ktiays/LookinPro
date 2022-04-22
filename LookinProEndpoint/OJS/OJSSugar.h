//
//  Created by Yuxin Chen on 2022/4/19.
//  Copyright (c) 2022 Yuxin Chen. All rights reserved.
// 

#ifndef OJSSugar_h
#define OJSSugar_h

#define CURRENT_JSCONTEXT [JSContext currentContext]

#define $(__OBJECT__) [JSValue valueWithObject:__OBJECT__ inContext:context]

#define $null [JSValue valueWithNullInContext:context]
#define $undefined [JSValue valueWithUndefinedInContext:context]
#define $error(__MESSAGE__) [JSValue valueWithNewErrorFromMessage:__MESSAGE__ inContext:context]

#define $int32(__INTEGER__) [JSValue valueWithInt32:(int32_t) __INTEGER__ inContext:context]
#define $uint32(__UNSIGNED_INTEGER__) [JSValue valueWithUInt32:(uint32_t) __UNSIGNED_INTEGER__ inContext:context]
#define $double(__DOUBLE__) [JSValue valueWithDouble:(double) __DOUBLE__ inContext:context]
#define $bool(__BOOLEAN__) [JSValue valueWithBool:(BOOL) __BOOLEAN__ inContext:context]

#define $point(__POINT__) [JSValue valueWithPoint:__POINT__ inContext:context]
#define $size(__SIZE__) [JSValue valueWithSize:__SIZE__ inContext:context]
#define $rect(__RECT__) [JSValue valueWithRect:__RECT__ inContext:context]
#define $range(__RANGE__) [JSValue valueWithRange:__RANGE__ inContext:context]

#endif /* OJSSugar_h */
