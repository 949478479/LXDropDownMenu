//
//  CALayer+LXExtension.swift
//
//  Created by 从今以后 on 16/1/10.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

// MARK: - 动画 -
extension CALayer {

    /// 暂停、恢复动画。
    final var paused: Bool {
        set {
            if newValue == paused { return }

            if newValue {
                /* speed 设置为 0.0 将导致图层本地时间变为 0.0，而无论 beginTime 和 timeOffset 之前的值是多少，
                将 timeOffset 设置为图层本地时间，就可以在 speed 设置为 0.0 后保持图层本地时间不变，
                此时 speed 为 0.0，动画停止，且图层本地时间未变，因此动画会停止在原处。*/
                timeOffset = convertTime(CACurrentMediaTime(), fromLayer: nil)
                speed = 0.0
            } else {
                /* speed 设置为 1.0 后，图层本地时间会恢复正常。此时若将 timeOffset 重置为 0.0，即 timeOffset = 0.0，
                图层本地时间将等于绝对时间 CACurrentMediaTime()。但是暂停的这段时间内图层本地时间并未增长，
                应该减去这段时间，这个时间增量刚好是 CACurrentMediaTime() - timeOffset。若 beginTime 不为 0.0，
                还应加上该值。因此最终结果为 timeOffset = 0 - (CACurrentMediaTime() - timeOffset) + beginTime。
                这样图层的本地时间就会等于暂停前的值，此时 speed 恢复为 1.0，且图层本地时间未变，因此动画会从原处恢复。*/
                speed = 1.0
                timeOffset += beginTime - CACurrentMediaTime()
            }
        }
        get {
            return speed == 0.0
        }
    }

    /**
     添加动画。

     - parameter anim:              动画对象。
     - parameter key:               动画对象的键。
     - parameter modelLayerUpdater: 在此闭包中更新图层属性不会触发隐式动画。
     - parameter completion:        动画正常完成或被移除时调用此闭包，注意不要设置动画代理。
     */
    final func addAnimation(anim: CAAnimation, forKey key: String? = nil,
        modelLayerUpdater: (() -> ())?, completion: (Bool -> ())?) {

        class AnimationDelegate {
            var completion: (Bool -> ())?
            init(completion: Bool -> ()) {
                self.completion = completion
            }
            private func animationDidStart(anim: CAAnimation) {}
            private func animationDidStop(anim: CAAnimation, finished flag: Bool) {
                completion?(flag)
                completion = nil
            }
        }

        if let completion = completion {
            anim.delegate = AnimationDelegate(completion: completion)
        }
        modelLayerUpdater?()
        self.addAnimation(anim, forKey: key)
    }

    /**
     添加动画。

     - parameter anim:              动画对象。
     - parameter key:               动画对象的键。
     - parameter modelLayerUpdater: 在此闭包中更新图层属性不会触发隐式动画。
     */
    final func addAnimation(anim: CAAnimation, forKey key: String? = nil, modelLayerUpdater: () -> ()) {
        addAnimation(anim, forKey: key, modelLayerUpdater: modelLayerUpdater, completion: nil)
    }

    /**
     添加动画。

     - parameter anim:       动画对象。
     - parameter key:        动画对象的键。
     - parameter completion: 动画正常完成或被移除时调用此闭包，注意不要设置动画代理。
     */
    final func addAnimation(anim: CAAnimation, forKey key: String? = nil, completion: Bool -> ()) {
        addAnimation(anim, forKey: key, modelLayerUpdater: nil, completion: completion)
    }
}
