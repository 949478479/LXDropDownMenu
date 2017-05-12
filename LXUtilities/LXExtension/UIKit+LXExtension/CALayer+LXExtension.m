//
//  CALayer+LXExtension.m
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "CALayer+LXExtension.h"

NS_ASSUME_NONNULL_BEGIN

@interface _LXAnimationDelegate : NSObject <CAAnimationDelegate>
{
    void (^_completion)(BOOL finished);
}
@end
@implementation _LXAnimationDelegate

- (instancetype)initWithCompletion:(void (^)(BOOL finished))completion
{
    self = [super init];
    if (self) {
        _completion = completion;
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_completion) {
        _completion(flag);
        _completion = nil;
    }
}

@end

@implementation CALayer (LXExtension)

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
    return self.frame.size.width;
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

#pragma mark position

- (void)setLx_positionX:(CGFloat)lx_positionX
{
    CGPoint position = self.position;
    position.x = lx_positionX;
    self.position = position;
}

- (CGFloat)lx_positionX
{
    return self.position.x;
}

- (void)setLx_positionY:(CGFloat)lx_positionY
{
    CGPoint position = self.position;
    position.y = lx_positionY;
    self.position = position;
}

- (CGFloat)lx_positionY
{
    return self.position.y;
}

#pragma mark - 动画 -

- (void)lx_addAnimation:(CAAnimation *)anim
                 forKey:(nullable NSString *)key
      modelLayerUpdater:(void (^)(void))modelLayerUpdater
{
    [self lx_addAnimation:anim
                   forKey:key
        modelLayerUpdater:modelLayerUpdater
               completion:(void (^_Nonnull)(BOOL))nil];
}

- (void)lx_addAnimation:(CAAnimation *)anim
                 forKey:(nullable NSString *)key
             completion:(void(^)(BOOL finished))completion
{
    [self lx_addAnimation:anim
                   forKey:key
        modelLayerUpdater:(void (^_Nonnull)(void))nil
               completion:completion];
}

- (void)lx_addAnimation:(CAAnimation *)anim
                 forKey:(nullable NSString *)key
      modelLayerUpdater:(void (^)(void))modelLayerUpdater
             completion:(void (^)(BOOL finished))completion
{
    if (completion) {
        anim.delegate = [[_LXAnimationDelegate alloc] initWithCompletion:completion];
    }

	if (modelLayerUpdater) {
		modelLayerUpdater();
	}

    [self addAnimation:anim forKey:key];
}

- (void)setLx_paused:(BOOL)lx_paused
{
	if (lx_paused == self.lx_paused) {
		return;
	}

    if (lx_paused) {
        /* speed 设置为 0.0 将导致图层本地时间变为 0.0，而无论 beginTime 和 timeOffset 之前的值是多少，
           将 timeOffset 设置为图层本地时间，就可以在 speed 设置为 0.0 后保持图层本地时间不变，
           此时 speed 为 0.0，动画停止，且图层本地时间未变，因此动画会停止在原处。*/
        self.timeOffset = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0.0;
    } else {
        /* speed 设置为 1.0 后，图层本地时间会恢复正常。此时若将 timeOffset 重置为 0.0，即 timeOffset = 0.0，
           图层本地时间将等于绝对时间 CACurrentMediaTime()。但是暂停的这段时间内图层本地时间并未增长，
           应该减去这段时间，这个时间增量刚好是 CACurrentMediaTime() - timeOffset。若 beginTime 不为 0.0，
           还应加上该值。因此最终结果为 timeOffset = 0 - (CACurrentMediaTime() - timeOffset) + beginTime。
           这样图层的本地时间就会等于暂停前的值，此时 speed 恢复为 1.0，且图层本地时间未变，因此动画会从原处恢复。*/
        self.speed = 1.0;
        self.timeOffset += self.beginTime - CACurrentMediaTime();
    }
}

- (BOOL)lx_paused
{
    return self.speed == 0.0;
}

@end

NS_ASSUME_NONNULL_END
