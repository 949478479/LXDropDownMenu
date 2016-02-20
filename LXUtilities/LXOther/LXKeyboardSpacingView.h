//
//  LXKeyboardSpacingView.h
//
//  Created by 从今以后 on 15/10/8.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

/// 该视图的高度会随键盘高度变化，键盘收回时为零，键盘弹出时为键盘高度。
/// 在 IB 中将高度约束的值设置为零，并连接 heightConstraint 属性即可。注意不要设置其他会影响高度的约束。
@interface LXKeyboardSpacingView : UIView
@property (nonnull, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@end

