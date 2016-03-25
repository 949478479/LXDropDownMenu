//
//  CAAnimation+LXExtension.swift
//
//  Created by 从今以后 on 16/1/10.
//  Copyright © 2016年 apple. All rights reserved.
//

import QuartzCore.CAMediaTiming

extension CAMediaTimingFunction {
    @nonobjc static let Linear        = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    @nonobjc static let EaseIn        = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    @nonobjc static let EaseOut       = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    @nonobjc static let EaseInEaseOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
}
