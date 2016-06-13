//
//  LXDropDownMenu.m
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXDropDownMenu.h"

@interface __LXDropDownMenuBarSeparatorView : UIView
@end
@implementation __LXDropDownMenuBarSeparatorView
@end

@interface __LXDropDownMenuWrapperView : UIView
@end
@implementation __LXDropDownMenuWrapperView
@end

@interface __LXDropDownMenuDimmingView : UIControl
@end
@implementation __LXDropDownMenuDimmingView
@end

@interface __LXDropDownMenuTableView : UITableView
@end
@implementation __LXDropDownMenuTableView
@end

@interface __LXDropDownMenuBarButton : UIButton
@end
@implementation __LXDropDownMenuBarButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    // image.width + title.width == button.width 即 contentRect.width 减去两侧间距
    // image.originX + image.width == title.originX
    // image 和 title 与 button 的间距相同，二者相邻且居中
    CGRect titleRect = [super titleRectForContentRect:contentRect];

    // margin 为 title 与 button 右侧的间距
    CGFloat margin = contentRect.size.width - (titleRect.origin.x + titleRect.size.width);

    // x 坐标为 margin 的位置是 title 与 button 左侧间距为 margin 的位置，然后进一步左移 2 点
    titleRect.origin.x = margin - 2;

    return titleRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect imageRect = [super imageRectForContentRect:contentRect];

    // margin 为 image 与 button 左侧的间距
    CGFloat margin = imageRect.origin.x;

    // x 坐标为 CGRectGetMaxX(contentRect) - margin 的位置是 image 与 button 右侧间距为 margin 的位置
    // 再减去 image 宽度即是原点 x 坐标,然后进一步右移 2 点，这样 title 和 image 之间就有 4 点间距了，比较合适
    imageRect.origin.x = CGRectGetMaxX(contentRect) - margin - CGRectGetWidth(imageRect) + 2;

    return imageRect;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];

    [self sizeToFit]; // 设置完 title 后调整尺寸
}

- (void)setHighlighted:(BOOL)highlighted
{
    // 去除高亮效果
}

@end

#pragma mark - LXDropDownMenu -

@interface LXDropDownMenu () <UITableViewDataSource, UITableViewDelegate>

/// 菜单是否打开
@property (nonatomic, readwrite) BOOL isOpen;
/// 当前打开的菜单分组
@property (nonatomic, readwrite) NSInteger currentSection;

/// 菜单栏按钮数组
@property (nonatomic, copy) NSArray<__LXDropDownMenuBarButton *> *menuBarButtons;
/// 菜单栏分隔线数组
@property (nonatomic, copy) NSArray<__LXDropDownMenuBarSeparatorView *> *menuBarSeparatorViews;

/// 菜单表视图
@property (nonatomic) __LXDropDownMenuTableView *menuTableView;
/// 菜单容器视图
@property (nonatomic) __LXDropDownMenuWrapperView *menuWrapperView;
/// 菜单背景视图
@property (nonatomic, weak) __LXDropDownMenuDimmingView *menuDimmingView;
/// 菜单表视图高度约束
@property (nonatomic, weak) NSLayoutConstraint *menuTableViewHeightConstraint;                                                       

@end

@implementation LXDropDownMenu

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _currentSection = NSNotFound;
    _animationDuration = 0.25;
    _selectedColor = self.tintColor;
    _normalColor = [UIColor blackColor];
    _tableViewBgColor = [UIColor whiteColor];
    _barButtonTextFont = [UIFont systemFontOfSize:17.0];
    _separatorColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    _dimmingColor = [UIColor colorWithWhite:0.0 alpha:0.5];
}

#pragma mark - 安装菜单栏和菜单

- (void)didMoveToWindow
{
    // 从窗口移除时直接返回
    if (!self.window) {
        return;
    }

    // 已经添加到视图控制器视图上时直接返回
    if (self.menuWrapperView.superview) {
        return;
    }

    [self setupMenuBar];
    [self setupMenuView];
}

- (void)setupMenuBar
{
    [self setupMenuBarButtons];
    [self setupMenuBarVerticalSeparatorView];
    [self setupMenuBarBottomSeparatorView];
    [self setupMenuBarAppearance];
}

