//
//  YZPullDownMenu.h
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXNibBridge.h"
@class YZPullDownMenu;

NS_ASSUME_NONNULL_BEGIN

@protocol YZPullDownMenuDelegate <NSObject>
@required
/// 返回索引对应的菜单的菜单项
- (NSArray<NSString *> *)pullDownMenu:(YZPullDownMenu *)menu itemsForMenuAtIndex:(NSUInteger)index;

@optional
- (void)pullDownMenu:(YZPullDownMenu *)menu willOpenMenuAtIndex:(NSUInteger)index;

@end

@interface YZPullDownMenu : UIView <XXNibBridge>

/// 菜单展开关闭动画持续时间
@property (nonatomic) IBInspectable double animationDuration;

/// 菜单单元格行高
@property (nonatomic) IBInspectable CGFloat rowHeight;
/// 菜单最大显示行数
@property (nonatomic) IBInspectable NSUInteger maxVisibleRows;

/// 菜单按钮文本字体
@property (nullable, nonatomic) UIFont *buttonTextFont;
/// 菜单项文本字体
@property (nullable, nonatomic) UIFont *itemTextFont;
/// 普通状态颜色
@property (nullable, nonatomic) IBInspectable UIColor *normalColor;
/// 选中状态颜色
@property (nullable, nonatomic) IBInspectable UIColor *selectedColor;
/// 菜单项选中状态背景颜色
@property (nullable, nonatomic) IBInspectable UIColor *selectedBackgroundColor;

/// 菜单是否打开
@property (nonatomic, readonly) BOOL isOpen;
/// 当前打开的菜单的索引，若没有打开的菜单，则索引为 NSNotFound
@property (nonatomic, readonly) NSUInteger currentMenuIndex;

/// 下拉菜单代理
@property (nonatomic, weak) IBOutlet id<YZPullDownMenuDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
