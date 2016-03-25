//
//  LXTimer.h
//
//  Created by 从今以后 on 15/11/30.
//  Copyright © 2015年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXTimer : NSObject

/// 定时器是否有效。
@property (nonatomic, readonly, getter=isValid) BOOL valid;

/// 定时器的触发间隔。
@property (nonatomic, readonly) NSTimeInterval timeInterval;

/// 定时器的宽容度。
@property (nonatomic, readonly) NSTimeInterval tolerance;

/// 令定时器失效。
- (void)invalidate;

/// 创建基于 @c dispatch_source_t 的主线程定时器。定时器需被强引用。
+ (LXTimer *)timerWithInterval:(NSTimeInterval)timeInterval
                     tolerance:(NSTimeInterval)tolerance
                       handler:(void (^)(void))handler;

/// 创建基于 @c dispatch_source_t 的主线程定时器。定时器需被强引用。
+ (LXTimer *)timerWithTimeInterval:(NSTimeInterval)timeInterval
                         tolerance:(NSTimeInterval)tolerance
                            target:(id)target
                          selector:(SEL)selector;

@end

NS_ASSUME_NONNULL_END