- (void)setupMenuBarButtons
{
    UIImage *normalImage = [[UIImage imageNamed:@"down_arrow"]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *selectedImage = [[UIImage imageNamed:@"up_arrow"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    NSArray *barButtonTitles = [self.dataSource sectionTitlesForDropDownMenu:self];
    NSUInteger numberOfSections = barButtonTitles.count;
    NSAssert(numberOfSections > 0, @"菜单分组标题数量必须大于零");
    NSMutableArray *menuBarButtons = [NSMutableArray arrayWithCapacity:numberOfSections];

    for (NSUInteger i = 0; i < numberOfSections; ++i) {

        __LXDropDownMenuBarButton *barButton = [__LXDropDownMenuBarButton new];
        {
            barButton.lx_normalImage = normalImage;
            barButton.lx_selectedImage = selectedImage;
            barButton.lx_normalTitle = barButtonTitles[i];
            barButton.translatesAutoresizingMaskIntoConstraints = NO;
            [barButton addTarget:self
                          action:@selector(handleBarButtonDidTap:)
                forControlEvents:UIControlEventTouchUpInside];
        }

        [self addSubview:barButton];
        menuBarButtons[i] = barButton;

        NSDictionary *views = nil;
        if (i == 0) {
            // 最左侧菜单栏按钮
            views = NSDictionaryOfVariableBindings(barButton);
        } else {
            // 当前菜单栏按钮和它左侧相邻的菜单栏按钮
            UIButton *previousBarButton = menuBarButtons[i - 1];
            views = NSDictionaryOfVariableBindings(previousBarButton, barButton);
        }

        // 菜单栏按钮一律上下紧贴菜单栏
        NSString *visualFormats[2] = { @"V:|[barButton]|" };

        if (i == 0) {
            // 最左侧菜单栏按钮左紧贴菜单栏，如果只有一个菜单栏按钮则右侧紧贴菜单栏右侧
            visualFormats[1] = (numberOfSections > 1) ? @"H:|[barButton]" : @"H:|[barButton]|";
        } else if (i == numberOfSections - 1) {
            // 最右侧的菜单栏按钮右侧紧贴菜单栏，宽度和上一个菜单栏按钮相等
            visualFormats[1] = @"H:[barButton(previousBarButton)]|";
        } else {
            // 位于中间部分的菜单栏按钮宽度和上一个菜单栏按钮相等
            visualFormats[1] = @"H:[barButton(previousBarButton)]";
        }

        for (int i = 0; i < 2; ++i) {
            [self addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                     options:kNilOptions
                                                     metrics:nil
                                                       views:views]];
        }
    }

    self.menuBarButtons = menuBarButtons;
}

- (void)setupMenuBarVerticalSeparatorView
{
    NSUInteger barButtonCount = self.menuBarButtons.count;

    NSAssert(barButtonCount > 0, @"菜单栏按钮数量必须大于零");

    // 只有一个菜单栏按钮则不用添加垂直分隔线
    if (barButtonCount == 1) {
        return;
    }

    NSMutableArray *separators = [NSMutableArray arrayWithCapacity:barButtonCount - 1];

    // 在菜单栏按钮间添加垂直分隔线
    [self.menuBarButtons enumerateObjectsUsingBlock:^(UIButton *barButton, NSUInteger idx, BOOL *stop) {

        // 最后一个菜单栏按钮
        if (idx == barButtonCount - 1) {
            return;
        }

        __LXDropDownMenuBarSeparatorView *separatorView = [__LXDropDownMenuBarSeparatorView new];
        separatorView.backgroundColor = self.separatorColor;
        separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [separators addObject:separatorView];
        [self addSubview:separatorView];

        // 当前菜单栏按钮和它右侧相邻的菜单栏按钮
        UIButton *currentBarButton = barButton;
        UIButton *nextBarButton = self.menuBarButtons[idx + 1];

        // 分隔线紧贴两侧的菜单栏按钮，分隔线宽度为 1
        NSDictionary *views = NSDictionaryOfVariableBindings(currentBarButton, separatorView, nextBarButton);

        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[currentBarButton][separatorView(1)][nextBarButton]"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:views]];

        // 分隔线高度为菜单栏高度的 0.7 倍，垂直居中
        CGFloat multipliers[2] = { 0.7, 1.0 };
        NSLayoutAttribute attributes[2] = { NSLayoutAttributeHeight, NSLayoutAttributeCenterY };
        for (int i = 0; i < 2; ++i) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                             attribute:attributes[i]
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:attributes[i]
                                                            multiplier:multipliers[i]
                                                              constant:0.0]];
        }
    }];

    self.menuBarSeparatorViews = separators;
}

