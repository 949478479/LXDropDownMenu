//
//  YZPullDownMenu.h
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YZPullDownMenu;

NS_ASSUME_NONNULL_BEGIN


@protocol YZPullDownMenuDataSource <NSObject>
@required

/// 返回菜单分组数量
- (NSInteger)numberOfSectionsInPullDownMenu:(YZPullDownMenu *)menu;

/// 返回菜单分组标题
- (NSArray<NSString *> *)sectionTitlesForPullDownMenu:(YZPullDownMenu *)menu;

/// 返回相应菜单分组中的单元格数量
- (NSInteger)pullDownMenu:(YZPullDownMenu *)menu numberOfRowsInSection:(NSInteger)section;

/// 返回相应菜单分组中相应行的单元格
- (UITableViewCell *)pullDownMenu:(YZPullDownMenu *)menu cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/// 返回相应菜单分组的菜单高度
- (CGFloat)pullDownMenu:(YZPullDownMenu *)menu heightForMenuInSection:(NSInteger)section;

/// 返回相应菜单分组中相应行的行高
- (CGFloat)pullDownMenu:(YZPullDownMenu *)menu heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol YZPullDownMenuDelegate <NSObject>
@optional

/// 即将打开菜单分组
- (void)pullDownMenu:(YZPullDownMenu *)menu willOpenMenuInSection:(NSInteger)section;
/// 菜单分组已经关闭
- (void)pullDownMenu:(YZPullDownMenu *)menu didCloseMenuInSection:(NSInteger)section;
/// 选中菜单项
- (void)pullDownMenu:(YZPullDownMenu *)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface YZPullDownMenu : UIView

/// 菜单展开关闭动画时间
@property (nonatomic) IBInspectable double animationDuration;
/// 菜单栏按钮文本字体,默认为 17.0 系统 字体
@property (null_resettable, nonatomic) UIFont *barButtonTextFont;
/// 菜单栏按钮标题和图片在普通状态下的颜色
@property (nullable, nonatomic) IBInspectable UIColor *normalColor;
/// 菜单栏按钮标题和图片在选中状态下的颜色
@property (nullable, nonatomic) IBInspectable UIColor *selectedColor;
/// 菜单栏分隔线颜色
@property (nullable, nonatomic) IBInspectable UIColor *separatorColor;

/// 菜单是否打开
@property (nonatomic, readonly) BOOL isOpen;
/// 当前打开的菜单分组，若没有打开的菜单，则该值为 NSNotFound
@property (nonatomic, readonly) NSInteger currentSection;

/// 菜单代理
@property (nullable, nonatomic, weak) IBOutlet id<YZPullDownMenuDelegate> delegate;
/// 菜单数据源
@property (nullable, nonatomic, weak) IBOutlet id<YZPullDownMenuDataSource> dataSource;


/// 根据单元格的 nib 文件注册单元格并指定重用标识符
- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;

/// 根据单元格的类注册单元格并指定重用标识符
- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier;

/// 从缓存池获取单元格，若已注册，则无可用单元格时会自动创建注册的单元格
- (nullable __kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;


/// 选中指定的菜单项，不会触发相关代理方法
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath;

/// 打开指定的菜单分组，会触发相关代理方法
- (void)openMenuInSection:(NSUInteger)section;

/// 关闭当前打开的菜单分组，会触发相关代理方法
- (void)closeMenu;

@end

NS_ASSUME_NONNULL_END
