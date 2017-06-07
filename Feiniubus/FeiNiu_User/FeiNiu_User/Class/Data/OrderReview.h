//
//  OrderReview.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/3.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

@class ReviewItem;

@interface OrderReview : BaseModel
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, assign) CGFloat driverScores;
@property (nonatomic, assign) CGFloat vehicleScores;
@property (nonatomic, assign) BOOL isAppraiseVehicle;
@property (nonatomic, assign) BOOL isAppraiseDriver;
@property (nonatomic, strong) NSArray<ReviewItem *> *vehicleAppraises;
@property (nonatomic, strong) NSArray<ReviewItem *> *driverAppraises;
@property (nonatomic, strong) NSArray<NSString *> *vehiclePhotos;
@end

@interface ReviewItem : BaseModel
@property (nonatomic, strong) NSDate    *appraiseTime;
@property (nonatomic, assign) NSInteger appraiseLevel;
@property (nonatomic, strong) NSString  *content;
@property (nonatomic, strong) NSString  *reviewId;
@end