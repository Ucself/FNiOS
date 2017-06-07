//
//  TFCarOrderDetailModel.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/6.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFCarOrderDetailModel : NSObject

@property (nonatomic, assign) double    boardingLatitude;
@property (nonatomic, assign) double    boardingLongitude;
@property (nonatomic, assign) double    destinationLatitude;
@property (nonatomic, assign) double    destinationLongitude;


@property (nonatomic, assign) NSInteger carpoolOrderId;
@property (nonatomic, assign) NSInteger taskId;
@property (nonatomic, assign) NSInteger busId;

@property (nonatomic, strong) NSString  *driverName;
@property (nonatomic, strong) NSString  *driverPhone;
@property (nonatomic, strong) NSString  *driverAvatar;
@property (nonatomic, strong) NSString  *license;

@property (nonatomic, strong) NSString  *orderId;
@property (nonatomic, assign) int type;
@property (nonatomic, strong) NSString  *boardAddress;
@property (nonatomic, strong) NSString  *destinationAddress;
@property (nonatomic, assign) int   state;
@property (nonatomic, assign) int   payState;
@property (nonatomic, strong) NSString*   price;
@property (nonatomic, strong) NSString*   creator;
@property (nonatomic, strong) NSString*   createTime;
@property (nonatomic, assign) int   number;
@property (nonatomic, assign) float   driverScore;
@property (nonatomic, assign) int   driverOrderNum;


- (id)initWithDictionary:(NSDictionary*)_dic;


@end
