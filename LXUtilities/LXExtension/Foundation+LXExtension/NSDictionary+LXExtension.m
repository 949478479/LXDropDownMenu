//
//  NSDictionary+LXExtension.m
//
//  Created by 从今以后 on 15/10/10.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@protocol LXDescriptionProtocol;
#import "NSDictionary+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark -

@implementation NSDictionary (LXExtension)

#pragma mark - 实例化方法 -

+ (nullable NSDictionary *)lx_dictionaryWithResourcePath:(NSString *)path
{
	return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:nil]];
}

#pragma mark - 函数式便捷方法 -

- (NSMutableArray *)lx_map:(id _Nullable (^)(id _Nonnull, id _Nonnull))map
{
	NSUInteger count = self.count;

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];

	if (count == 0) {
		return array;
	}

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key,
                                              id _Nonnull obj,
                                              BOOL *_Nonnull stop) {
        id result = map(key, obj);
		if (result) {
			[array addObject:result];
		}
    }];

    return array;
}

- (NSMutableDictionary *)lx_filter:(BOOL (^)(id _Nonnull, id _Nonnull))filter
{
	NSUInteger count = self.count;

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];

	if (count == 0) {
		return dict;
	}

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key,
                                              id _Nonnull obj,
                                              BOOL *_Nonnull stop) {
		if (filter(key, obj)) {
			dict[key] = obj;
		}
    }];

    return dict;
}

#pragma mark - 打印对齐 -

#ifdef DEBUG
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wat-protocol"
- (NSString *)descriptionWithLocale:(nullable id)locale
{
    NSMutableString *description = [NSMutableString stringWithString:@"{\n"];

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key,
											  id _Nonnull obj,
											  BOOL *_Nonnull stop) {
        NSMutableString *subDescription =
		[NSMutableString stringWithFormat:@"    %@ = %@;\n", key, obj];

        if ([obj isKindOfClass:NSArray.self] ||
            [obj isKindOfClass:NSDictionary.self] ||
            [obj conformsToProtocol:@protocol(LXDescriptionProtocol)]) {

            [subDescription replaceOccurrencesOfString:@"\n"
                                            withString:@"\n    "
                                               options:(NSStringCompareOptions)0
                                                 range:(NSRange){0,subDescription.length - 1}];
        }

        [description appendString:subDescription];
    }];

    [description appendString:@"}"];

    return description.copy;
}
#pragma clang diagnostic pop
- (NSString *)debugDescription
{
    return [self descriptionWithLocale:nil];
}
#endif

@end

#pragma mark -

@implementation NSMutableDictionary (LXExtension)

#pragma mark - 实例化方法 -

+ (NSMutableDictionary *)dictionaryWithSharedKeys:(NSArray<id<NSCopying>> *)keys
{
	return [NSMutableDictionary dictionaryWithSharedKeySet:[NSDictionary sharedKeySetForKeys:keys]];
}

@end

NS_ASSUME_NONNULL_END
