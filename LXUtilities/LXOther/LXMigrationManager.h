//
//  LXMigrationManager.h
//
//  Created by 从今以后 on 16/1/29.
//  Copyright © 2016年 apple. All rights reserved.
//

@import Foundation;
@class NSManagedObjectModel;

NS_ASSUME_NONNULL_BEGIN

@interface LXMigrationManager : NSObject

/// 查找 `mainBundle` 中的映射文件，迁移当前数据库，使之兼容最新模型。若成功返回 `YES`，否则返回 `NO`。
+ (BOOL)progressivelyMigrateStoreFromURL:(NSURL *)sourceStoreURL
							   storeType:(NSString *)storeType
							   modelName:(NSString *)modelName
								   error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
