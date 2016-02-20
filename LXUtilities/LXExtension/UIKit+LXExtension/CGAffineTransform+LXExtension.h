//
//  CGAffineTransform+LXExtension.h
//
//  Created by 从今以后 on 16/1/10.
//  Copyright © 2016年 apple. All rights reserved.
//

static inline CGAffineTransform LXAffineTransformMakeScaleTranslate(CGFloat sx,
                                                                    CGFloat sy,
                                                                    CGFloat tx,
                                                                    CGFloat ty)
{
    return CGAffineTransformMake(sx, 0, 0, sy, tx, ty);
}
