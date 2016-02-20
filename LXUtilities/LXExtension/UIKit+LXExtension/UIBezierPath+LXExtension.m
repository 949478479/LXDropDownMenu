//
//  UIBezierPath+LXExtension.m
//
//  Created by 从今以后 on 15/12/12.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIBezierPath+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIBezierPath (LXExtension)

+ (instancetype)lx_bezierPathWithStartPoint:(CGPoint)start endPoint:(CGPoint)end
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    return path;
}

@end

NS_ASSUME_NONNULL_END
