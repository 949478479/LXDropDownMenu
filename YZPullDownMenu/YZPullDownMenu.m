//
//  YZPullDownMenu.m
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LXUtilities.h"
#import "YZPullDownMenu.h"

#pragma mark - __YZPullDownMenuBarSeparatorView -

@interface __YZPullDownMenuBarSeparatorView : UIView
@end
@implementation __YZPullDownMenuBarSeparatorView
@end

#pragma mark - __YZPullDownMenuWrapperView -

@interface __YZPullDownMenuWrapperView : UIView
@end
@implementation __YZPullDownMenuWrapperView
@end

#pragma mark - __YZPullDownMenuDimmingView -

@interface __YZPullDownMenuDimmingView : UIView
@end
@implementation __YZPullDownMenuDimmingView
@end

#pragma mark - __YZPullDownMenuTableViewBackgroundView -

@interface __YZPullDownMenuTableViewBackgroundView : UIView
@end
@implementation __YZPullDownMenuTableViewBackgroundView
@end

#pragma mark - __YZPullDownMenuTableView -

@interface __YZPullDownMenuTableView : UITableView
@end
@implementation __YZPullDownMenuTableView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 触摸点位于菜单表视图的内容范围内则让菜单表视图处理
    CGRect contentRect = self.bounds;
    contentRect.size.height = MIN(self.contentSize.height, contentRect.size.height);
    if (CGRectContainsPoint(contentRect, point)) {
        return self;
    }
    return nil;
}

@end

#pragma mark - __YZPullDownMenuBarButton -

@interface __YZPullDownMenuBarButton : UIButton
@end
@implementation __YZPullDownMenuBarButton

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

#pragma mark - YZPullDownMenu -

@interface YZPullDownMenu () <UITableViewDataSource, UITableViewDelegate>

/// 菜单是否打开
@property (nonatomic, readwrite) BOOL isOpen;
/// 当前打开的菜单分组
@property (nonatomic, readwrite) NSUInteger currentSection;
/// 菜单项标题
@property (nonatomic, copy) NSArray<NSString *> *menuItemTitles;

/// 菜单栏按钮数组
@property (nonatomic) NSArray<__YZPullDownMenuBarButton *> *menuBarButtons;
/// 菜单栏分隔线数组
@property (nonatomic) NSArray<__YZPullDownMenuBarSeparatorView *> *menuBarSeparatorViews;

/// 菜单容器视图
@property (nonatomic) __YZPullDownMenuWrapperView *menuWrapperView;
/// 菜单背景视图
@property (nonatomic, weak) __YZPullDownMenuDimmingView *menuDimmingView;
/// 菜单表视图
@property (nonatomic, weak) __YZPullDownMenuTableView *menuTableView;
/// 菜单表视图高度约束
@property (nonatomic, weak) NSLayoutConstraint *menuTableViewHeightConstraint;                                                       

@end

@implementation YZPullDownMenu
@synthesize barButtonTextFont = _barButtonTextFont;

- (void)dealloc
{
    LXLog(@"%@ delloc", self);
}

#pragma mark - 添加菜单视图

- (void)didMoveToWindow
{
    [self addMenuViewToViewControllerViewIfNeeded];
}

- (void)addMenuViewToViewControllerViewIfNeeded
{
    // 从窗口移除
    if (!self.window) {
        return;
    }

    // 已经添加到了视图控制器视图上
    if (self.menuWrapperView.superview) {
        return;
    }

    [self setupMenuBar];
    [self setupMenuView];

    [self setupMenuBarAppearance];

    UIViewController *viewController = self.lx_viewController;

    self.menuWrapperView.hidden = YES;
    [viewController.view addSubview:self.menuWrapperView];

    // 上贴菜单栏，下贴选项卡或屏幕底部，左右紧贴窗口边缘
    id menuView = self.menuWrapperView, bottomGuide = viewController.bottomLayoutGuide;
    NSDictionary *views = NSDictionaryOfVariableBindings(self, menuView, bottomGuide);
    NSString *visualFormats[] = { @"H:|[menuView]|", @"V:[self][menuView][bottomGuide]" };
    for (uint i = 0; i < 2; ++i) {
        [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                                        options:kNilOptions
                                                                        metrics:nil
                                                                          views:views]];
    }
}

#pragma mark - 安装菜单栏和菜单

