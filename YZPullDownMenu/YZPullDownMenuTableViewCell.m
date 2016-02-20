//
//  YZPullDownMenuTableViewCell.m
//  YZPullDownMenu_Demo
//
//  Created by 从今以后 on 16/2/20.
//  Copyright © 2016年 从今以后. All rights reserved.
//

#import "YZPullDownMenuTableViewCell.h"

@implementation YZPullDownMenuTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.textLabel.textColor = selected ? self.selectedTextColor : self.normalTextColor;
}

@end
