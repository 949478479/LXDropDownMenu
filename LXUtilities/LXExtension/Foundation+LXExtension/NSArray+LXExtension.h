//
//  NSArray+LXExtension.h
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (LXExtension)

///----------------
/// @name 实例化方法
///----------------

/// 根据资源相对 @c mainBundle 的路径创建数组，资源名须带拓展名。
+ (nullable NSArray<ObjectType> *)lx_arrayWithResourcePath:(NSString *)path;

///-------------------
/// @name 函数式便捷方法
///-------------------

- (NSMutableArray *)lx_map:(id _Nullable (^)(ObjectType obj, NSUInteger idx))map;

- (NSMutableArray<ObjectType> *)lx_filter:(BOOL (^)(ObjectType obj, NSUInteger idx))filter;

@end

NS_ASSUME_NONNULL_END
