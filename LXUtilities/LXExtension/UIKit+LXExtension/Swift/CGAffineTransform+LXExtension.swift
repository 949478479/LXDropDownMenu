//
//  CGAffineTransform+LXExtension.swift
//
//  Created by 从今以后 on 16/1/10.
//  Copyright © 2016年 apple. All rights reserved.
//

import CoreGraphics.CGAffineTransform

extension CGAffineTransform {

    var NSValue: NSValueType {
        return NSValueType(CGAffineTransform: self)
    }

    func CGAffineTransformMakeScaleTranslate(sx: CGFloat, _ sy: CGFloat, _ tx: CGFloat, _ ty: CGFloat) -> CGAffineTransform {
        return CGAffineTransformMake(sx, 0, 0, sy, tx, ty)
    }

    mutating func scaleInPlace(sx sx: CGFloat, sy: CGFloat) {
        self = CGAffineTransformScale(self, sx, sy)
    }

    mutating func rotateInPlace(angle angle: CGFloat) {
        self = CGAffineTransformRotate(self, angle)
    }

    mutating func translateInPlace(tx tx: CGFloat, ty: CGFloat) {
        self = CGAffineTransformTranslate(self, tx, ty)
    }
}