- (void)setupMenuBarBottomSeparatorView
{
    // 添加菜单栏底部分隔线
    __LXDropDownMenuBarSeparatorView *horizontalSeparatorView = [__LXDropDownMenuBarSeparatorView new];
    horizontalSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    horizontalSeparatorView.backgroundColor = self.separatorColor;
    [self addSubview:horizontalSeparatorView];

    NSMutableArray *separators = [NSMutableArray arrayWithArray:self.menuBarSeparatorViews];
    [separators addObject:horizontalSeparatorView];
    self.menuBarSeparatorViews = separators;

    NSDictionary *views = NSDictionaryOfVariableBindings(horizontalSeparatorView);
    NSString *visualFormats[2] = {
        @"H:|[horizontalSeparatorView]|", @"V:[horizontalSeparatorView(1)]|"
    };
    for (int i = 0; i < 2; ++i) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
    }
}

- (__LXDropDownMenuTableView *)menuTableView
{
    // 表视图使用懒加载是为了注册单元格时保证能获取到表视图
    if (!_menuTableView) {
        _menuTableView = [__LXDropDownMenuTableView new];
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        _menuTableView.backgroundColor = self.tableViewBgColor;
        _menuTableView.separatorStyle = self.hiddenSeparator ? 0 : 1;
        _menuTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _menuTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    }
    return _menuTableView;
}

- (void)setupMenuView
{
    // 菜单背景蒙版视图
    __LXDropDownMenuDimmingView *menuDimmingView = [__LXDropDownMenuDimmingView new];
    menuDimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    menuDimmingView.backgroundColor = self.dimmingColor;
    [menuDimmingView addTarget:self
                        action:@selector(handleMenuDimmingViewDidTap)
              forControlEvents:UIControlEventTouchUpInside];
    self.menuDimmingView = menuDimmingView;

    // 菜单容器视图，即菜单表视图和菜单蒙版视图的父视图
    __LXDropDownMenuWrapperView *menuWrapperView = [__LXDropDownMenuWrapperView new];
    menuWrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    menuWrapperView.hidden = YES;
    self.menuWrapperView = menuWrapperView;

    // 获取菜单栏所在的视图控制器
    UIViewController *viewController = self.lx_viewController;
    NSAssert(viewController, @"菜单栏尚未添加到窗口上");
    UIView *viewControllerView = viewController.view, *menuTableView = self.menuTableView;
    
    [menuWrapperView addSubview:menuDimmingView];
    [menuWrapperView addSubview:menuTableView];
    [viewControllerView addSubview:menuWrapperView];

    id<UILayoutSupport> bottomGuide = viewController.bottomLayoutGuide;
    NSDictionary *views = NSDictionaryOfVariableBindings(self, bottomGuide, menuWrapperView, menuTableView, menuDimmingView);
    NSString *visualFormats[6] = {
        @"V:[self][menuWrapperView][bottomGuide]", // 包装视图顶部紧贴菜单栏，底部紧贴选项卡顶部或视图控制器视图底部
        @"H:|[menuWrapperView]|", // 包装视图左右紧贴视图控制器视图边缘
        @"V:|[menuDimmingView]|", // 背景蒙版视图上下紧贴包装视图边缘
        @"H:|[menuDimmingView]|", // 背景蒙版视图左右紧贴包装视图边缘
        @"V:|[menuTableView]",    // 菜单表视图顶部紧贴包装视图顶部
        @"H:|[menuTableView]|",   // 菜单表视图左右紧贴包装视图边缘
    };
    for (int i = 0; i < 6; ++i) {
        [viewControllerView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:views]];
    }

    // 通过高度约束控制菜单表视图高度
    NSLayoutConstraint *menuTableViewHeightConstraint =
    [NSLayoutConstraint constraintWithItem:self.menuTableView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:233.0];
    [menuTableView addConstraint:menuTableViewHeightConstraint];
    self.menuTableViewHeightConstraint = menuTableViewHeightConstraint;
}

#pragma mark - 配置菜单外观

