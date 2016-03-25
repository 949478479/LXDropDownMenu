//
//  NSBundle+LXExtension.m
//
//  Created by 从今以后 on 15/11/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "NSBundle+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSBundle (LXExtension)

#pragma mark - 版本号

+ (NSString *)lx_versionString

{
    return [self.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)lx_shortVersionString
{
    return [self.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

@end

NS_ASSUME_NONNULL_END
