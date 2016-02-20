//
//  LXDynamicTypeManager.m
//
//  Created by 从今以后 on 16/1/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LXDynamicTypeManager.h"

NS_ASSUME_NONNULL_BEGIN

@implementation LXDynamicTypeManager

static NSMapTable<id, void (^)(void)> *LXObserverAndBlocks;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSPointerFunctionsOptions keyOptions = NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality;
        NSPointerFunctionsOptions valueOptions = NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality;
        LXObserverAndBlocks = [NSMapTable mapTableWithKeyOptions:keyOptions valueOptions:valueOptions];

        void (^usingBlock)(NSNotification * _Nonnull) = ^(NSNotification * _Nonnull note) {
            for (void (^block)(void) in LXObserverAndBlocks.objectEnumerator) {
                block();
            }
        };

        [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:usingBlock];
    });
}

+ (void)addObserver:(id)observer usingBlock:(void (^)(void))block
{
    [LXObserverAndBlocks setObject:block forKey:observer];
}

+ (void)removeObserver:(id)observer
{
    [LXObserverAndBlocks removeObjectForKey:observer];
}

@end

NS_ASSUME_NONNULL_END
