//
//  QueryTicketResultModel.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/21.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

@interface QueryTicketResultModel : BaseModel

@property (nonatomic,strong) NSString *trainPathId;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *startCity;
@property (nonatomic,strong) NSString *startSite;
@property (nonatomic,strong) NSString *endCity;
@property (nonatomic,strong) NSString *endSite;
@property (nonatomic,assign) int type;      //2定时，3滚动
@property (nonatomic,strong) NSString *time;
@property (nonatomic,assign) int remainedTicket;
@property (nonatomic,assign) int price;
@property (nonatomic,assign) int couponIoc;        //优惠卷类型
@property (nonatomic,strong) NSString *coupon;      //优惠卷描述

@end
