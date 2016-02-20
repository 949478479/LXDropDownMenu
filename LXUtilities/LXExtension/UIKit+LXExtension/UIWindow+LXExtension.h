//
//  UIWindow+LXExtension.h
//
//  Created by 从今以后 on 16/2/1.
//  Copyright © 2016年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (LXExtension)

/// 主窗口。
+ (nullable UIWindow *)lx_keyWindow;

/// 主窗口的根视图控制器。
+ (nullable UIViewController *)lx_rootViewController;

/// 主窗口的顶层视图控制器。
+ (nullable UIViewController *)lx_topViewController;

/// 将指定故事板中的初始控制器设置为主窗口的根控制器。
+ (void)lx_setRootViewControllerWithStoryboardName:(NSString *)storyboardName;

@end

NS_ASSUME_NONNULL_END
