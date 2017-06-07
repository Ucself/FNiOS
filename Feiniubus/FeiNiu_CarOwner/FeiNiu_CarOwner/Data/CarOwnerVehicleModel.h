//
//  CarOwnerVehicleModel.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/9.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OperatePhoto @"operatePhoto"
#define VehiclePhoto @"vehiclePhoto"

@interface CarOwnerVehicleModel : NSObject

//车辆ID
@property(nonatomic,strong) NSString *vehicleId;
//车牌号
@property(nonatomic,strong) NSString *licensePlate;
//座位数
@property(nonatomic,assign) int seats;
//车辆等级id
@property(nonatomic,assign) int levelId;
//车主id
@property(nonatomic,strong) NSString *owenerId;
//车辆创建时间
@property(nonatomic,strong) NSString *createTime;
//车辆运行状态
@property(nonatomic,assign) int state;
//运营所属运营公司id
@property(nonatomic,strong) NSString *companyId;
//车辆开始运营时间
@property(nonatomic,strong) NSString *registerTime;
//车辆的业务范围Id
@property(nonatomic,assign) int businessScopeId;
//车辆长度
@property(nonatomic,assign) int length;
//车辆审核状态
@property(nonatomic,assign) int audit;
//车辆单日期望毛利  （最后报价）
@property(nonatomic,assign) float lastQuotation;
//车辆类型id
@property(nonatomic,assign) int typeId;
//车辆图片的扩展
@property(nonatomic,strong) NSMutableDictionary *extension;
//车辆的评分
@property(nonatomic,assign) float ratingId;
//燃油类型Id
@property(nonatomic,assign) int fuelTypeId;
//业务范围名称
@property(nonatomic,strong) NSString *businessScopeName;
//车辆等级名称
@property(nonatomic,strong) NSString *levelName;
//车辆类型名称
@property(nonatomic,strong) NSString *typeName;
//运营公司名称
@property(nonatomic,strong) NSString *companyName;
//燃油类型名称
@property(nonatomic,strong) NSString *fuelTypeName;

//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary;

-(CarOwnerVehicleModel *)clone;

@end

@interface CarOwnerOperatePhotoModel : NSObject

@property(nonatomic,strong) NSString *firstUrl;
@property(nonatomic,strong) NSString *secondUrl;
@property(nonatomic,strong) NSString *thirdUrl;
@property(nonatomic,strong) NSString *fourthUrl;

//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary;

-(CarOwnerOperatePhotoModel *)clone;
@end

@interface CarOwnerVehiclePhotoModel : NSObject

//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary;

@property(nonatomic,strong) NSString *frontUrl;
@property(nonatomic,strong) NSString *sideUrl;
@property(nonatomic,strong) NSString *backUrl;

-(CarOwnerVehiclePhotoModel *)clone;
@end












