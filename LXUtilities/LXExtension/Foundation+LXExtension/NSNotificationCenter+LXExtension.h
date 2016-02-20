//
//  NSNotificationCenter+LXExtension.h
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (LXExtension)

/// 使用 `defaultCenter` 注册键盘弹出收回通知。
+ (void)lx_observeKeyboardStateWithObserver:(id)observer
							selectorForShow:(SEL)aSelectorForShow
							selectorForHide:(SEL)aSelectorForHide;

/// 使用 `defaultCenter` 注册键盘 `frame` 即将改变通知。
+ (id<NSObject>)lx_observeKeyboardFrameChangeWithBlock:(void (^)(NSNotification *note))block;

/// 使用 `defaultCenter` 注册动态字体变化通知。
+ (id<NSObject>)lx_observeContentSizeCategoryChangeWithBlock:(void (^)(NSNotification *note))block;

@end

NS_ASSUME_NONNULL_END
