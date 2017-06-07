//
//  CityObj.h
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/9.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FNDataModule/BaseModel.h>

@interface CityObj : BaseModel  


@property (nonatomic, strong) NSString *adcode;         //城市代码
@property (nonatomic, strong) NSString *city_name;      //城市名称
@property (nonatomic, strong) NSString *company_name;   //公司名称
@property (nonatomic, strong) NSString *disabled;       //是否禁用
@property (nonatomic, strong) NSString *province_code;  //开通城市所对应的省级CODE
@property (nonatomic, strong) NSString *province_name;  //开通城市所对应的省级名称
@property (nonatomic, assign) int site_level;           //站点等级
@property (nonatomic, assign) int tag;                  //标签
@property (nonatomic, assign) double central_latitude;  //纬度
@property (nonatomic, assign) double central_longitude; //经度
@end


@interface StationObj : BaseModel
@property (nonatomic, strong) NSString *id;       //站点id
@property (nonatomic, strong) NSString *station_id;       //站点id
@property (nonatomic, strong) NSString *name;             //名称
@property (nonatomic, strong) NSString *address;          //地址
@property (nonatomic, assign) double longitude;        //经度
@property (nonatomic, assign) double latitude;         //纬度
@property (nonatomic, assign) int type;                   //类型 (机场 1 火车站2 汽车站3)
@property (nonatomic, assign) BOOL matched;             //是否匹配到的航站楼

@end


@interface CoordinateObj : BaseModel
@property (nonatomic, assign) double longitude;        //经度
@property (nonatomic, assign) double latitude;         //纬度
@property (nonatomic, assign) int sort;                //排序
@end

@interface FenceObj : BaseModel
@property (nonatomic, strong) NSString *name;             //名称
@property (nonatomic, strong) NSString *city_name;             //名称
@property (nonatomic, strong) NSString *id;               //id
@property (nonatomic, strong) NSString *business_module;  //业务类型
@property (nonatomic, strong) NSString *adcode;           //区域代码
@property (nonatomic, assign) int       priority;         //优先级
@property (nonatomic, assign) BOOL      disabled;         //是否禁用
@property (nonatomic, strong) NSArray<CoordinateObj*>  *coordinates;           //围栏数据

@end



