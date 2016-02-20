//
//  GCD+LXExtension.m
//
//  Created by 从今以后 on 15/11/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "GCD+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

dispatch_source_t lx_dispatch_source_timer(NSTimeInterval secondInterval,
                                           NSTimeInterval secondLeeway,
                                           dispatch_block_t handler)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, secondInterval * NSEC_PER_SEC, secondLeeway * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, handler);
    return timer;
}

void lx_dispatch_after(NSTimeInterval delayInSeconds, dispatch_block_t handler)
{
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), handler);
}

NS_ASSUME_NONNULL_END
