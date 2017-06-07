//
//  CarOwnerVehicleModel.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/9.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerVehicleModel.h"
#import <FNCommon/JsonUtils.h>

@implementation CarOwnerVehicleModel

//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        if (![dictionary isKindOfClass:[NSDictionary class]] || !dictionary) {
            return self;
        }
        self.vehicleId = [dictionary objectForKey:@"id"] ? [dictionary objectForKey:@"id"] : @"";
        self.licensePlate = [dictionary objectForKey:@"licensePlate"] ? [dictionary objectForKey:@"licensePlate"] : @"";
        self.seats = [dictionary objectForKey:@"seats"] ? [[dictionary objectForKey:@"seats"] intValue] : 0;
        self.levelId = [dictionary objectForKey:@"levelId"] ? [[dictionary objectForKey:@"levelId"] intValue] : 0;
        self.owenerId = [dictionary objectForKey:@"owenerId"] ? [dictionary objectForKey:@"owenerId"] : @"";
        self.createTime = [dictionary objectForKey:@"createTime"] ? [dictionary objectForKey:@"createTime"]  : @"";
        self.state = [dictionary objectForKey:@"state"] ? [[dictionary objectForKey:@"state"] intValue] : 0;
        self.companyId = [dictionary objectForKey:@"companyId"] ? [dictionary objectForKey:@"companyId"] : @"";
        self.registerTime = [dictionary objectForKey:@"registerTime"] ? [dictionary objectForKey:@"registerTime"] : @"";
        self.businessScopeId = [dictionary objectForKey:@"businessScope"] ? [[dictionary objectForKey:@"businessScope"] intValue] : 0;
        self.length = [dictionary objectForKey:@"length"] ? [[dictionary objectForKey:@"length"] intValue] : 0;
        self.audit = [dictionary objectForKey:@"audit"] ? [[dictionary objectForKey:@"audit"] intValue] : 0;
        self.lastQuotation = [dictionary objectForKey:@"lastQuotation"] ? [[dictionary objectForKey:@"lastQuotation"] floatValue]: 0.0f;
        self.typeId = [dictionary objectForKey:@"type"] ? [[dictionary objectForKey:@"type"] intValue] : 0;
        //        self.extension =
        //对图片进行处理
        NSMutableDictionary *extensionDic = [[NSMutableDictionary alloc] init];
        if ([dictionary objectForKey:@"extension"]) {
            NSMutableDictionary *extensionStingDic = [[NSMutableDictionary alloc] init];
            //去掉空格
            NSString *strExtension = [dictionary objectForKey:@"extension"];
            strExtension = [strExtension stringByReplacingOccurrencesOfString:@" " withString:@""];
            extensionStingDic = (NSMutableDictionary*)[JsonUtils jsonToDcit:strExtension];
            //存在证件照
            if ([extensionStingDic objectForKey:OperatePhoto]) {
                CarOwnerOperatePhotoModel *operatePhotoModel = [[CarOwnerOperatePhotoModel alloc] initWithDictionary:[extensionStingDic objectForKey:OperatePhoto]];
                [extensionDic setObject:operatePhotoModel forKey:OperatePhoto];
            }
            //存在车辆照片
            if ([extensionStingDic objectForKey:VehiclePhoto]) {
                CarOwnerVehiclePhotoModel *operatePhotoModel = [[CarOwnerVehiclePhotoModel alloc] initWithDictionary:[extensionStingDic objectForKey:VehiclePhoto]];
                [extensionDic setObject:operatePhotoModel forKey:VehiclePhoto];
            }
            
        }
        self.extension = extensionDic;
        self.ratingId = [dictionary objectForKey:@"rating"] ? [[dictionary objectForKey:@"rating"] floatValue] : 0.0f;
        self.fuelTypeId = [dictionary objectForKey:@"fuelType"] ? [[dictionary objectForKey:@"fuelType"] intValue] : 0;
        self.businessScopeName = [dictionary objectForKey:@"businessScopeName"] ? [dictionary objectForKey:@"businessScopeName"]  : @"";
        self.levelName = [dictionary objectForKey:@"levelName"] ? [dictionary objectForKey:@"levelName"]  : @"";
        self.typeName = [dictionary objectForKey:@"typeName"] ? [dictionary objectForKey:@"typeName"]  : @"";
        self.companyName = [dictionary objectForKey:@"companyName"] ? [dictionary objectForKey:@"companyName"]  : @"";
        self.fuelTypeName = [dictionary objectForKey:@"fuelTypeName"] ? [dictionary objectForKey:@"fuelTypeName"]  : @"";
    }
    
    return self;
}

