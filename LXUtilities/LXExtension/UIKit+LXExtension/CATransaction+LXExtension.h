//
//  CATransaction+LXExtension.h
//
//  Created by 从今以后 on 15/11/23.
//  Copyright © 2015年 apple. All rights reserved.
//

@import QuartzCore;

NS_ASSUME_NONNULL_BEGIN

@interface CATransaction (LXExtension)

/**
 *  禁用隐式动画。
 *
 *  @param actionsWithoutAnimation 在 block 内修改图层属性不会触发隐式动画。
 */
+ (void)lx_performWithoutAnimation:(void (^)(void))actionsWithoutAnimation;

/**
 *  定制隐式动画。
 *
 *  @param duration   隐式动画持续时间。
 *  @param animations 在此 block 内修改图层属性。
 *  @param completion 隐式动画完成时调用此 block。
 */
+ (void)lx_animateWithDuration:(NSTimeInterval)duration
                    animations:(void (^)(void))animations
                    completion:(nullable void (^)(void))completion;
@end

NS_ASSUME_NONNULL_END
