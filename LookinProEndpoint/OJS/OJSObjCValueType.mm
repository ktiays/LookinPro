//
//  Created by Yuxin Chen on 2022/4/19.
//  Copyright (c) 2022 Yuxin Chen. All rights reserved.
//

#include <string>

#import <objc/runtime.h>

#import "OJSObjCValueType.h"

@implementation OJSObjCTypeDescription

- (instancetype)init {
    self = [super init];
    if (self) {
        _associatedTypes = [NSMutableArray array];
    }
    return self;
}

@end

#pragma mark - Parse Type Encoding

OJSObjCTypeDescription *parseSingleEncodingType(const char c) {
    auto description = [OJSObjCTypeDescription new];
    switch (c) {
        case _C_ID: description.type = OJSObjCValueTypeObject; break;
        case _C_CLASS: description.type = OJSObjCValueTypeClass; break;
        case _C_SEL: description.type = OJSObjCValueTypeSelector; break;
        case _C_CHR: description.type = OJSObjCValueTypeChar; break;
        case _C_UCHR: description.type = OJSObjCValueTypeUnsignedChar; break;
        case _C_SHT: description.type = OJSObjCValueTypeShort; break;
        case _C_USHT: description.type = OJSObjCValueTypeUnsignedShort; break;
        case _C_INT:
        case _C_ATOM: description.type = OJSObjCValueTypeInt; break;
        case _C_UINT: description.type = OJSObjCValueTypeUnsignedInt; break;
        case _C_LNG: description.type = OJSObjCValueTypeLong; break;
        case _C_LNG_LNG: description.type = OJSObjCValueTypeLongLong; break;
        case _C_ULNG: description.type = OJSObjCValueTypeUnsignedLong; break;
        case _C_ULNG_LNG: description.type = OJSObjCValueTypeUnsignedLongLong; break;
        case _C_FLT: description.type = OJSObjCValueTypeFloat; break;
        case _C_DBL: description.type = OJSObjCValueTypeDouble; break;
        case _C_BFLD: description.type = OJSObjCValueTypeBit; break;
        case _C_BOOL: description.type = OJSObjCValueTypeBoolean; break;
        case _C_VOID: description.type = OJSObjCValueTypeVoid; break;
        case _C_PTR: description.type = OJSObjCValueTypePointer; break;
        case _C_CHARPTR: description.type = OJSObjCValueTypeCharPointer; break;
        default: description.type = OJSObjCValueTypeUndefined; break;
    }
    return description;
}

OJSObjCTypeDescription *parseMultiEncodingType(std::string::iterator &iter) {
    enum parse_state {
        begin,
        array_t,
        struct_n,
        struct_t,
        union_n,
        union_t,
    };
    auto description = [OJSObjCTypeDescription new];
    std::string name;
    parse_state state = begin;
    char end_of_encoding = 0;
    do {
        switch (*iter) {
            case _C_ARY_B: {
                if (state == begin) {
                    end_of_encoding = _C_ARY_E;
                    description.type = OJSObjCValueTypeArray;
                    state = array_t;
                    break;
                }
            } break;
            case _C_STRUCT_B: {
                if (state == begin) {
                    end_of_encoding = _C_STRUCT_E;
                    description.type = OJSObjCValueTypeStruct;
                    state = struct_n;
                    break;
                }
                auto struct_description = parseMultiEncodingType(iter);
                [description.associatedTypes addObject:struct_description];
            } break;
            case _C_UNION_B: {
                if (state == begin) {
                    end_of_encoding = _C_UNION_E;
                    description.type = OJSObjCValueTypeUnion;
                    state = union_n;
                    break;
                }
                auto union_description = parseMultiEncodingType(iter);
                [description.associatedTypes addObject:union_description];
            } break;
            default: {
                if (state == array_t) break;
                
                if (*iter == '=') {
                    if (state == struct_n) {
                        state = struct_t;
                    } else if (state == union_n) {
                        state = union_t;
                    }
                    break;
                }
                
                if (state == struct_n || state == union_n) {
                    name += *iter;
                    break;
                }
                
                auto type_description = parseSingleEncodingType(*iter);
                [description.associatedTypes addObject:type_description];
            } break;
        }
        ++iter;
    } while(*iter != end_of_encoding);
    description.name = [NSString stringWithUTF8String:name.c_str()];
    return description;
}

OJSObjCTypeDescription *_valueTypeDescriptionWithEncodingType(const std::string::iterator begin, const std::string::iterator end) {
    OJSObjCTypeDescription *description = nil;
    for (auto iter = begin; iter != end; ++iter) {
        switch (*iter) {
            case _C_ARY_B:
            case _C_STRUCT_B:
            case _C_UNION_B:
                description = parseMultiEncodingType(iter);
                break;
            case _C_PTR:
                description = parseSingleEncodingType(*iter);
                [description.associatedTypes addObject:_valueTypeDescriptionWithEncodingType(++iter, end)];
                return description;
            default:
                description = parseSingleEncodingType(*iter);
                break;
        }
    }
    return description;
}

extern "C"
OJSObjCTypeDescription *ObjCValueTypeDescriptionWithEncodingType(const char *c) {
    std::string encoding_type(c);
    return _valueTypeDescriptionWithEncodingType(encoding_type.begin(), encoding_type.end());
}
