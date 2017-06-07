//
//  CarpoolOrderPrice.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/7.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarpoolOrderPrice : NSObject

@property (nonatomic,copy)   NSString *virtualId;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,copy)   NSString *bookingStartTime;
@property (nonatomic,copy)   NSString *bookingEndTime;
@property (nonatomic,strong) NSNumber *childrenNumber;
@property (nonatomic,strong) NSNumber *peopleNumber;
@property (nonatomic,strong) NSString *pathId;
@property (nonatomic,strong) NSString *trainId;


@end
