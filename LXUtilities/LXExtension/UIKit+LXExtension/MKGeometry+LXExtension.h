//
//  MKGeometry+LXExtension.h
//
//  Created by 从今以后 on 16/1/3.
//  Copyright © 2016年 apple. All rights reserved.
//

@import MapKit.MKGeometry;

static inline MKMapRect LXMapRectForCoordinateRegion(MKCoordinateRegion region)
{
    CLLocationCoordinate2D coordinateA = {
        region.center.latitude + region.span.latitudeDelta / 2,
        region.center.longitude - region.span.longitudeDelta / 2,
    };

    CLLocationCoordinate2D coordinateB = {
        region.center.latitude - region.span.latitudeDelta / 2,
        region.center.longitude + region.span.longitudeDelta / 2,
    };

    MKMapPoint a = MKMapPointForCoordinate(coordinateA);
    MKMapPoint b = MKMapPointForCoordinate(coordinateB);

    return MKMapRectMake(MIN(a.x, b.x), MIN(a.y, b.y), ABS(a.x - b.x), ABS(a.y - b.y));
}
