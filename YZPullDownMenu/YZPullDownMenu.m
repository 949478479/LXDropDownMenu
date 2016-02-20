//
//  YZPullDownMenu.m
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "LXUtilities.h"
#import "YZPullDownMenu.h"
#import "YZPullDownMenuTableView.h"
#import "YZPullDownMenuWrapperView.h"
#import "YZPullDownMenuBackgroundView.h"

@interface __YZPullDownMenuBarSeparatorView : UIView
@end
@implementation __YZPullDownMenuBarSeparatorView
@end


@interface YZPullDownMenu ()

/// 菜单是否打开
@property (nonatomic, readwrite) BOOL isOpen;
/// 当前打开的菜单的索引
@property (nonatomic, readwrite) NSUInteger currentMenuIndex;

/// 菜单栏按钮
@property (nonatomic) IBOutletCollection(UIButton) NSArray<UIButton *> *barButtons;
/// 菜单容器视图
@property (nonatomic) IBOutlet YZPullDownMenuWrapperView *menuWrapperView;
/// 菜单表视图
@property (nonatomic) IBOutlet YZPullDownMenuTableView *menuTableView;
/// 菜单背景视图
@property (nonatomic) IBOutlet YZPullDownMenuBackgroundView *menuBackgroundView;

@end

@implementation YZPullDownMenu

- (void)dealloc
{
    LXLog(@"%@ delloc", self);
}

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

#pragma mark - 设置菜单样式

- (void)setRowHeight:(CGFloat)rowHeight
{
    _rowHeight = rowHeight;

    self.menuTableView.rowHeight = rowHeight;
}

- (void)setMaxVisibleRows:(NSUInteger)maxVisibleRows
{
    _maxVisibleRows = maxVisibleRows;

    self.menuTableView.maxVisibleRows = maxVisibleRows;
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;

    // 让所有菜单栏按钮标题和图片显示普通状态的颜色
    self.tintColor = normalColor;

    self.menuTableView.normalTextColor = normalColor;

    [self.barButtons makeObjectsPerformSelector:@selector(setLx_normalTitleColor:)
                                     withObject:normalColor];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;

    self.menuTableView.selectedTextColor = selectedColor;

    [self.barButtons makeObjectsPerformSelector:@selector(setLx_selectedTitleColor:)
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
        self.menuTableView.items = nil;
        self.currentMenuIndex = NSNotFound;
        return;
    }

    [self.barButtons enumerateObjectsUsingBlock:^(UIButton *buuton, NSUInteger idx, BOOL *stop) {
        if (buuton == tappedButton) {
            *stop = YES;
            self.currentMenuIndex = idx;
            self.menuTableView.items = [self.delegate pullDownMenu:self itemsForMenuAtIndex:idx];
        }
    }];
}

- (void)switchMenuStateForTappedButton:(UIButton *)tappedButton completion:(void (^)(void))completion
{
    if (self.isOpen) {
        if (!tappedButton.selected) {
            // 点击了其它菜单栏按钮，刷新菜单内容
            [self.menuTableView reloadData];
            completion();
        } else {
            // 点击当前菜单栏按钮，关闭菜单
            CGFloat height = self.menuTableView.heightConstraint.constant;
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.menuBackgroundView.alpha = 0;
                self.menuTableView.heightConstraint.constant = 0;
                [self.menuWrapperView layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.isOpen = NO;
                self.menuWrapperView.hidden = YES;
                self.menuTableView.heightConstraint.constant = height;
                completion();
            }];
        }
    } else {
        // 菜单由关闭状态被打开，刷新菜单内容
        [self.menuTableView reloadData];

        // 将表视图展开关闭的动画延迟一个运行循环执行，否则动画效果会很难看
        dispatch_async(dispatch_get_main_queue(), ^{

            self.menuWrapperView.hidden = NO;
            self.menuBackgroundView.alpha = 0;
            CGFloat height = self.menuTableView.heightConstraint.constant;
            self.menuTableView.heightConstraint.constant = 0;
            [self.menuWrapperView layoutIfNeeded];

            [UIView animateWithDuration:self.animationDuration animations:^{
                self.menuBackgroundView.alpha = 1;
                self.menuTableView.heightConstraint.constant = height;
                [self.menuWrapperView layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.isOpen = YES;
                completion();
            }];
        });
    }

    // 将被点击按钮设为选中状态，取消其他按钮的选中状态
    for (UIButton *button in self.barButtons) {
        if (button == tappedButton) {
            button.selected = !button.selected;
        } else {
            button.selected = NO;
        }
        button.tintColor = button.selected ? self.selectedColor : self.normalColor;
    }
}

@end
