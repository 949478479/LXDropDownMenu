//
//  GCD+LXExtension.swift
//
//  Created by 从今以后 on 16/1/18.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation

/// 获取 `DISPATCH_QUEUE_PRIORITY_HIGH` 优先级的全局队列。
func dispatch_get_high_global_queue() -> dispatch_queue_t {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
}

/// 获取 `DISPATCH_QUEUE_PRIORITY_DEFAULT` 优先级的全局队列。
func dispatch_get_default_global_queue() -> dispatch_queue_t {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
}

/// 获取 `DISPATCH_QUEUE_PRIORITY_LOW` 优先级的全局队列。
func dispatch_get_low_global_queue() -> dispatch_queue_t {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
}

/// 获取 `DISPATCH_QUEUE_PRIORITY_BACKGROUND` 优先级的全局队列。
func dispatch_get_background_global_queue() -> dispatch_queue_t {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
}

/// 延迟指定时间后提交闭包到主队列。
func dispatch_after(delay: NSTimeInterval, _ block: dispatch_block_t) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), block)
}

/// 创建一个基于 `dispatch_source_t` 的挂起状态的主线程定时器。
func dispatch_source_timer(interval: NSTimeInterval, leeway: NSTimeInterval,
    _ handler: dispatch_block_t) -> dispatch_source_t {

    let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())

    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW,
        UInt64(interval * Double(NSEC_PER_SEC)), UInt64(leeway * Double(NSEC_PER_SEC)))
        
    dispatch_source_set_event_handler(timer, handler)

    return timer
}

extension dispatch_object_t {

    /// 挂起。
    final func suspend() {
        dispatch_suspend(self)
    }

    /// 恢复。
    final func resume() {
        dispatch_resume(self)
    }
}

extension dispatch_source_t {
    
    /// 取消。
    final func cancel() {
        dispatch_source_cancel(self)
    }
}

extension dispatch_queue_t {

    /// 异步提交闭包到队列。
    final func async(block: dispatch_block_t) {
        dispatch_async(self, block)
    }

    /// 同步提交闭包到队列。
    final func sync(block: dispatch_block_t) {
        dispatch_sync(self, block)
    }

    /// 同步提交闭包到队列，并重复执行指定次数。
    final func apply(iterations: Int, _ block: Int -> Void) {
        dispatch_apply(iterations, self, block)
    }

    /// 异步提交屏障闭包到队列。
    final func barrier_async(block: dispatch_block_t) {
        dispatch_barrier_async(self, block)
    }
}

extension dispatch_group_t {

    /// 表明当前闭包已加入任务组。
    final func enter() {
        dispatch_group_enter(self)
    }

    /// 表明当前闭包执行完成，从任务组中移除。
    final func leave() {
        dispatch_group_leave(self)
    }

    /// 异步提交闭包到指定队列，并将闭包加入任务组。
    final func async(queue: dispatch_queue_t, _ block: dispatch_block_t) {
        dispatch_group_async(self, queue, block)
    }

    /// 无限等待直至任务组中的任务全部完成，即任务组为空时。
    final func waitForever() {
        dispatch_group_wait(self, DISPATCH_TIME_FOREVER)
    }

    /// 待任务组中的任务全部完成后（即任务组为空时）异步提交闭包到指定队列。
    final func notify(queue: dispatch_queue_t, _ block: dispatch_block_t) {
        dispatch_group_notify(self, queue, block)
    }
}

extension dispatch_semaphore_t {

    /// 增加信号量计数。
    /// - returns: 若有等待线程被唤醒则返回非零值，否则返回零。
    final func signal() -> Int {
        return dispatch_semaphore_signal(self)
    }

    /// 减少信号量计数并等待。
    /// - parameter timeout: 等待超时时间。
    /// - returns: 若等待超时则返回非零值，否则返回零。
    final func wait(timeout: dispatch_time_t) -> Int {
        return dispatch_semaphore_wait(self, timeout)
    }
}
