//
//  LXCoreDataController.h
//
//  Created by 从今以后 on 16/1/29.
//  Copyright © 2016年 apple. All rights reserved.
//

@import CoreData;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXCoreDataController : NSObject

- (LXCoreDataController *)initWithModelName:(NSString *)modelName
								  storeName:(NSString *)storeName
								  storeType:(NSString *)storeType NS_DESIGNATED_INITIALIZER;

- (BOOL)migrate:(NSError **)error;
- (BOOL)saveIfNeed:(NSError **)error;

@property (nonatomic, readonly) BOOL isMigrationNeeded;

@property (nonatomic, readonly) NSURL	 *storeURL;
@property (nonatomic, readonly) NSString *modelName;
@property (nonatomic, readonly) NSString *storeName;
@property (nonatomic, readonly) NSString *storeType;

@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

NS_ASSUME_NONNULL_END
