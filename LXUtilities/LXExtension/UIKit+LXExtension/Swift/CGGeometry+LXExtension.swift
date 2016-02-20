//
//  CGGeometry+LXExtension.swift
//
//  Created by 从今以后 on 15/12/21.
//  Copyright © 2015年 apple. All rights reserved.
//

import Foundation.NSValue
import CoreGraphics.CGGeometry

typealias NSValueType = NSValue

extension CGPoint {

    var NSValue: NSValueType {
        return NSValueType(CGPoint: self)
    }

    func adjustBy(dx dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }

    mutating func adjustInPlace(dx dx: CGFloat, dy: CGFloat) {
        x += dx
        y += dy
    }
}

extension CGSize {

    var NSValue: NSValueType {
        return NSValueType(CGSize: self)
    }

    func adjustBy(dw dw: CGFloat, dh: CGFloat) -> CGSize {
        return CGSize(width: width + dw, height: height + dh)
    }

    mutating func adjustInPlace(dw dw: CGFloat, dh: CGFloat) {
        width  += dw
        height += dh
    }
}

extension CGRect {

    var NSValue: NSValueType {
        return NSValueType(CGRect: self)
    }

    func transformBy(t: CGAffineTransform) -> CGRect {
        return CGRectApplyAffineTransform(self, t)
    }

    mutating func transformInPlace(t: CGAffineTransform) {
        self = CGRectApplyAffineTransform(self, t)
    }
}
