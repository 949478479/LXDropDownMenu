//
//  YZPullDownMenu.h
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXNibBridge.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YZOpenedPullDownMenu) {
    YZOpenedPullDownMenuNone,
    YZOpenedPullDownMenuLeft,
    YZOpenedPullDownMenuCenter,
    YZOpenedPullDownMenuRight,
};

@interface YZPullDownMenu : UIView <XXNibBridge>

/// 菜单单元格行高
@property (nonatomic) IBInspectable CGFloat rowHeight;
/// 菜单最大显示行数
@property (nonatomic) IBInspectable NSUInteger maxVisibleRows;
/// 动画持续时间
@property (nonatomic) IBInspectable double animationDuration;
/// 当前打开的菜单
@property (nonatomic, readonly) YZOpenedPullDownMenu openedPullDownMenu;

/// 即将打开左侧菜单，在闭包中返回要显示的菜单项
@property (nullable, nonatomic, copy) NSArray<NSString *> * (^willOpenLeftMenu)(YZPullDownMenu *menu);
/// 即将打开中间菜单，在闭包中返回要显示的菜单项
@property (nullable, nonatomic, copy) NSArray<NSString *> * (^willOpenCenterMenu)(YZPullDownMenu *menu);
/// 即将打开右侧菜单，在闭包中返回要显示的菜单项
@property (nullable, nonatomic, copy) NSArray<NSString *> * (^willOpenRightMenu)(YZPullDownMenu *menu);

/// 左侧按钮点击回调
@property (nonatomic, copy) void (^didTappedLeftButton)(YZPullDownMenu *menu);
/// 中间按钮点击回调
@property (nonatomic, copy) void (^didTappedCenterButton)(YZPullDownMenu *menu);
/// 右侧按钮点击回调
@property (nonatomic, copy) void (^didTappedRightButton)(YZPullDownMenu *menu);

@end

NS_ASSUME_NONNULL_END
