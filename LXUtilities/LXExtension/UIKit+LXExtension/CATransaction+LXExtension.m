//
//  CATransaction+LXExtension.m
//
//  Created by 从今以后 on 15/11/23.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "CATransaction+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CATransaction (LXExtension)

+ (void)lx_performWithoutAnimation:(void (^)(void))actionsWithoutAnimation
{
    [self begin];
    [self setDisableActions:YES];
    actionsWithoutAnimation();
    [self commit];
}

+ (void)lx_animateWithDuration:(NSTimeInterval)duration
                    animations:(void (^)(void))animations
                    completion:(nullable void (^)(void))completion
{
    [self begin];
    [self setAnimationDuration:duration];
    [self setCompletionBlock:completion];
    animations();
    [self commit];
}

@end

NS_ASSUME_NONNULL_END
