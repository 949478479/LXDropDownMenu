//
//  NSDictionary+LXExtension.h
//
//  Created by 从今以后 on 15/10/10.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ObjectType> (LXExtension)

///----------------
/// @name 实例化方法
///----------------

/// 根据资源相对 @c mainBundle 的路径创建字典，资源名须带拓展名。
+ (nullable NSDictionary<KeyType, ObjectType> *)lx_dictionaryWithResourcePath:(NSString *)path;

///-------------------
/// @name 函数式便捷方法
///-------------------

- (NSMutableArray *)lx_map:(id _Nullable (^)(KeyType key, ObjectType obj))map;

- (NSMutableDictionary<KeyType, ObjectType> *)lx_filter:(BOOL (^)(KeyType key, ObjectType obj))filter;

@end

@interface NSMutableDictionary<KeyType, ObjectType> (LXExtension)

/**
 * 使用如下两个方法创建可变字典：
 *
 * @code
 *+[NSDictionary(NSSharedKeySetDictionary) sharedKeySetForKeys:]
 *+[NSMutableDictionary(NSSharedKeySetDictionary) dictionaryWithSharedKeySet:]
 * @endcode
 *
 * @note 共享键字典总是可变的，即使使用 @c -[NSMutableDictionary copy]。
 */
+ (NSMutableDictionary<KeyType, ObjectType> *)dictionaryWithSharedKeys:(NSArray<KeyType<NSCopying>> *)keys;

@end

NS_ASSUME_NONNULL_END
