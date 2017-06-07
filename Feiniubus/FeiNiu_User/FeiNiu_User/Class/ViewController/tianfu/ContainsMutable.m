//
//  ContainsMutable.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/23.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "ContainsMutable.h"

@implementation ContainsMutable


//在范围内返回1，不在返回0
+ (BOOL)isContainsMutableBoundCoords:(CLLocationCoordinate2D*)coords count:(int)count coordinate:(CLLocationCoordinate2D)coordinate{
    
    if (count == 0) {
        return YES;
    }
    
    CLLocationCoordinate2D *arrSome = coords;
    
    float vertx[count];
    float verty[count];
    
    for (int i = 0; i < count; i++) {
        vertx[i] = arrSome[i].latitude;
        verty[i] = arrSome[i].longitude;
    }
    
    BOOL flag = pnpoly(count, vertx, verty, coordinate.latitude, coordinate.longitude);
    return flag;
}


BOOL pnpoly (int nvert, float *vertx, float *verty, float testx, float testy) {
    int i, j;
    BOOL c = NO;
    for (i = 0, j = nvert-1; i < nvert; j = i++) {
        if (((verty[i]>testy) != (verty[j]>testy)) && (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
            c = !c;
    }
    return c;
}



@end
