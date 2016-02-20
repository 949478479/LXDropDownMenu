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

#pragma mark - __YZPullDownMenuBackgroundView -

@interface __YZPullDownMenuBackgroundView : UIView
@end
@implementation __YZPullDownMenuBackgroundView
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
@property (nonatomic, readwrite) NSUInteger currentMenuSection;
/// 菜单内容
@property (nonatomic, copy) NSArray<NSString *> *menuItems;

/// 菜单栏按钮
@property (nonatomic) IBOutletCollection(UIButton) NSArray<UIButton *> *menuBarButtons;
/// 菜单背景视图
@property (nonatomic) IBOutlet __YZPullDownMenuBackgroundView *menuBackgroundView;
/// 菜单容器视图
@property (nonatomic) IBOutlet __YZPullDownMenuWrapperView *menuWrapperView;
/// 菜单表视图
@property (nonatomic) IBOutlet __YZPullDownMenuTableView *menuTableView;
/// 菜单表视图高度约束
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *menuTableViewHeightConstraint;

@end

@implementation YZPullDownMenu

//- (void)dealloc
//{
//    LXLog(@"%@ delloc", self);
//}

#pragma mark - 添加移除菜单视图

- (void)didMoveToWindow
{
    // 菜单栏添加到窗口时，且菜单视图尚未添加，则添加菜单视图
    if (self.window && !self.menuWrapperView.superview) {

        UIViewController *vc = self.lx_viewController;

        self.menuWrapperView.hidden = YES;
        [vc.view addSubview:self.menuWrapperView];

        // 上贴菜单栏，下贴选项卡或屏幕底部，左右紧贴窗口边缘
        id menuView = self.menuWrapperView, bottomGuide = vc.bottomLayoutGuide;
        NSDictionary *views = NSDictionaryOfVariableBindings(self, menuView, bottomGuide);
        NSString *visualFormats[] = { @"H:|[menuView]|", @"V:[self][menuView][bottomGuide]" };
        for (uint i = 0; i < 2; ++i) {
            [NSLayoutConstraint activateConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                     options:kNilOptions
                                                     metrics:nil
                                                       views:views]];
        }
    }
}

#pragma mark - 设置菜单外观

- (void)setRowHeight:(CGFloat)rowHeight
{
    _rowHeight = rowHeight;

    self.menuTableView.rowHeight = rowHeight;
    self.menuTableViewHeightConstraint.constant = rowHeight * MIN(self.menuItems.count, self.maxVisibleRows);
}

- (void)setMaxVisibleRows:(NSUInteger)maxVisibleRows
{
    _maxVisibleRows = maxVisibleRows;

    self.menuTableViewHeightConstraint.constant = self.rowHeight * MIN(self.menuItems.count, self.maxVisibleRows);
}

- (void)setMenuItems:(NSArray<NSString *> *)menuItems
{
    _menuItems = menuItems.copy;

    self.menuTableViewHeightConstraint.constant = self.rowHeight * MIN(self.menuItems.count, self.maxVisibleRows);
}

- (void)setButtonTextFont:(UIFont *)buttonTextFont
{
    _buttonTextFont = buttonTextFont;

    for (UIButton *button in self.menuBarButtons) {
        button.titleLabel.font = buttonTextFont;
    }
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;

    // 让所有菜单栏按钮标题和图片显示普通状态的颜色
    self.tintColor = normalColor;
    [self.menuBarButtons makeObjectsPerformSelector:@selector(setLx_normalTitleColor:)
                                         withObject:normalColor];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;

    [self.menuBarButtons makeObjectsPerformSelector:@selector(setLx_selectedTitleColor:)
                                         withObject:selectedColor];
}

#pragma mark - 菜单栏按钮点击处理

- (IBAction)handleBarButtonDidTapped:(UIButton *)tappedButton
{
    self.userInteractionEnabled = NO;

    [self configureMenuItemsForTappedButton:tappedButton];

    [self switchMenuStateForTappedButton:tappedButton completion:^{
        self.userInteractionEnabled = YES;
    }];
}

- (void)configureMenuItemsForTappedButton:(UIButton *)tappedButton
{
    // 被点击的菜单栏按钮已是选中状态，此时应该关闭菜单，而不是配置菜单项
    if (tappedButton.selected) {
        self.menuItems = nil;
        self.currentMenuSection = NSNotFound;
        return;
    }

    [self.menuBarButtons enumerateObjectsUsingBlock:^(UIButton *buuton, NSUInteger idx, BOOL *stop) {
        if (buuton == tappedButton) {
            *stop = YES;
            self.currentMenuSection = idx;
            self.menuItems = [self.delegate pullDownMenu:self itemsForMenuInSection:idx];
        }
    }];
}

- (void)switchMenuStateForTappedButton:(UIButton *)tappedButton completion:(void (^)(void))completion
{
    if (self.isOpen) {
        if (!tappedButton.selected) { // 点击了其它菜单栏按钮，刷新菜单内容
            [self.menuTableView reloadData];
            if ([self.delegate respondsToSelector:@selector(pullDownMenu:willOpenMenuInSection:)]) {
                [self.delegate pullDownMenu:self willOpenMenuInSection:self.currentMenuSection];
            }
            completion();
        } else { // 点击当前菜单栏按钮，关闭菜单
            CGFloat height = self.menuTableViewHeightConstraint.constant;
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.menuBackgroundView.alpha = 0;
                self.menuTableViewHeightConstraint.constant = 0;
                [self.menuWrapperView layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.isOpen = NO;
                self.menuWrapperView.hidden = YES;
                self.menuTableViewHeightConstraint.constant = height;
                completion();
            }];
        }
    } else { // 菜单由关闭状态被打开，刷新菜单内容
        self.menuWrapperView.hidden = NO;
        self.menuBackgroundView.alpha = 0;
        CGFloat height = self.menuTableViewHeightConstraint.constant;
        self.menuTableViewHeightConstraint.constant = 0;
        [self.menuWrapperView layoutIfNeeded];

        [UIView animateWithDuration:self.animationDuration animations:^{
            self.menuBackgroundView.alpha = 1;
            self.menuTableViewHeightConstraint.constant = height;
            [self.menuWrapperView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.isOpen = YES;
            completion();
        }];

        [self.menuTableView reloadData];
        if ([self.delegate respondsToSelector:@selector(pullDownMenu:willOpenMenuInSection:)]) {
            [self.delegate pullDownMenu:self willOpenMenuInSection:self.currentMenuSection];
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

- (IBAction)menuBackgroundViewDidTapped:(UITapGestureRecognizer *)sender
{
    for (UIButton *button in self.menuBarButtons) {
        if (button.selected) {
            [self handleBarButtonDidTapped:button];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
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

    cell.textLabel.text = self.menuItems[indexPath.row];
    cell.textLabel.font = self.itemTextFont;
    cell.textLabel.textColor = self.normalColor;
    cell.textLabel.highlightedTextColor = self.selectedColor;
    cell.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;

    return cell;
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

@end
