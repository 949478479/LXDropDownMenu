//
//  UIApplication+LXExtension.m
//
//  Created by 从今以后 on 16/2/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "UIApplication+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIApplication (LXExtension)

+ (nullable id<UIApplicationDelegate>)lx_appDelegate
{
	return [[self sharedApplication] delegate];
}

@end

NS_ASSUME_NONNULL_END
