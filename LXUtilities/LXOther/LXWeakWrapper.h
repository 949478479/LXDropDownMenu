//
//  LXWeakWrapper.h
//
//  Created by 从今以后 on 16/1/1.
//  Copyright © 2016年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXWeakWrapper<ObjectType> : NSObject

@property (nonatomic, weak, readonly) ObjectType object;

+ (instancetype)wrapperWithObject:(ObjectType)object;

@end

NS_ASSUME_NONNULL_END