- (void)setupMenuView
{
    // 菜单表视图
    __YZPullDownMenuTableView *menuTableView = [__YZPullDownMenuTableView new];
    menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    menuTableView.translatesAutoresizingMaskIntoConstraints = NO;
    menuTableView.backgroundColor = [UIColor whiteColor];
    menuTableView.dataSource = self;
    menuTableView.delegate = self;
    self.menuTableView = menuTableView;

    // 菜单背景蒙版视图
    __YZPullDownMenuDimmingView *menuDimmingView = [__YZPullDownMenuDimmingView new];
    menuDimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    menuDimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    [menuDimmingView addGestureRecognizer:
     [[UITapGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(handleMenuDimmingViewDidTap:)]];
    self.menuDimmingView = menuDimmingView;

    // 菜单容器视图，即菜单表视图和菜单蒙版视图的父视图
    __YZPullDownMenuWrapperView *menuWrapperView = [__YZPullDownMenuWrapperView new];
    menuWrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    [menuWrapperView addSubview:menuDimmingView];
    [menuWrapperView addSubview:menuTableView];
    self.menuWrapperView = menuWrapperView;

    // 蒙版视图四边紧贴容器视图，表视图上、左、右三边紧贴容器视图
    NSDictionary *views = NSDictionaryOfVariableBindings(menuTableView, menuDimmingView);
    NSString *visualFormats[] = {
        @"H:|[menuDimmingView]|", @"V:|[menuDimmingView]|",
        @"H:|[menuTableView]|", @"V:|[menuTableView]"
    };
    size_t count = sizeof(visualFormats) / sizeof(NSString *);
    for (size_t i = 0; i < count; ++i) {
        [menuWrapperView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:views]];
    }

    // 通过高度约束控制表视图高度
    NSLayoutConstraint *menuTableViewHeightConstraint =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:[menuTableView(233)]"
                                            options:kNilOptions
                                            metrics:nil
                                              views:views][0];
    [menuTableView addConstraint:menuTableViewHeightConstraint];
    self.menuTableViewHeightConstraint = menuTableViewHeightConstraint;
}

- (void)setupMenuBar
{
    [self setupMenuBarButtons];
    [self setupMenuBarVerticalSeparatorView];
    [self setupMenuBarBottomSeparatorView];
}

- (void)setupMenuBarButtons
{
    UIImage *normalImage = [[UIImage imageNamed:@"down_arrow"]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *selectedImage = [[UIImage imageNamed:@"up_arrow"]
                              imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    NSArray *barButtonTitles = [self.delegate sectionTitlesForPullDownMenu:self];
    NSUInteger numberOfSections = [self.delegate numberOfSectionsInPullDownMenu:self];
    NSMutableArray *menuBarButtons = [NSMutableArray arrayWithCapacity:numberOfSections];

    for (NSUInteger i = 0; i < numberOfSections; ++i) {

        __YZPullDownMenuBarButton *barButton = [__YZPullDownMenuBarButton new];
        {
            barButton.lx_normalImage = normalImage;
            barButton.lx_selectedImage = selectedImage;
            barButton.lx_normalTitle = barButtonTitles[i];
            barButton.translatesAutoresizingMaskIntoConstraints = NO;

            [barButton addTarget:self
                          action:@selector(handleBarButtonDidTap:)
                forControlEvents:UIControlEventTouchUpInside];
        }

        menuBarButtons[i] = barButton;
        [self addSubview:barButton];

        NSDictionary *views = nil;
        if (i == 0) {
            views = NSDictionaryOfVariableBindings(barButton);
        } else {
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

        for (uint i = 0; i < 2; ++i) {
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

        UIView *separatorView = [UIView new];
        separatorView.backgroundColor = self.separatorColor;
        separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:separatorView];
        [separators addObject:separatorView];

        UIButton *leftBarButton = barButton;
        UIButton *rightBarButton = self.menuBarButtons[idx + 1];

        // 分隔线紧贴两侧的菜单栏按钮，分隔线宽度为 1
        NSDictionary *views = NSDictionaryOfVariableBindings(leftBarButton, separatorView, rightBarButton);
        [self addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[leftBarButton][separatorView(1)][rightBarButton]"
                                                 options:kNilOptions
                                                 metrics:nil
                                                   views:views]];
        // 分隔线高度为菜单栏高度的 0.7 倍
        [self addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:0.7
                                                          constant:0.0]];
        // 分隔线垂直居中
        [self addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
    }];

    self.menuBarSeparatorViews = separators;
}

- (void)setupMenuBarBottomSeparatorView
{
    // 添加菜单栏底部分隔线
    UIView *horizontalSeparatorView = [UIView new];
    horizontalSeparatorView.backgroundColor = self.separatorColor;
    horizontalSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:horizontalSeparatorView];

    NSMutableArray *separators = [NSMutableArray arrayWithArray:self.menuBarSeparatorViews];
    [separators addObject:horizontalSeparatorView];
    self.menuBarSeparatorViews = separators;

    NSDictionary *views = NSDictionaryOfVariableBindings(horizontalSeparatorView);
    NSString *visualFormats[] = {
        @"H:|[horizontalSeparatorView]|", @"V:[horizontalSeparatorView(1)]|"
    };
    for (uint i = 0; i < 2; ++i) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
    }
}

