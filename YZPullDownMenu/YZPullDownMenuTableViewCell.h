//
//  YZPullDownMenuTableViewCell.h
//  YZPullDownMenu_Demo
//
//  Created by 从今以后 on 16/2/20.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZPullDownMenuTableViewCell : UITableViewCell

/// 文本内容
@property (nullable, nonatomic, copy) NSString *text;
/// 文本字体
@property (nullable, nonatomic) UIFont *textFont;
/// 普通状态文本颜色
@property (nullable, nonatomic) UIColor *normalTextColor;
/// 选中状态文本颜色
@property (nullable, nonatomic) UIColor *selectedTextColor;
/// 选中状态背景颜色
@property (nullable, nonatomic) UIColor *selectedBackgroundColor;

@end

NS_ASSUME_NONNULL_END
