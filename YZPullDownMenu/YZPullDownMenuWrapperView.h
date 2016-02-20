//
//  YZPullDownMenuWrapperView.h
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZPullDownMenuWrapperView : UIView

/// 菜单蒙版点击回调
@property (nonatomic, copy) void (^didTappedBackgoundView)(void);

+ (instancetype)menuWrapperView;

@end

NS_ASSUME_NONNULL_END