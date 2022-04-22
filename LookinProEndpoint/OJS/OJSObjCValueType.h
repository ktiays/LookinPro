//
//  Created by Yuxin Chen on 2022/4/19.
//  Copyright (c) 2022 Yuxin Chen. All rights reserved.
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, OJSObjCValueType) {
    OJSObjCValueTypeUndefined,
    OJSObjCValueTypeObject,
    OJSObjCValueTypeClass,
    OJSObjCValueTypeSelector,
    OJSObjCValueTypeChar,
    OJSObjCValueTypeUnsignedChar,
    OJSObjCValueTypeShort,
    OJSObjCValueTypeUnsignedShort,
    OJSObjCValueTypeInt,
    OJSObjCValueTypeUnsignedInt,
    OJSObjCValueTypeLong,
    OJSObjCValueTypeLongLong,
    OJSObjCValueTypeUnsignedLong,
    OJSObjCValueTypeUnsignedLongLong,
    OJSObjCValueTypeFloat,
    OJSObjCValueTypeDouble,
    OJSObjCValueTypeBit,
    OJSObjCValueTypeBoolean,
    OJSObjCValueTypeVoid,
    OJSObjCValueTypePointer,
    OJSObjCValueTypeCharPointer,
    OJSObjCValueTypeArray,
    OJSObjCValueTypeUnion,
    OJSObjCValueTypeStruct,
};

@interface OJSObjCTypeDescription : NSObject

@property (nonatomic, assign) OJSObjCValueType type;

@property (nonatomic, copy, nullable) NSString *name;

@property (nonatomic, strong) NSMutableArray<OJSObjCTypeDescription *> *associatedTypes;

@end

#ifdef __cplusplus
extern "C" {
#endif

extern OJSObjCTypeDescription * ObjCValueTypeDescriptionWithEncodingType(const char *c);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
