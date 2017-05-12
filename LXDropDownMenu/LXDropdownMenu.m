//
//  LXDropdownMenu.m
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXDropdownMenu.h"

@interface _LXDropdownMenuBarSeparatorView : UIView
@end
@implementation _LXDropdownMenuBarSeparatorView
@end

@interface _LXDropdownMenuWrapperView : UIView
@end
@implementation _LXDropdownMenuWrapperView
@end

@interface _LXDropdownMenuDimmingView : UIControl
@end
@implementation _LXDropdownMenuDimmingView
@end

@interface _LXDropdownMenuTableView : UITableView
@end
@implementation _LXDropdownMenuTableView

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if ([delegate isKindOfClass:[LXDropdownMenu class]]) {
        [super setDelegate:delegate];
    }
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    if ([dataSource isKindOfClass:[LXDropdownMenu class]]) {
        [super setDataSource:dataSource];
    }
}

@end

@interface _LXDropdownMenuBarButton : UIButton
@end
@implementation _LXDropdownMenuBarButton

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

- (void)setHighlighted:(BOOL)highlighted
{
    // 去除高亮效果
}

@end

#pragma mark - LXDropdownMenu -

@interface LXDropdownMenu () <UITableViewDataSource, UITableViewDelegate>

/// 菜单是否打开
@property (nonatomic, readwrite) BOOL isOpen;
/// 选中的按钮
@property (nonatomic) UIButton *selectedButton;
/// 即将打开的菜单分组
@property (nonatomic) NSInteger targetSection;
/// 当前打开的菜单分组
@property (nonatomic, readwrite) NSInteger currentSection;

/// 菜单栏按钮数组
@property (nonatomic, copy) NSArray<_LXDropdownMenuBarButton *> *barButtons;
/// 菜单栏分隔线数组
@property (nonatomic, copy) NSArray<_LXDropdownMenuBarSeparatorView *> *barSeparatorViews;

/// 菜单表视图
@property (nonatomic) _LXDropdownMenuTableView *tableView;
/// 菜单容器视图
@property (nonatomic) _LXDropdownMenuWrapperView *wrapperView;
/// 菜单背景视图
@property (nonatomic) _LXDropdownMenuDimmingView *dimmingView;
/// 菜单表视图高度约束
@property (nonatomic) NSLayoutConstraint *tableViewHeightConstraint;

@end

@implementation LXDropdownMenu

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
    _animationDuration = 0.25;
    _targetSection = NSNotFound;
    _currentSection = NSNotFound;
    _barButtonSelectedColor = self.tintColor;
    _barButtonNormalColor = [UIColor blackColor];
    _barButtonTextFont = [UIFont systemFontOfSize:17.0];
    _dimmingColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    _barSeparatorColor = [UIColor colorWithWhite:0.0 alpha:0.1];
}

#pragma mark - 安装菜单栏和菜单

- (void)didMoveToWindow
{
    if (!self.window) {
        return;
    }

    if (self.wrapperView.superview) {
        return;
    }

    [self setupMenuBar];
    [self setupMenuView];
}

- (void)setupMenuBar
{
    [self setupBarButtons];
    [self setupBarSeparator];
}

