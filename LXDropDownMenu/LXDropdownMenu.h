//
//  LXDropdownMenu.h
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXDropdownMenu;

NS_ASSUME_NONNULL_BEGIN

@protocol LXDropdownMenuDataSource <NSObject>
@required

/// 返回菜单分组标题数组，标题个数对应菜单分组个数
- (NSArray<NSString *> *)sectionTitlesForDropdownMenu:(LXDropdownMenu *)menu;

/// 返回相应菜单分组中的单元格数量
- (NSInteger)dropdownMenu:(LXDropdownMenu *)menu numberOfRowsInSection:(NSInteger)section;

/// 返回相应菜单分组中相应行的单元格
- (UITableViewCell *)dropdownMenu:(LXDropdownMenu *)menu cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/// 返回相应菜单分组的菜单高度
- (CGFloat)dropdownMenu:(LXDropdownMenu *)menu heightForMenuInSection:(NSInteger)section;

/// 返回相应菜单分组中相应行的行高
- (CGFloat)dropdownMenu:(LXDropdownMenu *)menu heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol LXDropdownMenuDelegate <NSObject>
@optional

/// 即将打开（切换）菜单分组，可在此方法中选中指定行，在此方法中更换数据源内容没有效果
- (void)dropdownMenu:(LXDropdownMenu *)menu willOpenMenuInSection:(NSInteger)section;
/// 已经打开菜单分组，只是切换菜单分组时不会调用此方法
- (void)dropdownMenu:(LXDropdownMenu *)menu didOpenMenuInSection:(NSInteger)section;
/// 即将关闭菜单分组
- (void)dropdownMenu:(LXDropdownMenu *)menu willCloseMenuInSection:(NSInteger)section;
/// 已经关闭菜单分组
- (void)dropdownMenu:(LXDropdownMenu *)menu didCloseMenuInSection:(NSInteger)section;
/// 是否可以选中指定行
- (BOOL)dropdownMenu:(LXDropdownMenu *)menu shouldSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/// 已经选中指定行，适用于当前展开的菜单分组
- (void)dropdownMenu:(LXDropdownMenu *)menu didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
/// 是否可以选中指定行
- (BOOL)dropdownMenu:(LXDropdownMenu *)menu shouldDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
/// 已经取消选中指定行，适用于当前展开的菜单分组
- (void)dropdownMenu:(LXDropdownMenu *)menu didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface LXDropdownMenu : UIView

/// 菜单展开关闭动画时间，默认为 0.25s
@property (nonatomic) IBInspectable double animationDuration;

/// 菜单栏按钮文本字体，默认为 17.0 系统字体
@property (nonatomic) UIFont *barButtonTextFont;
/// 菜单栏按钮标题和图片在普通状态下的颜色，默认为黑色
@property (nonatomic) IBInspectable UIColor *normalColor;
/// 菜单栏按钮标题和图片在选中状态下的颜色，默认使用 tintColor
@property (nonatomic) IBInspectable UIColor *selectedColor;
/// 菜单栏分隔线颜色，默认为 alpha 为 0.1 的黑色
@property (nonatomic) IBInspectable UIColor *separatorColor;

/// 是否隐藏菜单表视图的分隔线，默认不隐藏
@property (nonatomic) IBInspectable BOOL hiddenSeparator;
/// 背景蒙版颜色，默认为 alpha 为 0.5 的黑色
@property (nonatomic) IBInspectable UIColor *dimmingColor;
/// 菜单背景色，默认为白色
@property (nonatomic) IBInspectable UIColor *tableViewBgColor;

/// 菜单是否打开
@property (nonatomic, readonly) BOOL isOpen;
/// 当前已打开的菜单分组，若没有打开的菜单，则该值为 NSNotFound
@property (nonatomic, readonly) NSInteger currentSection;

/// 菜单代理
@property (nullable, nonatomic, weak) IBOutlet id<LXDropdownMenuDelegate> delegate;
/// 菜单数据源
@property (nullable, nonatomic, weak) IBOutlet id<LXDropdownMenuDataSource> dataSource;

/// 根据单元格的 nib 文件注册单元格并指定重用标识符
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;

/// 根据单元格的类注册单元格并指定重用标识符
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

/// 从缓存池获取单元格，若已注册，则无可用单元格时会自动创建注册的单元格
- (nullable __kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

/// 选中指定行，不会触发相关代理方法，只应在菜单即将打开或完全打开后调用
- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 取消选中指定行，不会触发相关代理方法，只应在菜单即将打开或完全打开后调用
- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated;

/// 打开指定的菜单分组，会触发相关代理方法
- (void)openMenuInSection:(NSUInteger)section;

/// 关闭当前打开的菜单分组，会触发相关代理方法
- (void)closeMenu;

@end

NS_ASSUME_NONNULL_END
