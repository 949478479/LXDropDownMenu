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
/// 返回索引对应的菜单的菜单项
- (NSArray<NSString *> *)pullDownMenu:(YZPullDownMenu *)menu itemsForMenuAtIndex:(NSUInteger)index;

@optional
- (void)pullDownMenu:(YZPullDownMenu *)menu willOpenMenuAtIndex:(NSUInteger)index;

@end

@interface YZPullDownMenu : UIView <XXNibBridge>

/// 菜单是否打开
@property (nonatomic, readonly) BOOL isOpen;
/// 当前打开的菜单的索引，若没有打开的菜单，则索引为 NSNotFound
@property (nonatomic, readonly) NSUInteger currentMenuIndex;

/// 菜单单元格行高
@property (nonatomic) IBInspectable CGFloat rowHeight;
/// 菜单最大显示行数
@property (nonatomic) IBInspectable NSUInteger maxVisibleRows;
/// 动画持续时间
@property (nonatomic) IBInspectable double animationDuration;

/// 下拉菜单代理
@property (nonatomic, weak) IBOutlet id<YZPullDownMenuDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
