//
//  UIApplication+LXExtension.h
//
//  Created by 从今以后 on 16/2/1.
//  Copyright © 2016年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (LXExtension)

/// `sharedApplication` 的代理。
+ (nullable id<UIApplicationDelegate>)lx_appDelegate;

@end

NS_ASSUME_NONNULL_END
