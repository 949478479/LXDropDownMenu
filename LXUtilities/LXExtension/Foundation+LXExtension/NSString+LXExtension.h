//
//  NSString+LXExtension.h
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LXExtension)

///--------------
/// @name 文本范围
///--------------

- (CGSize)lx_sizeWithBoundingSize:(CGSize)size font:(UIFont *)font;

///--------------
/// @name 表单验证
///--------------

- (BOOL)lx_isEmail;
- (BOOL)lx_isPhoneNumber;

///--------------
/// @name 加密处理
///--------------

- (NSString *)lx_MD5;
- (NSString *)lx_SHA1;
- (NSString *)lx_SHA224;
- (NSString *)lx_SHA256;
- (NSString *)lx_SHA384;
- (NSString *)lx_SHA512;

///-----------
/// @name 其他
///-----------

/// 将非字母、数字、下划线的字符替换为下划线。开头的数字也会被替换为下划线。
- (NSString *)lx_alphanumericString;

@end

NS_ASSUME_NONNULL_END
