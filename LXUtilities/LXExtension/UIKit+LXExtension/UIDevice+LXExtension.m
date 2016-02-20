//
//  UIDevice+LXExtension.m
//
//  Created by 从今以后 on 16/2/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "UIDevice+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIDevice (LXExtension)

+ (BOOL)lx_isPad
{
	return [self currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL)lx_isPhone
{
	return [self currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

+ (uint64_t)lx_physicalMemory
{
	return [NSProcessInfo processInfo].physicalMemory;
}

@end

NS_ASSUME_NONNULL_END