-(CarOwnerVehicleModel *)clone {
    CarOwnerVehicleModel *other = [[CarOwnerVehicleModel alloc] init];
    //车辆ID
    other.vehicleId = [[NSString alloc] initWithString: _vehicleId];
    //车牌号
    other.licensePlate = [[NSString alloc] initWithString: _licensePlate];
    //座位数
    other.seats = _seats;
    //车辆等级id
    other.levelId = _levelId;
    //车主id
    other.owenerId = [[NSString alloc] initWithString: _owenerId];
    //车辆创建时间
    other.createTime = [[NSString alloc] initWithString: _createTime];
    //车辆运行状态
    other.state = _state;
    //运营所属运营公司id
    other.companyId = [[NSString alloc] initWithString: _companyId];
    //车辆开始运营时间
    other.registerTime = [[NSString alloc] initWithString: _registerTime];
    //车辆的业务范围Id
    other.businessScopeId = _businessScopeId;
    //车辆长度
    other.length = _length;
    //车辆审核状态
    other.audit = _audit;
    //车辆单日期望毛利  （最后报价）
    other.lastQuotation = _lastQuotation;
    //车辆类型id
    other.typeId = _typeId;
    //车辆的评分
    other.ratingId = _ratingId;
    //燃油类型Id
    other.fuelTypeId = _fuelTypeId;
    //业务范围名称
    other.businessScopeName = [[NSString alloc] initWithString: _businessScopeName];
    //车辆等级名称
    other.levelName = [[NSString alloc] initWithString: _levelName];
    //车辆类型名称
    other.typeName = [[NSString alloc] initWithString: _typeName];
    //运营公司名称
    other.companyName = [[NSString alloc] initWithString: _companyName];
    //燃油类型名称
    other.fuelTypeName = [[NSString alloc] initWithString: _fuelTypeName];
    //车辆图片的扩展
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    other.extension = dict;
    CarOwnerOperatePhotoModel *operatePhotoModel = [_extension objectForKey: OperatePhoto];
    if(operatePhotoModel) {
        [dict setObject: [operatePhotoModel clone] forKey: OperatePhoto];
    }
    CarOwnerVehiclePhotoModel *vehiclePhotoModel = [_extension objectForKey: VehiclePhoto];
    if(vehiclePhotoModel) {
        [dict setObject: [vehiclePhotoModel clone] forKey: VehiclePhoto];
    }
    return other;
}

@end



@implementation CarOwnerOperatePhotoModel

-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        if ([dictionary isKindOfClass:[NSNull class]] || !dictionary) {
            return self;
        }
        self.firstUrl = [dictionary objectForKey:@"firstUrl"] ? [dictionary objectForKey:@"firstUrl"]  : @"";
        self.secondUrl = [dictionary objectForKey:@"secondUrl"] ? [dictionary objectForKey:@"secondUrl"]  : @"";
        self.thirdUrl = [dictionary objectForKey:@"thirdUrl"] ? [dictionary objectForKey:@"thirdUrl"]  : @"";
        self.fourthUrl = [dictionary objectForKey:@"fourthUrl"] ? [dictionary objectForKey:@"fourthUrl"]  : @"";
    }
    
    return self;
}

-(CarOwnerOperatePhotoModel *)clone {
    CarOwnerOperatePhotoModel *other = [[CarOwnerOperatePhotoModel alloc] init];
    other.firstUrl = [[NSString alloc] initWithString: _firstUrl];
    other.secondUrl = [[NSString alloc] initWithString: _secondUrl];
    other.thirdUrl = [[NSString alloc] initWithString: _thirdUrl];
    other.fourthUrl = [[NSString alloc] initWithString: _fourthUrl];
    return other;
}

@end

@implementation CarOwnerVehiclePhotoModel

-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        if ([dictionary isKindOfClass:[NSNull class]] || !dictionary) {
            return self;
        }
        self.frontUrl = [dictionary objectForKey:@"frontUrl"] ? [dictionary objectForKey:@"frontUrl"]  : @"";
        self.sideUrl = [dictionary objectForKey:@"sideUrl"] ? [dictionary objectForKey:@"sideUrl"]  : @"";
        self.backUrl = [dictionary objectForKey:@"backUrl"] ? [dictionary objectForKey:@"backUrl"]  : @"";
    }
    
    return self;
}

-(CarOwnerVehiclePhotoModel *)clone {
    CarOwnerVehiclePhotoModel *other = [[CarOwnerVehiclePhotoModel alloc] init];
    other.frontUrl = [[NSString alloc] initWithString: _frontUrl];
    other.sideUrl = [[NSString alloc] initWithString: _sideUrl];
    other.backUrl = [[NSString alloc] initWithString: _backUrl];
    return other;
}

@end
