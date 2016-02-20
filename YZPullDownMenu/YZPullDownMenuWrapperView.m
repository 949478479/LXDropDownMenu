//
//  YZPullDownMenuWrapperView.m
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "YZPullDownMenuWrapperView.h"

@implementation YZPullDownMenuWrapperView

#pragma mark - 构造方法

+ (instancetype)menuWrapperView
{
    UINib *nib = [UINib nibWithNibName:@"YZPullDownMenu" bundle:nil];
    NSArray *views = [nib instantiateWithOwner:nil options:nil];
    for (UIView *view in views) {
        if ([view isMemberOfClass:self]) {
            return (YZPullDownMenuWrapperView *)view;
        }
    }
    NSAssert(NO, @"实例化失败");
    return nil;
}

@end
