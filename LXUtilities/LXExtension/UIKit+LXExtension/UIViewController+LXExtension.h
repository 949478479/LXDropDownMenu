//
//  UIViewController+LXExtension.h
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (LXExtension)

///--------------
/// @name 各种条栏
///--------------

#pragma mark - 各种条栏 -

/// 控制器所属 `UITabBarController` 的 `tabBar`。
@property (nullable, nonatomic, readonly) UITabBar *lx_tabBar;
/// 控制器所属 `UINavigationController` 的 `toolBar`。
@property (nullable, nonatomic, readonly) UIToolbar *lx_toolBar;
/// 控制器所属 `UINavigationController` 的 `navigationBar`。
@property (nullable, nonatomic, readonly) UINavigationBar *lx_navigationBar;

///---------------
/// @name 实例化方法
///---------------

#pragma mark - 实例化方法 -

/// 实例化指定故事板中的初始控制器。
+ (instancetype)lx_instantiateWithStoryboardName:(NSString *)storyboardName;

/// 实例化指定故事板中的指定控制器。
+ (instancetype)lx_instantiateWithStoryboardName:(NSString *)storyboardName
									  identifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
