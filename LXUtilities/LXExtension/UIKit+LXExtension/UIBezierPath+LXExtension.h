//
//  UIBezierPath+LXExtension.h
//
//  Created by 从今以后 on 15/12/12.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (LXExtension)

/**
 *  根据起点和终点创建一条直线路径。
 *
 *  @param start 线段起点。
 *  @param end   线段终点。
 */
+ (instancetype)lx_bezierPathWithStartPoint:(CGPoint)start endPoint:(CGPoint)end;

@end

NS_ASSUME_NONNULL_END
