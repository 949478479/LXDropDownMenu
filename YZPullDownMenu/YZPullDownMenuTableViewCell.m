//
//  YZPullDownMenuTableViewCell.m
//
//  Created by 从今以后 on 16/2/20.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "YZPullDownMenuTableViewCell.h"

@implementation YZPullDownMenuTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [UIView new];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text.copy;

    self.textLabel.text = self.text;
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;

    self.textLabel.font = textFont;
}

- (void)setNormalTextColor:(UIColor *)normalTextColor
{
    _normalTextColor = normalTextColor;

    self.textLabel.textColor = normalTextColor;
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor
{
    _selectedTextColor = selectedTextColor;

    self.textLabel.highlightedTextColor = selectedTextColor;
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    _selectedBackgroundColor = selectedBackgroundColor;
    
    self.selectedBackgroundView.backgroundColor = selectedBackgroundColor;
}

@end
