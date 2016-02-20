//
//  LXKeyboardSpacingView.m
//
//  Created by 从今以后 on 15/10/8.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "UIScreen+LXExtension.h"
#import "LXKeyboardSpacingView.h"
#import "NSNotificationCenter+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXKeyboardSpacingView ()
@property (nonatomic) id keyboardObserver;
@end

@implementation LXKeyboardSpacingView

- (void)updateConstraints
{
	NSAssert(self.heightConstraint != nil, @"未连接高度约束。。。");
	[super updateConstraints];
}

- (void)didMoveToSuperview
{
	if (self.superview) { // 添加到父视图

		__weak typeof(self) weakSelf = self;

		self.keyboardObserver =
		[NSNotificationCenter lx_observeKeyboardFrameChangeWithBlock:^(NSNotification *note) {

			__strong typeof(weakSelf) strongSelf = weakSelf;

			CGRect keyboardEndFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
			CGFloat keyboardOriginY = CGRectGetMinY(keyboardEndFrame);
			CGFloat keyboardHeight  = CGRectGetHeight(keyboardEndFrame);

			/*
			 如果主动注销响应者收回键盘，例如 endEditing: 或者 resignFirstResponder，
			 keyboardOriginY 值为 keyboardHeight + LXScreenSize().height，而并非 LXScreenSize().height。
			 这种情况下，如下算法会算出负数，出现约束歧义：
				CGFloat constant = LXScreenSize().height - keyboardOriginY;
				weakSelf.heightConstraint.constant = constant;
			 */
			CGFloat constant = (keyboardOriginY < [UIScreen lx_size].height) ? keyboardHeight : 0;
			strongSelf.heightConstraint.constant = constant;

			NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
			[UIView animateWithDuration:duration animations:^{
				[strongSelf.superview layoutIfNeeded];
			}];
		}];

	} else { // 从父视图移除
		[[NSNotificationCenter defaultCenter] removeObserver:self.keyboardObserver];
	}
}

@end

NS_ASSUME_NONNULL_END