- (void)setupBarButtons
{
    UIImage *normalImage = [[UIImage imageNamed:@"down_arrow"]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *selectedImage = [[UIImage imageNamed:@"up_arrow"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    NSAssert(self.dataSource, @"尚未设置数据源");
    NSArray *barButtonTitles = [self.dataSource sectionTitlesForDropdownMenu:self];
    NSUInteger numberOfSections = barButtonTitles.count;
    NSAssert(numberOfSections > 0, @"菜单分组标题数量必须大于零");
    NSMutableArray *barButtons = [NSMutableArray arrayWithCapacity:numberOfSections];

    for (NSUInteger i = 0; i < numberOfSections; ++i) {

        _LXDropdownMenuBarButton *barButton = [_LXDropdownMenuBarButton new];
        {
            barButton.tag = i;
            barButton.tintColor = self.barButtonNormalColor;
            barButton.titleLabel.font = self.barButtonTextFont;
            barButton.lx_normalImage = normalImage;
            barButton.lx_normalTitle = barButtonTitles[i];
            barButton.lx_normalTitleColor = self.barButtonNormalColor;
            barButton.lx_selectedImage = selectedImage;
            barButton.lx_selectedTitleColor = self.barButtonSelectedColor;
            [barButton addTarget:self
                          action:@selector(barButtonDidTap:)
                forControlEvents:UIControlEventTouchUpInside];
            barButton.translatesAutoresizingMaskIntoConstraints = NO;
        }

        [self addSubview:barButtons[i] = barButton];

        NSDictionary *views = nil;
        if (i == 0) {
            // 最左侧菜单栏按钮
            views = NSDictionaryOfVariableBindings(barButton);
        } else {
            // 当前菜单栏按钮和它左侧相邻的菜单栏按钮
            UIButton *leftBarButton = barButtons[i - 1];
            views = NSDictionaryOfVariableBindings(leftBarButton, barButton);
        }

        // 菜单栏按钮一律上下紧贴菜单栏
        NSString *visualFormats[2] = { @"V:|[barButton]|" };

        if (i == 0) {
            // 最左侧菜单栏按钮左紧贴菜单栏，如果只有一个菜单栏按钮则右侧紧贴菜单栏右侧
            visualFormats[1] = (numberOfSections > 1) ? @"H:|[barButton]" : @"H:|[barButton]|";
        } else if (i == numberOfSections - 1) {
            // 最右侧的菜单栏按钮右侧紧贴菜单栏，宽度和左侧相邻的菜单栏按钮相等
            visualFormats[1] = @"H:[barButton(leftBarButton)]|";
        } else {
            // 位于中间部分的菜单栏按钮宽度和左侧相邻的菜单栏按钮相等
            visualFormats[1] = @"H:[barButton(leftBarButton)]";
        }

        for (int i = 0; i < 2; ++i) {
            [self addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                     options:kNilOptions
                                                     metrics:nil
                                                       views:views]];
        }
    }

    self.barButtons = barButtons;
}

- (void)setupBarSeparator
{
    NSUInteger barButtonCount = self.barButtons.count;
    NSAssert(barButtonCount > 0, @"菜单栏按钮数量必须大于零");

    // 只有一个菜单栏按钮则不用添加垂直分隔线
    if (barButtonCount == 1) {
        goto label;
    }

    {
        NSMutableArray *separatorViews = [NSMutableArray arrayWithCapacity:barButtonCount - 1];

        // 在菜单栏按钮间添加垂直分隔线
        [self.barButtons enumerateObjectsUsingBlock:^(UIButton *barButton, NSUInteger idx, BOOL *stop) {

            // 最后一个菜单栏按钮
            if (idx == barButtonCount - 1) {
                return;
            }

            _LXDropdownMenuBarSeparatorView *separatorView = [_LXDropdownMenuBarSeparatorView new];
            separatorView.translatesAutoresizingMaskIntoConstraints = NO;
            separatorView.backgroundColor = self.barSeparatorColor;
            [separatorViews addObject:separatorView];
            [self addSubview:separatorView];

            UIButton *rightBarButton = self.barButtons[idx + 1];

            // 分隔线紧贴两侧的菜单栏按钮，分隔线宽度为 1
            NSDictionary *views = NSDictionaryOfVariableBindings(barButton, separatorView, rightBarButton);

            [self addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:[barButton][separatorView(1)][rightBarButton]"
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

        self.barSeparatorViews = separatorViews;
    }

label:
    {
        // 添加菜单栏底部分隔线
        _LXDropdownMenuBarSeparatorView *separatorView = [_LXDropdownMenuBarSeparatorView new];
        separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        separatorView.backgroundColor = self.barSeparatorColor;
        [self addSubview:separatorView];

        NSMutableArray *separatorViews = [NSMutableArray arrayWithArray:self.barSeparatorViews];
        [separatorViews addObject:separatorView];
        self.barSeparatorViews = separatorViews;

        NSDictionary *views = NSDictionaryOfVariableBindings(separatorView);
        NSString *visualFormats[2] = {
            @"H:|[separatorView]|", @"V:[separatorView(1)]|"
        };
        for (int i = 0; i < 2; ++i) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                                         options:kNilOptions
                                                                         metrics:nil
                                                                           views:views]];
        }
    }
}

- (_LXDropdownMenuTableView *)tableView
{
    // 表视图使用懒加载是为了注册单元格时保证能获取到表视图
    if (!_tableView) {
        _tableView = [_LXDropdownMenuTableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    }
    return _tableView;
}

- (void)setupMenuView
{
    // 菜单背景蒙版视图
    _LXDropdownMenuDimmingView *dimmingView = [_LXDropdownMenuDimmingView new];
    dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    dimmingView.backgroundColor = self.dimmingColor;
    [dimmingView addTarget:self
                    action:@selector(handleMenuDimmingViewDidTap)
          forControlEvents:UIControlEventTouchUpInside];
    self.dimmingView = dimmingView;

    // 菜单容器视图，即菜单表视图和菜单蒙版视图的父视图
    _LXDropdownMenuWrapperView *wrapperView = [_LXDropdownMenuWrapperView new];
    wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    wrapperView.hidden = YES;
    self.wrapperView = wrapperView;

    // 获取菜单栏所在的视图控制器
    UIViewController *viewController = self.lx_viewController;
    NSAssert(viewController, @"菜单栏尚未添加到窗口上");
    UIView *viewControllerView = viewController.view, *tableView = self.tableView;
    
    [wrapperView addSubview:dimmingView];
    [wrapperView addSubview:tableView];
    [viewControllerView addSubview:wrapperView];

    id<UILayoutSupport> bottomGuide = viewController.bottomLayoutGuide;
    NSDictionary *views = NSDictionaryOfVariableBindings(self, bottomGuide, wrapperView, tableView, dimmingView);
    NSString *visualFormats[6] = {
        @"V:[self][wrapperView][bottomGuide]",
        @"H:|[wrapperView]|",
        @"V:|[dimmingView]|",
        @"H:|[dimmingView]|",
        @"V:|[tableView]",
        @"H:|[tableView]|",
    };
    for (int i = 0; i < 6; ++i) {
        [viewControllerView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:views]];
    }

    // 通过高度约束控制菜单表视图高度
    NSLayoutConstraint *tableViewHeightConstraint =
    [NSLayoutConstraint constraintWithItem:self.tableView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:0.0];
    [tableView addConstraint:tableViewHeightConstraint];
    self.tableViewHeightConstraint = tableViewHeightConstraint;
}

#pragma mark - 配置菜单外观

- (void)setBarButtonTextFont:(UIFont *)barButtonTextFont
{
    _barButtonTextFont = barButtonTextFont;

    [self.barButtons setValue:barButtonTextFont forKeyPath:@"titleLabel.font"];
}

- (void)setBarButtonNormalColor:(UIColor *)barButtonNormalColor
{
    _barButtonNormalColor = barButtonNormalColor;

    for (UIButton *button in self.barButtons) {
        button.lx_normalTitleColor = barButtonNormalColor;
        button.tintColor = barButtonNormalColor; // 通过 tintColor 来改变菜单栏按钮图片颜色
    }
}

- (void)setBarButtonSelectedColor:(UIColor *)barButtonSelectedColor
{
    _barButtonSelectedColor = barButtonSelectedColor;

    [self.barButtons setValue:barButtonSelectedColor forKey:@"lx_selectedTitleColor"];
}

- (void)setBarSeparatorColor:(UIColor *)barSeparatorColor
{
    _barSeparatorColor = barSeparatorColor;

    [self.barSeparatorViews setValue:barSeparatorColor forKey:@"backgroundColor"];
}

- (void)setDimmingColor:(UIColor *)dimmingColor
{
    _dimmingColor = dimmingColor;

    self.dimmingView.backgroundColor = dimmingColor;
}

#pragma mark - 点击事件处理

- (void)barButtonDidTap:(UIButton *)selectedBtn
{
    if (self.selectedButton == selectedBtn) { // 点击当前已打开的菜单，此时应关闭菜单
        selectedBtn.selected = NO;
        selectedBtn.tintColor = self.barButtonNormalColor;
        self.selectedButton = nil;
        self.targetSection = self.currentSection;
    } else { // 点击新菜单，包括切换菜单的情况
        selectedBtn.selected = YES;
        selectedBtn.tintColor = self.barButtonSelectedColor;
        self.selectedButton.selected = NO;
        self.selectedButton.tintColor = self.barButtonNormalColor;
        self.selectedButton = selectedBtn;
        self.targetSection = selectedBtn.tag;
    }

    if (self.isOpen) {
        self.selectedButton ? [self refreshMenuView] : [self closeMenuView];
    } else {
        [self openMenuView];
    }
}

- (void)handleMenuDimmingViewDidTap
{
    [self barButtonDidTap:self.selectedButton];
}

#pragma mark - 切换菜单状态

- (void)openMenuView
{
    // 准备淡入背景蒙版，并将菜单表视图高度调整为零，为展开动画做准备
    self.dimmingView.alpha = 0.0;
    self.wrapperView.hidden = NO;
    self.tableViewHeightConstraint.constant = 0.0;
    [self.wrapperView layoutIfNeeded];

    self.tableViewHeightConstraint.constant =
    [self.dataSource dropdownMenu:self heightForMenuInSection:self.targetSection];

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [UIView animateWithDuration:self.animationDuration animations:^{

        // 淡入背景蒙版，展开菜单表视图
        self.dimmingView.alpha = 1.0;
        [self.wrapperView layoutIfNeeded];

    } completion:^(BOOL finished) {

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        self.isOpen = YES;
        self.currentSection = self.targetSection;

        if ([self.delegate respondsToSelector:@selector(dropdownMenu:didOpenMenuInSection:)]) {
            [self.delegate dropdownMenu:self didOpenMenuInSection:self.targetSection];
        }
    }];

    [self.tableView reloadData];

    if ([self.delegate respondsToSelector:@selector(dropdownMenu:willOpenMenuInSection:)]) {
        [self.delegate dropdownMenu:self willOpenMenuInSection:self.targetSection];
    }
}

- (void)closeMenuView
{
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:willCloseMenuInSection:)]) {
        [self.delegate dropdownMenu:self willCloseMenuInSection:self.targetSection];
    }

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [UIView animateWithDuration:self.animationDuration animations:^{

        self.dimmingView.alpha = 0.0;
        self.tableViewHeightConstraint.constant = 0.0;
        [self.wrapperView layoutIfNeeded];

    } completion:^(BOOL finished) {

        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

        self.isOpen = NO;
        self.wrapperView.hidden = YES;
        self.currentSection = NSNotFound;

        if ([self.delegate respondsToSelector:@selector(dropdownMenu:didCloseMenuInSection:)]) {
            [self.delegate dropdownMenu:self didCloseMenuInSection:self.targetSection];
        }
    }];
}

