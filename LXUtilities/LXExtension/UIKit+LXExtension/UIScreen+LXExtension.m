//
//  UIScreen+LXExtension.m
//
//  Created by 从今以后 on 16/2/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "UIScreen+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIScreen (LXExtension)

+ (CGSize)lx_size
{
	return [self mainScreen].bounds.size;
}

+ (CGFloat)lx_scale
{
	return [self mainScreen].scale;
}

@end

NS_ASSUME_NONNULL_END
