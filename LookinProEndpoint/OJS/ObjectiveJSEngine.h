//
//  Created by ktiays on 2022/4/19.
//  Copyright (c) 2022 ktiays. All rights reserved.
// 

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OJSInteropHelperExports <JSExport>

- (JSValue *)classFromString:(NSString *)className;

- (JSValue *)debugDescriptionOfObject:(JSValue *)objectValue;

JSExportAs(dynamicCastAddress,
           - (nullable JSValue *)dynamicCastAddressToObject:(NSString *)address);

#pragma mark Struct Constructor

JSExportAs(makeCGPoint,
           - (JSValue *)makeCGPointWithX:(double)x y:(double)y);

JSExportAs(makeCGSize,
           - (JSValue *)makeCGSizeWithWidth:(double)width height:(double)height);

JSExportAs(makeCGRect,
           - (JSValue *)makeCGRectWithX:(double)x y:(double)y width:(double)width height:(double)height);

JSExportAs(makeCGRectWithOriginAndSize,
           - (JSValue *)makeCGRectWithOrigin:(JSValue *)originValue size:(JSValue *)sizeValue);

JSExportAs(makeNSRange,
           - (JSValue *)makeNSRangeWithLocation:(NSUInteger)location length:(NSUInteger)length);

@end

extern NSString * ojs_descriptionOfJSValue(JSValue * value);

@interface ObjectiveJSEngine : NSObject

@property (nonatomic, readonly) JSContext *context;

@end

NS_ASSUME_NONNULL_END
