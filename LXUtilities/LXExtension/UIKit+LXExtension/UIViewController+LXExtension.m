//
//  UIViewController+LXExtension.m
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIViewController+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (LXExtension)

#pragma mark - 各种条栏 -

- (nullable UITabBar *)lx_tabBar
{
    return self.tabBarController.tabBar;
}

- (nullable UIToolbar *)lx_toolBar
{
	return self.navigationController.toolbar;
}

- (nullable UINavigationBar *)lx_navigationBar
{
    return self.navigationController.navigationBar;
}

#pragma mark - 实例化方法 -

+ (instancetype)lx_instantiateWithStoryboardName:(NSString *)storyboardName
{
    return [self lx_instantiateWithStoryboardName:storyboardName identifier:(NSString *_Nonnull)nil];
}

+ (instancetype)lx_instantiateWithStoryboardName:(NSString *)storyboardName
                                      identifier:(NSString *)identifier
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];

    if (identifier) {
        return [storyboard instantiateViewControllerWithIdentifier:identifier];
    }

    return [storyboard instantiateInitialViewController];
}

@end

NS_ASSUME_NONNULL_END
