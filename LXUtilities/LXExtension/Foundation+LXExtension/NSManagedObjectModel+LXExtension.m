//
//  NSManagedObjectModel+LXExtension.m
//
//  Created by 从今以后 on 16/1/29.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "NSManagedObjectModel+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSManagedObjectModel (LXExtension)

+ (nullable NSArray<NSURL *> *)lx_modelURLsForModelName:(NSString *)modelName
{
	// 各版本的 .xcdatamodel 文件均位于应用程序包的 .momd 文件夹内，扩展名 .xcdatamodel 会变为 .mom
	NSString *directory = [modelName stringByAppendingPathExtension:@"momd"];
	return [[NSBundle mainBundle] URLsForResourcesWithExtension:@"mom" subdirectory:directory];
}

+ (nullable NSArray<NSURL *> *)lx_allModelURLs
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *momdURLs = [mainBundle URLsForResourcesWithExtension:@"momd" subdirectory:nil];

	if (momdURLs.count == 0) {
		return nil;
	}

	NSMutableArray *modelPaths = [NSMutableArray new];

	for (NSURL *momdURL in momdURLs) {
		NSString *directory = [momdURL lastPathComponent];
		NSArray *paths = [mainBundle URLsForResourcesWithExtension:@"mom" subdirectory:directory];
		[modelPaths addObjectsFromArray:paths];
	}

	return modelPaths;
}

- (nullable NSString *)lx_modelName
{
	for (NSURL *modelURL in [self.class lx_allModelURLs]) {
		if ([[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] isEqual:self]) {
			return modelURL.lastPathComponent.stringByDeletingPathExtension;
		}
	}
	return nil;
}

@end

NS_ASSUME_NONNULL_END
