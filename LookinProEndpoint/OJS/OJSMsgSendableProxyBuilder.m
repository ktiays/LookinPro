//
//  Created by Yuxin Chen on 2022/4/19.
//  Copyright (c) 2022 Yuxin Chen. All rights reserved.
//

#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>

#import "OJSMsgSendableProxyBuilder.h"
#import "OJSSugar.h"
#import "OJSObjCValueType.h"

@implementation OJSMsgSendableProxyBuilder

+ (OJSProxyBuilder *)builderWithObject:(id)object inContext:(JSContext *)context {
    __auto_type builder = [[OJSProxyBuilder alloc] initWithObject:object inContext:context];
    builder.get = ^JSValue * _Nullable (JSValue *target, JSValue *key) {
        return [self _invokeObjCMethod:[key toString]
                              onObject:((OJSProxyObject *) [target toObject]).object];
    };
    return builder;
}

+ (nullable JSValue *)_invokeObjCMethod:(NSString *)methodName onObject:(id)object {
    Class cls = object_getClass(object);
    SEL sel = sel_registerName(methodName.UTF8String);
    Method meth = class_getInstanceMethod(cls, sel);
    if (!meth) return nil;
    
    JSContext *context = CURRENT_JSCONTEXT;
    
    __auto_type numberOfArgs = method_getNumberOfArguments(meth);
    if (numberOfArgs == 2) {
        // The method takes no arguments, so we can invoke it directly.
        IMP imp = method_getImplementation(meth);

        char *encoding = method_copyReturnType(meth);
        __auto_type returnTypeDescription = ObjCValueTypeDescriptionWithEncodingType(encoding);
        if (encoding != NULL) {
            free(encoding);
        }
#define INVOKE_FUNCTION_WITH_RETURN(__RETURN_TYPE__) ((__RETURN_TYPE__ (*)(id, SEL)) imp)(object, sel)
        switch (returnTypeDescription.type) {
            case OJSObjCValueTypeObject:
            case OJSObjCValueTypeClass: {
                __auto_type builder = [self builderWithObject:INVOKE_FUNCTION_WITH_RETURN(id) inContext:context];
                return builder.jsValue;
            }
            case OJSObjCValueTypeShort:
                return $int32(INVOKE_FUNCTION_WITH_RETURN(short));
            case OJSObjCValueTypeInt:
                return $int32(INVOKE_FUNCTION_WITH_RETURN(int));
            case OJSObjCValueTypeLong:
                return $int32(INVOKE_FUNCTION_WITH_RETURN(long));
            case OJSObjCValueTypeLongLong:
                return $double(INVOKE_FUNCTION_WITH_RETURN(long long));
            case OJSObjCValueTypeFloat:
                return $double(INVOKE_FUNCTION_WITH_RETURN(float));
            case OJSObjCValueTypeDouble:
                return $double(INVOKE_FUNCTION_WITH_RETURN(double));
            case OJSObjCValueTypeUnsignedShort:
                return $uint32(INVOKE_FUNCTION_WITH_RETURN(unsigned short));
            case OJSObjCValueTypeUnsignedInt:
                return $uint32(INVOKE_FUNCTION_WITH_RETURN(unsigned int));
            case OJSObjCValueTypeUnsignedLong:
                return $uint32(INVOKE_FUNCTION_WITH_RETURN(unsigned long));
            case OJSObjCValueTypeUnsignedLongLong:
                return $double(INVOKE_FUNCTION_WITH_RETURN(unsigned long long));
            case OJSObjCValueTypeBoolean:
                return $bool(INVOKE_FUNCTION_WITH_RETURN(BOOL));
            case OJSObjCValueTypeChar: {
                NSString *value = [NSString stringWithFormat:@"%c", INVOKE_FUNCTION_WITH_RETURN(char)];
                return $(value);
            }
            case OJSObjCValueTypeUnsignedChar: {
                NSString *value = [NSString stringWithFormat:@"%hhu", INVOKE_FUNCTION_WITH_RETURN(unsigned char)];
                return $(value);
            }
            case OJSObjCValueTypeStruct: {
                NSString *structName = returnTypeDescription.name;
                if ([structName isEqualToString:@"CGRect"]) {
                    return $rect(INVOKE_FUNCTION_WITH_RETURN(CGRect));
                } else if ([structName isEqualToString:@"CGPoint"]) {
                    return $point(INVOKE_FUNCTION_WITH_RETURN(CGPoint));
                } else if ([structName isEqualToString:@"CGSize"]) {
                    return $size(INVOKE_FUNCTION_WITH_RETURN(CGSize));
                } else if ([structName isEqualToString:@"NSRange"]) {
                    return $range(INVOKE_FUNCTION_WITH_RETURN(NSRange));
                }
                return nil;
            }
            default:
                return nil;
        }
#undef FUNCTION_RETURN
    }
    
    __auto_type block = ^JSValue * _Nullable {
        JSContext *context = [JSContext currentContext];
        NSArray *args = [JSContext currentArguments];
        NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(meth)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:object];
        [invocation setSelector:sel];
        if (args.count != sig.numberOfArguments - 2) {
            [context setException:$(@"Arguments are not enough.")];
            return nil;
        }
        
        // Make sure the arguments are not released before the method is invoked.
        NSMutableSet *argSet = [NSMutableSet set];
        [args enumerateObjectsUsingBlock:^(JSValue *obj, NSUInteger idx, BOOL *stop) {
            NSUInteger index = idx + 2;
            __auto_type type = [sig getArgumentTypeAtIndex:index];
            __auto_type valueTypeDescription = ObjCValueTypeDescriptionWithEncodingType(type);
#define SET_ARG(__ARG__) [invocation setArgument:(void *) &__ARG__ atIndex:index]
            switch (valueTypeDescription.type) {
                case OJSObjCValueTypeObject:
                case OJSObjCValueTypeClass: {
                    id object = obj.ojs_proxyObject.object;
                    [invocation setArgument:&object atIndex:index];
                    [argSet addObject:object];
                } break;
                case OJSObjCValueTypeShort: {
                    short s = [obj toInt32];
                    SET_ARG(s);
                } break;
                case OJSObjCValueTypeInt: {
                    int i = [obj toInt32];
                    SET_ARG(i);
                } break;
                case OJSObjCValueTypeLong: {
                    long l = [obj toInt32];
                    SET_ARG(l);
                } break;
                case OJSObjCValueTypeLongLong: {
                    long long ll = (long long) [obj toDouble];
                    SET_ARG(ll);
                } break;
                case OJSObjCValueTypeFloat: {
                    float f = [obj toDouble];
                    SET_ARG(f);
                } break;
                case OJSObjCValueTypeDouble: {
                    double d = [obj toDouble];
                    SET_ARG(d);
                } break;
                case OJSObjCValueTypeUnsignedShort: {
                    unsigned short s = [obj toUInt32];
                    SET_ARG(s);
                } break;
                case OJSObjCValueTypeUnsignedInt: {
                    unsigned int i = [obj toUInt32];
                    SET_ARG(i);
                } break;
                case OJSObjCValueTypeUnsignedLong: {
                    unsigned long l = [obj toUInt32];
                    SET_ARG(l);
                } break;
                case OJSObjCValueTypeUnsignedLongLong: {
                    unsigned long long ll = [obj toDouble];
                    SET_ARG(ll);
                } break;
                case OJSObjCValueTypeBoolean: {
                    BOOL b = [obj toBool];
                    SET_ARG(b);
                } break;
                case OJSObjCValueTypeChar: {
                    char c = [obj toInt32];
                    SET_ARG(c);
                } break;
                case OJSObjCValueTypeUnsignedChar: {
                    unsigned char c = [obj toUInt32];
                    SET_ARG(c);
                } break;
                case OJSObjCValueTypeStruct: {
                    NSString *argTypeName = valueTypeDescription.name;
                    if ([argTypeName isEqualToString:@"CGRect"]) {
                        CGRect rect = [obj toRect];
                        SET_ARG(rect);
                    } else if ([argTypeName isEqualToString:@"CGPoint"]) {
                        CGPoint point = [obj toPoint];
                        SET_ARG(point);
                    } else if ([argTypeName isEqualToString:@"CGSize"]) {
                        CGSize size = [obj toSize];
                        SET_ARG(size);
                    } else if ([argTypeName isEqualToString:@"NSRange"]) {
                        NSRange range = [obj toRange];
                        SET_ARG(range);
                    } else {
                        int i = 0;
                        SET_ARG(i);
                    }
                } break;
                default: break;
            }
#undef SET_ARG
        }];
        
        [invocation invoke];
        
        __auto_type returnTypeDescription = ObjCValueTypeDescriptionWithEncodingType(sig.methodReturnType);
#define GET_RETURN_VALUE_WITH_TYPE(__TYPE__) \
    __TYPE__ returnValue; \
    [invocation getReturnValue:(void *) &returnValue]
        switch (returnTypeDescription.type) {
            case OJSObjCValueTypeObject:
            case OJSObjCValueTypeClass: {
                GET_RETURN_VALUE_WITH_TYPE(id);
                if (returnValue) {
                    (void) (__bridge_retained void *) returnValue;
                }
                return [self builderWithObject:returnValue inContext:context].jsValue;
            }
            case OJSObjCValueTypeShort: {
                GET_RETURN_VALUE_WITH_TYPE(short);
                return $int32(returnValue);
            }
            case OJSObjCValueTypeInt: {
                GET_RETURN_VALUE_WITH_TYPE(int);
                return $int32(returnValue);
            }
            case OJSObjCValueTypeLong: {
                GET_RETURN_VALUE_WITH_TYPE(long);
                return $int32(returnValue);
            }
            case OJSObjCValueTypeLongLong: {
                GET_RETURN_VALUE_WITH_TYPE(long long);
                return $double(returnValue);
            }
            case OJSObjCValueTypeFloat: {
                GET_RETURN_VALUE_WITH_TYPE(float);
                return $double(returnValue);
            }
            case OJSObjCValueTypeDouble: {
                GET_RETURN_VALUE_WITH_TYPE(double);
                return $double(returnValue);
            }
            case OJSObjCValueTypeUnsignedShort: {
                GET_RETURN_VALUE_WITH_TYPE(unsigned short);
                return $uint32(returnValue);
            }
            case OJSObjCValueTypeUnsignedInt: {
                GET_RETURN_VALUE_WITH_TYPE(unsigned int);
                return $uint32(returnValue);
            }
            case OJSObjCValueTypeUnsignedLong: {
                GET_RETURN_VALUE_WITH_TYPE(unsigned long);
                return $uint32(returnValue);
            }
            case OJSObjCValueTypeUnsignedLongLong: {
                GET_RETURN_VALUE_WITH_TYPE(unsigned long long);
                return $double(returnValue);
            }
            case OJSObjCValueTypeBoolean: {
                GET_RETURN_VALUE_WITH_TYPE(BOOL);
                return $bool(returnValue);
            }
            case OJSObjCValueTypeChar: {
                GET_RETURN_VALUE_WITH_TYPE(char);
                NSString *charValue = [NSString stringWithFormat:@"%c", returnValue];
                return $(charValue);
            }
            case OJSObjCValueTypeUnsignedChar: {
                GET_RETURN_VALUE_WITH_TYPE(unsigned char);
                NSString *unsignedCharValue = [NSString stringWithFormat:@"%hhu", returnValue];
                return $(unsignedCharValue);
            }
            case OJSObjCValueTypeStruct: {
                NSString *structName = returnTypeDescription.name;
                if ([structName isEqualToString:@"CGRect"]) {
                    GET_RETURN_VALUE_WITH_TYPE(CGRect);
                    return $rect(returnValue);
                } else if ([structName isEqualToString:@"CGPoint"]) {
                    GET_RETURN_VALUE_WITH_TYPE(CGPoint);
                    return $point(returnValue);
                } else if ([structName isEqualToString:@"CGSize"]) {
                    GET_RETURN_VALUE_WITH_TYPE(CGSize);
                    return $size(returnValue);
                } else if ([structName isEqualToString:@"NSRange"]) {
                    GET_RETURN_VALUE_WITH_TYPE(NSRange);
                    return $range(returnValue);
                }
                return nil;
            } break;
            default: break;
        }
#undef GET_RETURN_VALUE_WITH_TYPE
        return nil;
    };
    return $(block);
}

@end
