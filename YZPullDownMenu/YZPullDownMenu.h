//
//  YZPullDownMenu.h
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YZPullDownMenu;

NS_ASSUME_NONNULL_BEGIN

@protocol YZPullDownMenuDelegate <NSObject>

@required
/// 返回菜单分组数量
- (NSUInteger)numberOfSectionsInPullDownMenu:(YZPullDownMenu *)menu;
/// 返回菜单分组标题
- (NSArray<NSString *> *)sectionTitlesForPullDownMenu:(YZPullDownMenu *)menu;
/// 返回菜单分组中的菜单项标题
- (NSArray<NSString *> *)pullDownMenu:(YZPullDownMenu *)menu itemTitlesForMenuInSection:(NSUInteger)section;

@optional
/// 即将打开菜单分组
- (void)pullDownMenu:(YZPullDownMenu *)menu willOpenMenuInSection:(NSUInteger)section;
/// 菜单分组已经关闭
- (void)pullDownMenu:(YZPullDownMenu *)menu didCloseMenuInSection:(NSUInteger)section;
/// 选中菜单项
- (void)pullDownMenu:(YZPullDownMenu *)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface YZPullDownMenu : UIView

/// 菜单项文本字体,默认为 17.0 系统 字体
@property (null_resettable, nonatomic) UIFont *itemTextFont;
/// 菜单栏按钮文本字体,默认为 17.0 系统 字体
@property (null_resettable, nonatomic) UIFont *barButtonTextFont;
/// 菜单展开关闭动画时间
@property (nonatomic) IBInspectable double animationDuration;
/// 菜单单元格行高
@property (nonatomic) IBInspectable CGFloat rowHeight;
/// 菜单最大显示行数
@property (nonatomic) IBInspectable NSUInteger maxVisibleRows;
/// 菜单栏按钮标题和图片以及菜单项文本在普通状态下的颜色
@property (nullable, nonatomic) IBInspectable UIColor *normalColor;
/// 菜单栏按钮标题和图片以及菜单项文本在选中状态下的颜色
@property (nullable, nonatomic) IBInspectable UIColor *selectedColor;
/// 菜单栏分隔线颜色
@property (nullable, nonatomic) IBInspectable UIColor *separatorColor;
/// 菜单项选中状态背景颜色
@property (nullable, nonatomic) IBInspectable UIColor *selectedBackgroundColor;

/// 菜单是否打开
@property (nonatomic, readonly) BOOL isOpen;
/// 当前打开的菜单分组，若没有打开的菜单，则分组为 NSNotFound
@property (nonatomic, readonly) NSUInteger currentSection;

/// 菜单代理
@property (nullable, nonatomic, weak) IBOutlet id<YZPullDownMenuDelegate> delegate;

/// 选中指定的菜单项，不会触发相关代理方法
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath;

/// 打开指定的菜单分组，会触发相关代理方法
- (void)openMenuInSection:(NSUInteger)section;

/// 关闭当前打开的菜单分组，会触发相关代理方法
- (void)closeMenu;

@end

NS_ASSUME_NONNULL_END