- (void)refreshMenuView
{
    self.tableViewHeightConstraint.constant =
    [self.dataSource dropdownMenu:self heightForMenuInSection:self.targetSection];

    [self.tableView reloadData];

    if ([self.delegate respondsToSelector:@selector(dropdownMenu:willOpenMenuInSection:)]) {
        [self.delegate dropdownMenu:self willOpenMenuInSection:self.targetSection];
    }

    self.currentSection = self.targetSection;
}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 避免表视图添加到窗口上时的数据源刷新操作
    if (self.targetSection == NSNotFound) {
        return 0;
    }
    return [self.dataSource dropdownMenu:self numberOfRowsInSection:self.targetSection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.targetSection];
    return [self.dataSource dropdownMenu:self cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.targetSection];
    return [self.dataSource dropdownMenu:self heightForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:shouldSelectRowAtIndexPath:)]) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
        if ([self.delegate dropdownMenu:self shouldSelectRowAtIndexPath:_indexPath]) {
            return indexPath;
        }
        return nil;
    }
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:shouldDeselectRowAtIndexPath:)]) {
        NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
        if ([self.delegate dropdownMenu:self shouldDeselectRowAtIndexPath:_indexPath]) {
            return indexPath;
        }
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:didSelectRowAtIndexPath:)]) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
        [self.delegate dropdownMenu:self didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(dropdownMenu:didDeselectRowAtIndexPath:)]) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:self.currentSection];
        [self.delegate dropdownMenu:self didDeselectRowAtIndexPath:indexPath];
    }
}

#pragma mark - 公共接口

- (void)registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier
{
    [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier
{
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (__kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [self.tableView dequeueReusableCellWithIdentifier:identifier];
}

- (void)selectRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];

    // 选中指定行，注意这里指定 UITableViewScrollPositionNone 会导致没有滚动而不是最小滚动，详见文档
    [self.tableView selectRowAtIndexPath:indexPath
                                    animated:animated
                              scrollPosition:UITableViewScrollPositionNone];
    
    // 将指定行以最小滚动距离滚入屏幕
    [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:animated];
}

- (void)deselectRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
}

- (void)openMenuInSection:(NSUInteger)section
{
    NSAssert(self.window, @"菜单栏尚未添加到窗口上");
    [self barButtonDidTap:self.barButtons[section]];
}

- (void)closeMenu
{
    if (self.isOpen) {
        [self handleMenuDimmingViewDidTap];
    }
}

- (void)closeMenuWithoutAnimation
{
    if (self.isOpen) {
        NSTimeInterval duration = self.animationDuration;
        self.animationDuration = 0;
        [self handleMenuDimmingViewDidTap];
        self.animationDuration = duration;
    }
}

@end
