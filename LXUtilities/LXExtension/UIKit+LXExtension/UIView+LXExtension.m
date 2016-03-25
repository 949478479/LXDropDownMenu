//
//  UIView+LXExtension.m
//
//  Created by 从今以后 on 15/9/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "UIView+LXExtension.h"
#import "CALayer+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIView (LXExtension)

#pragma mark - 几何布局 -

#pragma mark size

- (void)setLx_size:(CGSize)lx_size
{
    CGRect frame = self.frame;
    frame.size = lx_size;
    self.frame = frame;
}

- (CGSize)lx_size
{
    return self.frame.size;
}

- (void)setLx_width:(CGFloat)lx_width
{
    CGRect frame = self.frame;
    frame.size.width = lx_width;
    self.frame = frame;
}

- (CGFloat)lx_width
{
    return self.frame.size.height;
}

- (void)setLx_height:(CGFloat)lx_height
{
    CGRect frame = self.frame;
    frame.size.height = lx_height;
    self.frame = frame;
}

- (CGFloat)lx_height
{
    return self.frame.size.height;
}

#pragma mark origin

- (void)setLx_origin:(CGPoint)lx_origin
{
    CGRect frame = self.frame;
    frame.origin = lx_origin;
    self.frame = frame;
}

- (CGPoint)lx_origin
{
    return self.frame.origin;
}

- (void)setLx_originX:(CGFloat)lx_originX
{
    CGRect frame = self.frame;
    frame.origin.x = lx_originX;
    self.frame = frame;
}

- (CGFloat)lx_originX
{
    return self.frame.origin.x;
}

- (void)setLx_originY:(CGFloat)lx_originY
{
    CGRect frame = self.frame;
    frame.origin.y = lx_originY;
    self.frame = frame;
}

- (CGFloat)lx_originY
{
    return self.frame.origin.y;
}

#pragma mark center

- (void)setLx_centerX:(CGFloat)lx_centerX
{
	self.center = (CGPoint){lx_centerX, self.center.y};
}

- (CGFloat)lx_centerX
{
    return self.center.x;
}

- (void)setLx_centerY:(CGFloat)lx_centerY
{
	self.center = (CGPoint){self.center.x, lx_centerY};
}

- (CGFloat)lx_centerY
{
    return self.center.y;
}

#pragma mark - 图层 -

#pragma mark 图层圆角

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

#pragma mark 边框宽度

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

#pragma mark 边框颜色

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setBorderColor:(nullable UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (nullable UIColor *)borderColor
{
    CGColorRef color = self.layer.borderColor;
    return color ? [UIColor colorWithCGColor:color] : nil;
}

#pragma mark 添加图层

- (void)lx_addSublayer:(CALayer *)layer
{
    [self.layer addSublayer:layer];
}

#pragma mark - 视图控制器 -

- (nullable __kindof UIViewController *)lx_viewController
{
	UIResponder *responder = self.nextResponder;

	for (Class cls = [UIViewController class]; responder && ![responder isKindOfClass:cls];) {
		responder = responder.nextResponder;
	}

	return (UIViewController * _Nullable)responder;
}

- (nullable __kindof UITabBarController *)lx_tabBarController
{
	UIViewController *vc = self.lx_viewController;

	if ([vc isKindOfClass:[UITabBarController class]]) {
		return (UITabBarController * _Nullable)vc;
	}
	return vc.tabBarController;
}

- (nullable __kindof UISplitViewController *)lx_splitViewController
{
	UIViewController *vc = self.lx_viewController;

	if ([vc isKindOfClass:[UISplitViewController class]]) {
		return (UISplitViewController * _Nullable)vc;
	}
	return vc.splitViewController;
}

- (nullable __kindof UINavigationController *)lx_navigationController
{
	UIViewController *vc = self.lx_viewController;

	if ([vc isKindOfClass:[UINavigationController class]]) {
		return (UINavigationController * _Nullable)vc;
	}
	return vc.navigationController;
}

#pragma mark - xib -

+ (UINib *)lx_nib
{
    return [UINib nibWithNibName:NSStringFromClass(self) bundle:nil];
}

+ (NSString *)lx_nibName
{
    return NSStringFromClass(self);
}

+ (instancetype)lx_instantiateFromNib
{
    return [self lx_instantiateFromNibWithOwner:nil options:nil];
}

+ (instancetype)lx_instantiateFromNibWithOwner:(nullable id)ownerOrNil
                                       options:(nullable NSDictionary *)optionsOrNil
{
    NSArray *views = [self.lx_nib instantiateWithOwner:ownerOrNil options:optionsOrNil];
    for (UIView *view in views) {
        if ([view isMemberOfClass:self]) {
            return view;
        }
    }
    NSAssert(NO, @"%@.xib 中未找到对应的 %@", NSStringFromClass(self), NSStringFromClass(self));
    return nil;
}

#pragma mark - 动画 -

- (void)setLx_paused:(BOOL)lx_paused
{
	self.layer.lx_paused = lx_paused;
}

- (BOOL)lx_paused
{
	return self.layer.lx_paused;
}

- (void)lx_performShakeAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];

    animation.keyPath  = @"position.x";
    animation.values   = @[ @0, @10, @-10, @10, @0 ];
    animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
    animation.duration = 0.4;
    animation.additive = YES;

    [self.layer addAnimation:animation forKey:@"shake"];
}

@end

NS_ASSUME_NONNULL_END
