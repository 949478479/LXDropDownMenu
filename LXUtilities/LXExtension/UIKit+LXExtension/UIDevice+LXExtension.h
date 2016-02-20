//
//  UIDevice+LXExtension.h
//
//  Created by 从今以后 on 16/2/1.
//  Copyright © 2016年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (LXExtension)

/// 设备是否是 `iPad`。
+ (BOOL)lx_isPad;
/// 设备是否是 `iPhone`。
+ (BOOL)lx_isPhone;

/// 以字节为单位的设备内存大小。
+ (uint64_t)lx_physicalMemory;

@end

NS_ASSUME_NONNULL_END
