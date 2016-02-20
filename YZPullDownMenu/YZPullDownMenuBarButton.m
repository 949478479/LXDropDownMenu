//
//  YZPullDownMenuBarButton.m
//
//  Created by 从今以后 on 16/2/19.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "YZPullDownMenuBarButton.h"

@implementation YZPullDownMenuBarButton

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
