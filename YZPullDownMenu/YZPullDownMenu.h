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
/// 返回菜单分组对应的菜单项
- (NSArray<NSString *> *)pullDownMenu:(YZPullDownMenu *)menu itemsForMenuInSection:(NSUInteger)section;

@optional
/// 即将打开菜单分组
- (void)pullDownMenu:(YZPullDownMenu *)menu willOpenMenuInSection:(NSUInteger)section;
/// 选中菜单项
- (void)pullDownMenu:(YZPullDownMenu *)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface YZPullDownMenu : UIView <XXNibBridge>

/// 菜单展开关闭动画时间
@property (nonatomic) IBInspectable double animationDuration;
/// 菜单单元格行高
@property (nonatomic) IBInspectable CGFloat rowHeight;
/// 菜单最大显示行数
@property (nonatomic) IBInspectable NSUInteger maxVisibleRows;
/// 菜单栏按钮文本字体
@property (nullable, nonatomic) UIFont *buttonTextFont;
/// 菜单项文本字体
@property (nullable, nonatomic) UIFont *itemTextFont;
/// 菜单栏按钮标题和图片以及菜单项文本在普通状态下的颜色
@property (nullable, nonatomic) IBInspectable UIColor *normalColor;
/// 菜单栏按钮标题和图片以及菜单项文本在选中状态下的颜色
@property (nullable, nonatomic) IBInspectable UIColor *selectedColor;
/// 菜单项选中状态背景颜色
@property (nullable, nonatomic) IBInspectable UIColor *selectedBackgroundColor;

/// 菜单是否打开
@property (nonatomic, readonly) BOOL isOpen;
/// 当前打开的菜单分组，若没有打开的菜单，则分组为 NSNotFound
@property (nonatomic, readonly) NSUInteger currentMenuSection;
/// 菜单代理
@property (nullable, nonatomic, weak) IBOutlet id<YZPullDownMenuDelegate> delegate;

/// 选中指定的菜单项，不会触发相关代理方法
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
