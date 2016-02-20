//
//  UIImage+LXExtension.h
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LXExtension)

/// 图片纵横比例。
@property (nonatomic, readonly) CGFloat lx_aspectRatio;

///--------------
/// @name 图片缩放
///--------------

#pragma mark - 图片缩放 -

/**
 *  缩放图片到目标尺寸。
 *
 *  @param targetSize  目标尺寸。若模式为 AspectFit，则最终图片可能比目标尺寸小。
 *  @param contentMode 缩放模式。有效模式为：
					   @c UIViewContentModeScaleToFill
					   @c UIViewContentModeScaleAspectFit
					   @c UIViewContentModeScaleAspectFill
 */
- (UIImage *)lx_resizedImageForTargetSize:(CGSize)targetSize
							  contentMode:(UIViewContentMode)contentMode;

/// 图片在 @c UIViewContentModeScaleAspectFit 模式下填充 @c boundingRect 时的 frame。
- (CGRect)lx_rectForScaleAspectFitInsideBoundingRect:(CGRect)boundingRect;

///--------------
/// @name 图片裁剪
///--------------

#pragma mark - 图片裁剪 -

/**
 *  生成带边框的圆形图片，图片最终尺寸为裁剪尺寸加上两倍边框宽度。
 *
 *  @param cropArea    相对于图片的正方形裁剪区域。
 *  @param borderWidth 边框宽度，传入 @c 0 则无边框。
 *  @param borderColor 边框颜色，传入 @c nil 则为不透明黑色。
 */
- (UIImage *)lx_roundedImageForCropArea:(CGRect)cropArea
							borderWidth:(CGFloat)borderWidth
							borderColor:(nullable UIColor *)borderColor;

///--------------
/// @name 创建图片
///--------------

#pragma mark - 创建图片 -

/**
 *  使用 @c [UIImage imageWithContentsOfFile:] 创建图片。
 *
 *  @param path 图片相对于 @c mainBundle 的路径，包含扩展名。
 */
+ (nullable instancetype)lx_imageWithContentsOfFile:(NSString *)path NS_SWIFT_NAME(init(lx_contentsOfFile:));

/// 使用 @c [UIImage imageNamed:] 创建 @c UIImageRenderingModeAlwaysOriginal 渲染模式的图片。
+ (nullable instancetype)lx_originalRenderingImageNamed:(NSString *)name NS_SWIFT_NAME(init(originalRenderingImageNamed:));

/// 生成纯色图片。仅当 @c color 的 @c alpha 为 @c 1 且 @c cornerRadius 为 @c 0 时，图片才是完全不透明的。
+ (nullable instancetype)lx_imageWithColor:(UIColor *)color
                                      size:(CGSize)size
                              cornerRadius:(CGFloat)cornerRadius NS_SWIFT_NAME(init(color:size:cornerRadius:));

///-----------------
/// @name 获取像素颜色
///-----------------

#pragma mark - 获取像素颜色 -

/// 获取图片指定位置像素颜色，单位是点。
- (UIColor *)lx_pixelColorAtPosition:(CGPoint)position;

@end

NS_ASSUME_NONNULL_END
