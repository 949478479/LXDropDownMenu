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

/// 左侧菜单栏按钮
@property (nonatomic, weak) IBOutlet UIButton *leftBarButton;
/// 中间菜单栏按钮
@property (nonatomic, weak) IBOutlet UIButton *centerBarButton;
/// 右侧菜单栏按钮
@property (nonatomic, weak) IBOutlet UIButton *rightBarButton;
/// 全部菜单栏按钮
@property (nonatomic) IBOutletCollection(UIButton) NSArray *barButtons;

/// 菜单容器视图
@property (nonatomic) IBOutlet YZPullDownMenuWrapperView *menuWrapperView;
/// 菜单表视图
@property (nonatomic) IBOutlet YZPullDownMenuTableView *menuTableView;
/// 菜单背景视图
@property (nonatomic) IBOutlet YZPullDownMenuBackgroundView *menuBackgroundView;

@end

@implementation YZPullDownMenu

#pragma mark - 添加移除菜单视图

- (void)didMoveToWindow
{
    // 菜单栏添加到窗口时，将菜单视图添加到窗口上层，上贴菜单栏，下贴选项卡或屏幕底部，左右紧贴窗口边缘
    if (self.window) {
        self.menuWrapperView.hidden = YES;
        [self.window addSubview:self.menuWrapperView];

        self.menuWrapperView.translatesAutoresizingMaskIntoConstraints = NO;
        id menuView = self.menuWrapperView, bottomGuide = self.lx_viewController.bottomLayoutGuide;
        NSDictionary *views = NSDictionaryOfVariableBindings(self, menuView, bottomGuide);
        NSString *visualFormats[] = { @"H:|[menuView]|", @"V:[self][menuView][bottomGuide]" };
        for (uint i = 0; i < 2; ++i) {
            [NSLayoutConstraint activateConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                     options:kNilOptions
                                                     metrics:nil
                                                       views:views]];
        }
    } else {
        // 菜单栏从窗口移除时，一并移除菜单视图
        [self.menuWrapperView removeFromSuperview];
    }
}

#pragma mark - 设置菜单显示行数

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
        return;
    }

    // 根据被点击的菜单栏按钮获取相应的菜单项
    if (tappedButton == self.leftBarButton) {
        if (self.willOpenLeftMenu) {
            self.menuTableView.items = self.willOpenLeftMenu(self).copy;
        }
    } else if (tappedButton == self.centerBarButton) {
        if (self.willOpenCenterMenu) {
            self.menuTableView.items = self.willOpenCenterMenu(self).copy;
        }
    } else if (tappedButton == self.rightBarButton) {
        if (self.willOpenRightMenu) {
            self.menuTableView.items = self.willOpenRightMenu(self).copy;
        }
    }
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
    }
}

@end
