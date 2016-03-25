//
//  NSObject+LXExtension.m
//
//  Created by 从今以后 on 15/9/14.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import ObjectiveC.runtime;
#import "LXUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (LXExtension)

#pragma mark - 方法交换 -

#ifdef DEBUG
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LXMethodSwizzling(self, @selector(description), @selector(lx_description));
    });
}
#endif

#pragma mark - 关联对象 -

- (void)lx_setValue:(nullable id)value forKey:(NSString *)key
{
    objc_setAssociatedObject(self, NSSelectorFromString(key), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable id)lx_valueForKey:(NSString *)key
{
    return objc_getAssociatedObject(self, NSSelectorFromString(key));
}

#pragma mark - KVO -

- (void)lx_removeAllObservers
{
    for (id observance in [(__bridge id)[self observationInfo] valueForKey:@"observances"]) {
        [self removeObserver:[observance valueForKey:@"observer"]
                  forKeyPath:[observance valueForKeyPath:@"property.keyPath"]];
    }
}

#pragma mark - 调试增强 -

#ifdef DEBUG
- (NSString *)lx_description
{
	if ([self lx_valueForKey:@"lx_description"]) {
		return @"..."; // 防止 description 或 debugDescription 方法死循环
	}
	[self lx_setValue:@YES forKey:@"lx_description"];

    if (![self conformsToProtocol:@protocol(LXDescriptionProtocol)]) {
        return [self lx_description];
    }

    NSMutableDictionary *varInfo = [NSMutableDictionary new];
    for (NSString *propertyName in [self.class lx_propertyNameList]) {
        id value = [self valueForKey:propertyName] ?: @"nil";
        if (!strcmp(class_getName(object_getClass(value)), "__NSCFBoolean")) {
            value = [value boolValue] ? @"YES" : @"NO";
        }
        varInfo[propertyName] = value;
    }

	NSString *description = [NSString stringWithFormat:@"<%@: %p>\n%@", self.class, self, varInfo];

	[self lx_setValue:nil forKey:@"lx_description"];

    return description;
}
#endif

@end

NS_ASSUME_NONNULL_END