#pragma mark - 配置菜单外观

- (UIFont *)itemTextFont
{
    return _itemTextFont ?: [UIFont systemFontOfSize:17.0];
}

- (void)setBarButtonTextFont:(UIFont *)barButtonTextFont
{
    _barButtonTextFont = barButtonTextFont;

    [self.menuBarButtons setValue:barButtonTextFont forKeyPath:@"titleLabel.font"];
}

- (UIFont *)barButtonTextFont
{
    return _barButtonTextFont ?: [UIFont systemFontOfSize:17.0];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;

    self.tintColor = self.normalColor;
    [self.menuBarButtons setValue:normalColor forKey:@"lx_normalTitleColor"];
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

- (void)setupMenuViewAppearance
{
    self.menuTableView.rowHeight = self.rowHeight;
    CGFloat menuTableViewHeight = self.rowHeight * MIN(self.menuItemTitles.count, self.maxVisibleRows);
    self.menuTableViewHeightConstraint.constant = menuTableViewHeight;
}

- (void)setupMenuBarAppearance
{
    self.tintColor = self.normalColor; // 让所有菜单栏按钮标题和图片显示普通状态的颜色

    for (UIView *subview in self.subviews) {
        if ([subview isMemberOfClass:[__YZPullDownMenuBarButton class]]) {
            // 设置菜单栏按钮标题颜色以及字体
            __YZPullDownMenuBarButton *barButton = (__YZPullDownMenuBarButton *)subview;
            barButton.titleLabel.font = self.barButtonTextFont;
            barButton.lx_normalTitleColor = self.normalColor;
            barButton.lx_selectedTitleColor = self.selectedColor;
        } else if ([subview isMemberOfClass:[__YZPullDownMenuBarSeparatorView class]]) {
            // 设置菜单栏分隔线颜色
            __YZPullDownMenuBarSeparatorView *separatorView = (__YZPullDownMenuBarSeparatorView *)subview;
            separatorView.backgroundColor = self.separatorColor;
        }
    }
}

#pragma mark - 菜单栏按钮点击处理

- (void)handleBarButtonDidTap:(UIButton *)tappedButton
{
    // 在菜单动画结束前禁止交互
    self.userInteractionEnabled = NO;
    self.menuWrapperView.userInteractionEnabled = NO;

    [self configureMenuItemsForTappedButton:tappedButton];
    [self switchMenuStateForTappedButton:tappedButton completion:^{

        self.userInteractionEnabled = YES;
        self.menuWrapperView.userInteractionEnabled = YES;
    }];
}

- (void)configureMenuItemsForTappedButton:(UIButton *)tappedButton
{
    // 被点击的菜单栏按钮已是选中状态，此时应该关闭菜单，而不是配置菜单项
    if (tappedButton.selected) {
        self.menuItemTitles = nil;
        return;
    }

    // 找到被点击的菜单栏按钮，向数据源请求对应菜单所需的菜单内容
    [self.menuBarButtons enumerateObjectsUsingBlock:^(UIButton *buuton, NSUInteger idx, BOOL *stop) {
        if (buuton == tappedButton) {
            *stop = YES;
            self.currentSection = idx;
            self.menuItemTitles = [self.delegate pullDownMenu:self itemTitlesForMenuInSection:idx];
        }
    }];
}

- (void)switchMenuStateForTappedButton:(UIButton *)tappedButton completion:(void (^)(void))completion
{
    if (self.isOpen) {

        if (!tappedButton.selected) { // 点击了其它菜单栏按钮，刷新菜单内容

            [self setupMenuViewAppearance];
            [self.menuTableView reloadData];

            if ([self.delegate respondsToSelector:@selector(pullDownMenu:willOpenMenuInSection:)]) {
                [self.delegate pullDownMenu:self willOpenMenuInSection:self.currentSection];
            }

            completion();

        } else { // 点击当前菜单栏按钮，关闭菜单

            CGFloat height = self.menuTableViewHeightConstraint.constant;

            [UIView animateWithDuration:self.animationDuration animations:^{

                self.menuDimmingView.alpha = 0.0;
                self.menuTableViewHeightConstraint.constant = 0.0;
                [self.menuWrapperView layoutIfNeeded];

            } completion:^(BOOL finished) {

                self.isOpen = NO;
                self.menuWrapperView.hidden = YES;
                self.menuTableViewHeightConstraint.constant = height;

                if ([self.delegate respondsToSelector:@selector(pullDownMenu:didCloseMenuInSection:)]) {
                    [self.delegate pullDownMenu:self didCloseMenuInSection:self.currentSection];
                }
                self.currentSection = NSNotFound;

                completion();
            }];
        }

    } else { // 菜单由关闭状态被打开，刷新菜单内容

        [self setupMenuViewAppearance];

        self.menuWrapperView.hidden = NO;
        self.menuDimmingView.alpha = 0.0;
        CGFloat height = self.menuTableViewHeightConstraint.constant;
        self.menuTableViewHeightConstraint.constant = 0.0;
        [self.menuWrapperView layoutIfNeeded];

        [UIView animateWithDuration:self.animationDuration animations:^{

            self.menuDimmingView.alpha = 1.0;
            self.menuTableViewHeightConstraint.constant = height;
            [self.menuWrapperView layoutIfNeeded];

        } completion:^(BOOL finished) {

            self.isOpen = YES;
            completion();
        }];

        [self.menuTableView reloadData];

        if ([self.delegate respondsToSelector:@selector(pullDownMenu:willOpenMenuInSection:)]) {
            [self.delegate pullDownMenu:self willOpenMenuInSection:self.currentSection];
        }
    }

    // 将被点击按钮设为选中状态，取消其他按钮的选中状态
    for (UIButton *button in self.menuBarButtons) {
        if (button == tappedButton) {
            button.selected = !button.selected;
        } else {
            button.selected = NO;
        }
        button.tintColor = button.selected ? self.selectedColor : self.normalColor;
    }
}

#pragma mark - 菜单背景蒙版点击处理

- (void)handleMenuDimmingViewDidTap:(UITapGestureRecognizer *)sender
{
    for (UIButton *button in self.menuBarButtons) {
        if (button.selected) {
            [self handleBarButtonDidTap:button];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItemTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const reuseIdentifier = @"UITableViewCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
        cell.selectedBackgroundView = [UIView new];
    }

    cell.textLabel.text = self.menuItemTitles[indexPath.row];
    cell.textLabel.font = self.itemTextFont;
    cell.textLabel.textColor = self.normalColor;
    cell.textLabel.highlightedTextColor = self.selectedColor;
    cell.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;

    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 不允许重复选中同一行
    if ([[tableView indexPathsForSelectedRows].firstObject isEqual:indexPath]) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(pullDownMenu:didSelectItemAtIndexPath:)]) {
        [self.menuBarButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            if (button.selected) {
                *stop = YES;
                NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:idx];
                [self.delegate pullDownMenu:self didSelectItemAtIndexPath:_indexPath];
            }
        }];
    }
}

#pragma mark - 公共接口

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *_indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];

    // 选中指定行，注意这里指定 UITableViewScrollPositionNone 会导致没有滚动而不是最小滚动，详见文档
    [self.menuTableView selectRowAtIndexPath:_indexPath
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    
    // 将指定行以最小滚动距离滚入屏幕
    [self.menuTableView scrollToRowAtIndexPath:_indexPath
                              atScrollPosition:UITableViewScrollPositionNone
                                      animated:NO];
}

- (void)openMenuInSection:(NSUInteger)section
{
    [self handleBarButtonDidTap:self.menuBarButtons[section]];
}

- (void)closeMenu
{
    [self handleMenuDimmingViewDidTap:nil];
}

@end
