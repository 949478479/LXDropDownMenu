//
//  LXRuntimeUtilities.h
//
//  Created by 从今以后 on 15/11/20.
//  Copyright © 2015年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

void LXMethodSwizzling(Class cls, SEL originalSelector, SEL swizzledSelector);

NSArray<NSString *> * lx_protocol_propertyList(Protocol *protocol);

NS_ASSUME_NONNULL_END
