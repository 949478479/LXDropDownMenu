//
//  CATransform3D+LXExtension.swift
//
//  Created by 从今以后 on 16/1/10.
//  Copyright © 2016年 apple. All rights reserved.
//

import QuartzCore.CATransform3D

extension CATransform3D {

    var NSValue: NSValueType {
        return NSValueType(CATransform3D: self)
    }
}