- (void)setBarButtonTextFont:(UIFont *)barButtonTextFont
{
    _barButtonTextFont = barButtonTextFont;

    [self.menuBarButtons setValue:barButtonTextFont forKeyPath:@"titleLabel.font"];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;

    for (UIButton *button in self.menuBarButtons) {
        button.lx_normalTitleColor = normalColor;
        button.tintColor = normalColor; // 通过 tintColor 来改变菜单栏按钮图片颜色
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;

    [self.menuBarButtons setValue:selectedColor forKey:@"lx_selectedTitleColor"];
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;

    [self.menuBarSeparatorViews setValue:separatorColor forKey:@"backgroundColor"];
}

- (void)setDimmingColor:(UIColor *)dimmingColor
{
    _dimmingColor = dimmingColor;

    self.menuDimmingView.backgroundColor = dimmingColor;
}

- (void)setTableViewBgColor:(UIColor *)tableViewBgColor
{
    _tableViewBgColor = tableViewBgColor;

    _menuTableView.backgroundColor = tableViewBgColor;
}

- (void)setHiddenSeparator:(BOOL)hiddenSeparator
{
    _hiddenSeparator = hiddenSeparator;

    _menuTableView.separatorStyle = hiddenSeparator ? 0 : 1;
}

- (void)setupMenuBarAppearance
{
    // 设置背景蒙版视图颜色
    self.menuDimmingView.backgroundColor = self.dimmingColor;

    // 设置菜单栏按钮标题和图片的颜色以及字体
    for (UIButton *button in self.menuBarButtons) {
        button.tintColor = self.normalColor;
        button.titleLabel.font = self.barButtonTextFont;
        button.lx_normalTitleColor = self.normalColor;
        button.lx_selectedTitleColor = self.selectedColor;
    }

    // 设置菜单栏分隔线颜色
    for (UIView *separator in self.menuBarSeparatorViews) {
        separator.backgroundColor = self.separatorColor;
    }
}

- (void)setupMenuViewHeight
{
    CGFloat menuHeight = [self.dataSource dropDownMenu:self
                                heightForMenuInSection:self.currentSection];
    self.menuTableViewHeightConstraint.constant = menuHeight;
}

#pragma mark - 点击事件处理

- (void)handleBarButtonDidTap:(UIButton *)tappedButton
{
    [self switchMwnuSectionForTappedButton:tappedButton];
    [self switchMenuViewStateForTappedButton:tappedButton];
    [self switchMenuButtonStateForTappedButton:tappedButton];
}

- (void)handleMenuDimmingViewDidTap
{
    // 模拟按钮点击来关闭当前打开的菜单分组
    [self handleBarButtonDidTap:self.menuBarButtons[self.currentSection]];
}

#pragma mark - 切换菜单状态

- (void)switchMwnuSectionForTappedButton:(UIButton *)tappedButton
{
    // 被点击的按钮未被选中，说明打开了新的菜单分组，遍历所有菜单栏按钮找到该按钮索引，将该索引更新为当前菜单分组
    if (!tappedButton.selected) {
        [self.menuBarButtons enumerateObjectsUsingBlock:^(UIButton *buuton, NSUInteger idx, BOOL *stop) {
            if (buuton == tappedButton) {
                *stop = YES;
                self.currentSection = idx;
            }
        }];
    }
    NSAssert(self.currentSection != NSNotFound, @"无法确定当前菜单分组");
}

- (void)switchMenuViewStateForTappedButton:(UIButton *)tappedButton
{
    if (self.isOpen) {
        if (tappedButton.selected) {
            [self closeMenuView];
        } else {
            [self switchMenuView];
        }
    } else {
        [self openMenuView];
    }
}

- (void)switchMenuButtonStateForTappedButton:(UIButton *)tappedButton
{
    for (UIButton *button in self.menuBarButtons) {
        // 切换被点击按钮的选中状态，取消其他按钮的选中状态
        if (button == tappedButton) {
            button.selected = !button.selected;
        } else {
            button.selected = NO;
        }
        // 通过 tintColor 改变按钮图片颜色
        button.tintColor = button.selected ? self.selectedColor : self.normalColor;
    }
}

- (void)openMenuView
{
    // 准备淡入背景蒙版，并将菜单表视图高度调整为零，为展开动画做准备
    self.menuDimmingView.alpha = 0.0;
    self.menuWrapperView.hidden = NO;
    self.menuTableViewHeightConstraint.constant = 0.0;
    [self.menuWrapperView layoutIfNeeded];

    CGFloat menuHeight = [self.dataSource dropDownMenu:self
                                heightForMenuInSection:self.currentSection];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [UIView animateWithDuration:self.animationDuration animations:^{

        // 淡入背景蒙版，展开菜单表视图
        self.menuDimmingView.alpha = 1.0;
        self.menuTableViewHeightConstraint.constant = menuHeight;
        [self.menuWrapperView layoutIfNeeded];

    } completion:^(BOOL finished) {

        self.isOpen = YES;

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        if ([self.delegate respondsToSelector:@selector(dropDownMenu:didOpenMenuInSection:)]) {
            [self.delegate dropDownMenu:self didOpenMenuInSection:self.currentSection];
        }
    }];

    [self.menuTableView reloadData];

    if ([self.delegate respondsToSelector:@selector(dropDownMenu:willOpenMenuInSection:)]) {
        [self.delegate dropDownMenu:self willOpenMenuInSection:self.currentSection];
    }
}

- (void)closeMenuView
{
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:willCloseMenuInSection:)]) {
        [self.delegate dropDownMenu:self willCloseMenuInSection:self.currentSection];
    }

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [UIView animateWithDuration:self.animationDuration animations:^{

        self.menuDimmingView.alpha = 0.0;
        self.menuTableViewHeightConstraint.constant = 0.0;
        [self.menuWrapperView layoutIfNeeded];

    } completion:^(BOOL finished) {

        self.isOpen = NO;
        self.menuWrapperView.hidden = YES;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        NSInteger currentSection = self.currentSection;
        self.currentSection = NSNotFound;

        if ([self.delegate respondsToSelector:@selector(dropDownMenu:didCloseMenuInSection:)]) {
            [self.delegate dropDownMenu:self didCloseMenuInSection:currentSection];
        }
    }];
}

