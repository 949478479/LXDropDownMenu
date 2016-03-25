//
//  LXDynamicTypeManager.h
//
//  Created by 从今以后 on 16/1/22.
//  Copyright © 2016年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface LXDynamicTypeManager : NSObject

+ (void)addObserver:(id)observer usingBlock:(void (^)(void))block;
+ (void)removeObserver:(id)observer;

@end

NS_ASSUME_NONNULL_END
