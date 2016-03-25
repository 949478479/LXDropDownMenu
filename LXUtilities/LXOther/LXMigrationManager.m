//
//  LXMigrationManager.m
//
//  Created by 从今以后 on 16/1/29.
//  Copyright © 2016年 apple. All rights reserved.
//

@import CoreData;
#import "LXMigrationManager.h"

NS_ASSUME_NONNULL_BEGIN

@implementation LXMigrationManager

static NSManagedObjectModel *_finalModel;
static NSMutableArray<NSURL *> *_modelURLs;

+ (BOOL)progressivelyMigrateStoreFromURL:(NSURL *)sourceStoreURL
							   storeType:(NSString *)storeType
							   modelName:(NSString *)modelName
								   error:(NSError **)error
{
	// 获取当前数据库的元数据，用于判断兼容性
	NSDictionary *sourceMetadata =
	[NSPersistentStoreCoordinator metadataForPersistentStoreOfType:storeType
															   URL:sourceStoreURL
														   options:nil
															 error:error];
	if (!sourceMetadata) {
		return NO;
	}

	if (_finalModel == nil) {
		_finalModel = [self __modelForModelName:modelName];
	}

	// 检查当前版本和最终版本是否兼容，若不兼容则需要迁移
	if ([_finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
		if (error != NULL) {
			*error = nil;
		}
		return YES;
	}

	// 遍历应用程序包中各版本的模型文件，并尝试匹配包中的迁移映射文件
	NSMappingModel *mappingModel = nil;
	NSManagedObjectModel *destinationModel = nil;
	NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil
																	forStoreMetadata:sourceMetadata];
	if (![self __getDestinationModel:&destinationModel
						mappingModel:&mappingModel
					  forSourceModel:sourceModel
					   withModelName:modelName
							   error:error]) {
		return NO; // 未找到对应的映射文件，判定为迁移失败，停止迁移
	}

	// 迁移前先创建临时存储路径
	NSURL *destinationStoreURL = [self __destinationStoreURLWithSourceStoreURL:sourceStoreURL];
	NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
																 destinationModel:destinationModel];
	// 执行迁移过程
	if (![manager migrateStoreFromURL:sourceStoreURL
								 type:storeType
							  options:nil
					 withMappingModel:mappingModel
					 toDestinationURL:destinationStoreURL
					  destinationType:storeType
				   destinationOptions:nil
								error:error]) {
		return NO;
	}

	// 用临时数据库替换旧数据库
	if (![self __replaceSourceStoreAtURL:sourceStoreURL
			   withDestinationStoreAtURL:destinationStoreURL
								   error:error]) {
		return NO;
	}

	// 已经迁移到最终版本，迁移结束
	if ([destinationModel isEqual:_finalModel]) {
		_finalModel = nil;
		_modelURLs  = nil;
		return YES;
	}

	// 只往后迁移了一个版本，继续递归
	return [self progressivelyMigrateStoreFromURL:sourceStoreURL
										storeType:storeType
										modelName:modelName
											error:error];
}

+ (BOOL)__getDestinationModel:(NSManagedObjectModel * _Nonnull *)destinationModel
				 mappingModel:(NSMappingModel * _Nonnull *)mappingModel
			   forSourceModel:(NSManagedObjectModel *)sourceModel
				withModelName:(NSString *)modelName
						error:(NSError **)error
{
	*mappingModel = nil;
	*destinationModel = nil;

	if (_modelURLs == nil) {
		_modelURLs = [[self __modelPathsForModelName:modelName] mutableCopy];
	}

	if (_modelURLs.count == 0) {
		if (error != NULL) {
			*error = [NSError errorWithDomain:@"LXMigrationDomain"
										 code:233
									 userInfo:@{NSLocalizedDescriptionKey : @"未找到匹配的映射模型!"}];
		}
		return NO;
	}

	__block NSUInteger index = NSNotFound;
	__block NSMappingModel *mapping = nil;
	__block NSManagedObjectModel *model = nil;

	[_modelURLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull modelURL,
											  NSUInteger idx,
											  BOOL * _Nonnull stop) {

		// 根据应用程序包中的某个 .mom 文件（即 .xcdatamodel 文件）创建 NSManagedObjectModel
		model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

		// 根据当前模型和目标模型在应用程序包内查找对应的迁移映射文件
		mapping = [NSMappingModel mappingModelFromBundles:nil
										   forSourceModel:sourceModel
										 destinationModel:model];
		if (mapping != nil) {
			index = idx;
			*stop = YES;
		}
	}];

	if (index != NSNotFound) {
		*mappingModel = mapping;
		*destinationModel = model;
		[_modelURLs removeObjectAtIndex:index]; // 移除该路径避免下次递归时重复判断
		return YES;
	}

	if (error != NULL) {
		*error = [NSError errorWithDomain:@"LXMigrationDomain"
									 code:233
								 userInfo:@{NSLocalizedDescriptionKey : @"未找到匹配的映射模型!"}];
	}
	return NO;
}

+ (NSManagedObjectModel *)__modelForModelName:(NSString *)modelName
{
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
	return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

+ (NSArray<NSURL *> *)__modelPathsForModelName:(NSString *)modelName
{
	// 各版本的 .xcdatamodel 文件均位于应用程序包的 .momd 文件夹内，扩展名 .xcdatamodel 会变为 .mom
	NSString *directory = [modelName stringByAppendingPathExtension:@"momd"];
	return [[NSBundle mainBundle] URLsForResourcesWithExtension:@"mom" subdirectory:directory];
}

+ (NSURL *)__destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL
{
	// xxx.sqlite => xxx_temp.sqlite
	NSString *absoluteString = sourceStoreURL.absoluteString;
	NSRange range = [absoluteString rangeOfString:@"." options:NSBackwardsSearch];
	absoluteString = [absoluteString stringByReplacingCharactersInRange:range withString:@"_temp."];
	return [NSURL URLWithString:absoluteString];
}

+ (BOOL)__replaceSourceStoreAtURL:(NSURL *)sourceStoreURL
		withDestinationStoreAtURL:(NSURL *)destinationStoreURL
							error:(NSError **)error
{
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// 移除旧版数据库
	if (![fileManager removeItemAtURL:sourceStoreURL error:error]) {
		return NO;
	}

	// 将新版数据库改名为旧版数据库
	if (![fileManager moveItemAtURL:destinationStoreURL toURL:sourceStoreURL error:error]) {
		return NO;
	}

	return YES;
}

@end

NS_ASSUME_NONNULL_END
