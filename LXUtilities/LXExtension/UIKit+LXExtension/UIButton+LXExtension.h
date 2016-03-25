//
//  UIButton+LXExtension.h
//
//  Created by 从今以后 on 15/9/21.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LXExtension)

@property (nullable, nonatomic, copy) NSString *lx_normalTitle;
@property (nullable, nonatomic, copy) NSString *lx_disabledTitle;
@property (nullable, nonatomic, copy) NSString *lx_selectedTitle;
@property (nullable, nonatomic, copy) NSString *lx_highlightedTitle;

@property (nullable, nonatomic, copy) UIColor *lx_normalTitleColor;
@property (nullable, nonatomic, copy) UIColor *lx_disabledTitleColor;
@property (nullable, nonatomic, copy) UIColor *lx_selectedTitleColor;
@property (nullable, nonatomic, copy) UIColor *lx_highlightedTitleColor;

@property (nullable, nonatomic) UIImage *lx_normalImage;
@property (nullable, nonatomic) UIImage *lx_disabledImage;
@property (nullable, nonatomic) UIImage *lx_selectedImage;
@property (nullable, nonatomic) UIImage *lx_highlightedImage;

@property (nullable, nonatomic) UIImage *lx_normalBackgroundImage;
@property (nullable, nonatomic) UIImage *lx_disabledBackgroundImage;
@property (nullable, nonatomic) UIImage *lx_selectedBackgroundImage;
@property (nullable, nonatomic) UIImage *lx_highlightedBackgroundImage;

@end

NS_ASSUME_NONNULL_END