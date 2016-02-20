//
//  CGGeometry+LXExtension.h
//
//  Created by 从今以后 on 15/11/20.
//  Copyright © 2015年 apple. All rights reserved.
//

@import CoreGraphics.CGGeometry;

static inline CGRect LXRectAdjust(CGRect rect, CGFloat dx, CGFloat dy, CGFloat dw, CGFloat dh)
{
    return (CGRect){ {rect.origin.x + dx, rect.origin.y + dy}, {rect.size.width + dw, rect.size.height + dh} };
}

static inline CGSize LXSizeAdjust(CGSize size, CGFloat dw, CGFloat dh)
{
    return (CGSize){ size.width + dw, size.height + dh };
}

static inline CGPoint LXPointAdjust(CGPoint point, CGFloat dx, CGFloat dy)
{
    return (CGPoint){ point.x + dx, point.y + dy };
}
