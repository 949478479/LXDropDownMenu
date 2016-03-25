//
//  NSFileManager+LXExtension.h
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (LXExtension)

///-----------------
/// @name 路径 & URL
///-----------------

#pragma mark - 路径 & URL -

/// `Documents` 文件夹路径。
+ (NSString *)lx_pathForDocumentDirectory;
/// `Library` 文件夹路径。
+ (NSString *)lx_pathForLibraryDirectory;
/// `Caches` 文件夹路径。
+ (NSString *)lx_pathForCachesDirectory;
/// `Application Support` 文件夹路径，若不存在则创建。
+ (NSString *)lx_pathForApplicationSupportDirectory;

/// `Documents` 文件夹 `URL`。
+ (NSURL *)lx_URLForDocumentDirectory;
/// `Library` 文件夹 `URL`。
+ (NSURL *)lx_URLForLibraryDirectory;
/// `Caches` 文件夹 `URL`。
+ (NSURL *)lx_URLForCachesDirectory;
/// `Application Support` 文件夹 `URL`，若不存在则创建。
+ (NSURL *)lx_URLForApplicationSupportDirectory;

///-----------
/// @name 文件
///-----------

#pragma mark - 文件 -

/// 计算文件或目录所占字节数。
+ (uint64_t)lx_sizeOfItemAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
