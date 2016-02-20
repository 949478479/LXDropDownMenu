//
//  LXCoreDataController.m
//
//  Created by 从今以后 on 16/1/29.
//  Copyright © 2016年 apple. All rights reserved.
//

@import UIKit;
#import "LXMacro.h"
#import "LXMigrationManager.h"
#import "LXCoreDataController.h"
#import "NSFileManager+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation LXCoreDataController

@synthesize storeURL = _storeURL;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (instancetype)init
{
	NSAssert(NO, @"使用指定构造器 -[LXCoreDataController initWithModelName:storeName:storeType:]");
	return [self initWithModelName:@"" storeName:@"" storeType:@""];
}

- (instancetype)initWithModelName:(NSString *)modelName
						storeName:(NSString *)storeName
						storeType:(NSString *)storeType
{
	self = [super init];
	if (self) {
		_modelName = modelName.copy;
		_storeName = storeName.copy;
		_storeType = storeType.copy;
	}
	return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext == nil) {
		_managedObjectContext =
		[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		_managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
	}
	return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel == nil) {
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_modelName withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	}
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator == nil) {

		NSError *error = nil;
		_persistentStoreCoordinator =
		[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

		[_persistentStoreCoordinator addPersistentStoreWithType:self.storeType
												  configuration:nil
															URL:self.storeURL
														options:nil
														  error:&error];
		if (error != nil) {
			LXLog(error.localizedDescription);
			abort();
		}
	}

	return _persistentStoreCoordinator;
}

- (NSURL *)storeURL
{
	if (_storeURL == nil) {
		NSString *storeName = [NSString stringWithFormat:@"%@.sqlite", _storeName];
		NSURL *directoryURL = [NSFileManager lx_URLForApplicationSupportDirectory];
		_storeURL = [directoryURL URLByAppendingPathComponent:storeName];
	}
	return _storeURL;
}

- (BOOL)isMigrationNeeded
{
	NSError *error = nil;
	NSDictionary *sourceMetadata =
	[NSPersistentStoreCoordinator metadataForPersistentStoreOfType:self.storeType
															   URL:self.storeURL
														   options:nil
															 error:&error];
	// 若当前数据库的元数据和当前模型不兼容，则需要进行迁移
	if (sourceMetadata != nil) {
		return ![self.managedObjectModel isConfiguration:nil
							 compatibleWithStoreMetadata:sourceMetadata];
	}

	LXLog(error.localizedDescription);
	
	return NO;
}

- (BOOL)migrate:(NSError **)error
{
	// 确保程序进入后台后也能继续迁移过程
	__block UIBackgroundTaskIdentifier bgTask;
	bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTask];
	}];

	BOOL success = [LXMigrationManager progressivelyMigrateStoreFromURL:self.storeURL
															  storeType:self.storeType
															  modelName:self.modelName
																  error:error];
	success ? LXLog(@"迁移完成!~") : LXLog(@"迁移失败。。");

	[[UIApplication sharedApplication] endBackgroundTask:bgTask];

	return success;
}

- (BOOL)saveIfNeed:(NSError **)error
{
	if (self.managedObjectContext.hasChanges) {
		return [self.managedObjectContext save:error];
	}

	if (error != NULL) {
		*error = nil;
	}

	return YES;
}

@end

NS_ASSUME_NONNULL_END
