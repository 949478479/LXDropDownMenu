//
//  CATransaction+LXExtension.swift
//
//  Created by 从今以后 on 16/1/12.
//  Copyright © 2016年 apple. All rights reserved.
//

import QuartzCore.CATransaction

extension CATransaction {

    /**
     禁用隐式动画。

     - parameter actionsWithoutAnimation: 在闭包内修改图层属性不会触发隐式动画
     */
    static func performWithoutAnimation(actionsWithoutAnimation: () -> ()) {
        begin()
        setDisableActions(true)
        actionsWithoutAnimation()
        commit()
    }

    /**
     定制隐式动画。

     - parameter duration:   隐式动画持续时间。
     - parameter animations: 在此闭包内修改图层属性。
     - parameter completion: 隐式动画完成时调用此闭包。
     */
    static func animateWithDuration(duration: CFTimeInterval, animations: () -> (),
        completion: (() -> ())? = nil) {
        begin()
        setAnimationDuration(duration)
        setCompletionBlock(completion)
        animations();
        commit()
    }
}
