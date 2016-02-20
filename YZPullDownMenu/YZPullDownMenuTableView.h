//
//  YZPullDownMenuTableView.h
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZPullDownMenuTableView : UITableView

/// 菜单项普通状态文本颜色
@property (nonatomic) UIColor *normalTextColor;
/// 菜单项选中状态文本颜色
@property (nonatomic) UIColor *selectedTextColor;
/// 菜单最大显示行数
@property (nonatomic) NSUInteger maxVisibleRows;
/// 菜单内容
@property (nullable, nonatomic, copy) NSArray<NSString *> *items;
/// 菜单高度约束
@property (nonatomic, weak, readonly) NSLayoutConstraint *heightConstraint;

@end

NS_ASSUME_NONNULL_END
