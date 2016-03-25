//
//  LXMulticastDelegate.m
//
//  Created by 从今以后 on 15/9/25.
//  Copyright © 2015年 apple. All rights reserved.
//

@import ObjectiveC.runtime;
#import "LXMulticastDelegate.h"

#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

NS_ASSUME_NONNULL_BEGIN

@implementation LXMulticastDelegate {
    Protocol    *_protocol;
    NSHashTable *_delegates;
}

#pragma mark - 初始化 -

+ (LXMulticastDelegate *)multicastDelegateWithProtocol:(Protocol *)protocol
                                              delegate:(nullable id)delegate
{
    return [[self alloc] initWithProtocol:protocol delegate:delegate];
}

- (instancetype)initWithProtocol:(Protocol *)protocol delegate:(nullable id)delegate
{
    NSParameterAssert(protocol != nil);
    NSParameterAssert([delegate conformsToProtocol:protocol]);

    _protocol = protocol;
    _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory |
                  NSPointerFunctionsOpaquePersonality];

    if (delegate) {
        [_delegates addObject:delegate];
    }

    return self;
}

#pragma mark - 添加、移除代理成员 -

- (void)addDelegate:(id)delegate
{
    NSParameterAssert(delegate != nil);
    NSParameterAssert([delegate conformsToProtocol:_protocol]);

    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id)delegate
{
    NSParameterAssert(delegate != nil);

    [_delegates removeObject:delegate];
}

- (void)removeAllDelegates
{
    [_delegates removeAllObjects];
}

#pragma mark - 消息转发 -

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    // 先查找 required 协议方法
    struct objc_method_description desc = protocol_getMethodDescription(_protocol, sel, YES, YES);

    // 若未找到，进一步查找 option 协议方法
    if (!desc.types) {
        desc = protocol_getMethodDescription(_protocol, sel, NO, YES);
    }

    // 若找到，生成方法签名
    if (desc.types) {
        return [NSMethodSignature signatureWithObjCTypes:desc.types];
    }

    /* 返回 nil 将直接导致如下异常。为了能显示类名，手动抛出异常。
     *** Terminating app due to uncaught exception 'NSInvalidArgumentException',
     reason: '*** -[NSProxy doesNotRecognizeSelector:objectAtIndex:] called!' */
    NSString *reason = [NSString stringWithFormat:@"*** -[%@ doesNotRecognizeSelector:%s] called!",
                        object_getClass(self), sel_getName(sel)];

    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:reason
                                 userInfo:nil];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL sel = invocation.selector;
    for (id delegate in _delegates) {
        if ([delegate respondsToSelector:sel]) {
            [invocation invokeWithTarget:delegate];
        }
    }
}

#pragma mark - 调试

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>\n%@",
            object_getClass(self), self, _delegates.allObjects];
}

@end

NS_ASSUME_NONNULL_END