- (void)switchMenuView
{
    CGFloat menuHeight = [self.dataSource dropDownMenu:self
                                heightForMenuInSection:self.currentSection];
    self.menuTableViewHeightConstraint.constant = menuHeight;

    [self.menuTableView reloadData];

    if ([self.delegate respondsToSelector:@selector(dropDownMenu:willOpenMenuInSection:)]) {
        [self.delegate dropDownMenu:self willOpenMenuInSection:self.currentSection];
    }
}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 避免表视图添加到窗口上时的数据源刷新操作
    if (self.currentSection == NSNotFound) {
        return 0;
    }
    return [self.dataSource dropDownMenu:self numberOfRowsInSection:self.currentSection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
    return [self.dataSource dropDownMenu:self cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
    return [self.dataSource dropDownMenu:self heightForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:shouldSelectRowAtIndexPath:)]) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
        if ([self.delegate dropDownMenu:self shouldSelectRowAtIndexPath:_indexPath]) {
            return indexPath;
        }
        return nil;
    }
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:shouldDeselectRowAtIndexPath:)]) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
        if ([self.delegate dropDownMenu:self shouldDeselectRowAtIndexPath:_indexPath]) {
            return indexPath;
        }
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:didSelectRowAtIndexPath:)]) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
        [self.delegate dropDownMenu:self didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:didDeselectRowAtIndexPath:)]) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
        [self.delegate dropDownMenu:self didDeselectRowAtIndexPath:indexPath];
    }
}

#pragma mark - 公共接口

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
    [self.menuTableView registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    [self.menuTableView registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [self.menuTableView dequeueReusableCellWithIdentifier:identifier];
}

- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

    // 选中指定行，注意这里指定 UITableViewScrollPositionNone 会导致没有滚动而不是最小滚动，详见文档
    [self.menuTableView selectRowAtIndexPath:indexPath
                                    animated:animated
                              scrollPosition:UITableViewScrollPositionNone];
    
    // 将指定行以最小滚动距离滚入屏幕
    [self.menuTableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:animated];
}

- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.menuTableView deselectRowAtIndexPath:indexPath animated:animated];
}

- (void)openMenuInSection:(NSUInteger)section
{
    NSAssert(self.window, @"菜单栏尚未添加到窗口上");
    [self handleBarButtonDidTap:self.menuBarButtons[section]];
}

- (void)closeMenu
{
    [self handleMenuDimmingViewDidTap];
}

@end
