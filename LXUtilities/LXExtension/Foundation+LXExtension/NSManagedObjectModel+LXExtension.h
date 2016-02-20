//
//  NSManagedObjectModel+LXExtension.h
//
//  Created by 从今以后 on 16/1/29.
//  Copyright © 2016年 apple. All rights reserved.
//

@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectModel (LXExtension)

/// `NSManagedObjectModel` 对应的 `.xcdatamodel` 文件名。
- (nullable NSString *)lx_modelName;

/// 获取应用程序包中所有 `.xcdatamodel` 文件的 `URL`。
+ (nullable NSArray<NSURL *> *)lx_allModelURLs;

/// 获取指定 `.xcdatamodeld` 模型文件包中的所有版本的 `.xcdatamodel` 模型文件的 `URL`。
+ (nullable NSArray<NSURL *> *)lx_modelURLsForModelName:(NSString *)modelName;

@end

NS_ASSUME_NONNULL_END
