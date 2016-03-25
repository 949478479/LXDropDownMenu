//
//  GCD+LXExtension.h
//
//  Created by 从今以后 on 15/11/20.
//  Copyright © 2015年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// 创建基于 @c dispatch_source_t 的挂起状态的主线程定时器。
dispatch_source_t lx_dispatch_source_timer(NSTimeInterval secondInterval,
                                           NSTimeInterval secondLeeway,
                                           dispatch_block_t handler);

void lx_dispatch_after(NSTimeInterval delayInSeconds, dispatch_block_t handler);

NS_ASSUME_NONNULL_END
