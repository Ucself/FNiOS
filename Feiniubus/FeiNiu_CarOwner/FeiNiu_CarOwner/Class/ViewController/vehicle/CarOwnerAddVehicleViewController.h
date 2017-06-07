//
//  CarOwnerAddVehicleViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"
#import "CarOwnerVehicleModel.h"

typedef NS_ENUM(int, EditorType)
{
    EditorTypeAdd = 1,      //添加
    EditorTypeEditor,       //编辑
    EditorTypeError,        //审核错误
};

@interface CarOwnerAddVehicleViewController : CarOwnerBaseViewController

/**
 *  数据源属性
 */
//经营范围
@property (nonatomic, strong) NSMutableArray *businessScopeArray;
//座位数
@property (nonatomic, strong) NSMutableArray *seatNumberArray;
//车型等级
@property (nonatomic, strong) NSMutableArray *vehicleLevelArray;
//车型类型
@property (nonatomic, strong) NSMutableArray *vehicleTypeArray;
//等级类型数组
@property (nonatomic, strong) NSMutableArray *levelTypeArray;
//燃油类别
@property (nonatomic, strong) NSMutableArray *fuelTypeArray;
/**
 *  当前展示的数据数据源
 */
@property (nonatomic, strong) NSMutableDictionary *levelType;
@property (nonatomic, copy) CarOwnerVehicleModel *dataModel;
//运营证  state:0,1,2(0没有数据，1有图片，2用户重新上传图片) url:(服务器上的图片地址) newImage:(用户重新上传图片)
@property (nonatomic, strong) NSMutableArray *operateCertificate;
//车的照片 state:0,1,2(0没有数据，1有图片，2用户重新上传图片) url:(服务器上的图片地址) newImage:(用户重新上传图片)
@property (nonatomic, strong) NSMutableArray *carPhotos;

//传入的数据对象
@property (nonatomic, strong) CarOwnerVehicleModel *vehicleModel;
@property (nonatomic ,assign) EditorType editorType;



@end
