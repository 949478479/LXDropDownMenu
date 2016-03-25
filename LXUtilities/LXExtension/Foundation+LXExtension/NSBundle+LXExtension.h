//
//  NSBundle+LXExtension.h
//
//  Created by 从今以后 on 15/11/20.
//  Copyright © 2015年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (LXExtension)

///------------
/// @name 版本号
///------------

+ (NSString *)lx_versionString;
+ (NSString *)lx_shortVersionString;

@end

NS_ASSUME_NONNULL_END
