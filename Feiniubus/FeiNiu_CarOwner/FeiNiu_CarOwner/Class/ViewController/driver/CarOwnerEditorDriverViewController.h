//
//  CarOwnerEditorDriverViewController.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarOwnerBaseViewController.h"

//页面类型
typedef NS_ENUM(int, ControllerType)
{
    ControllerTypeAddDriver=1,      //添加驾驶员
    ControllerTypeEditorDriver,     //编辑驾驶员
    ControllerTypeErrorDriver,      //审核失败驾驶员
};

@interface CarOwnerEditorDriverViewController : CarOwnerBaseViewController

//身份证的照片 state:0,1,2(0没有数据，1有图片，2用户重新上传图片) url:(服务器上的图片地址) newImage:(用户重新上传图片)
@property (nonatomic, strong) NSMutableDictionary *headPhoto;

//驾驶员的基本信息
@property (nonatomic, strong) NSMutableDictionary *driverInfor;

//身份证的照片 state:0,1,2(0没有数据，1有图片，2用户重新上传图片) url:(服务器上的图片地址) newImage:(用户重新上传图片)
@property (nonatomic, strong) NSMutableArray *cardPhotos;


//类型，页面展示类型
@property (nonatomic,assign)  ControllerType controllerType;
//驾驶员id
@property (nonatomic,copy) NSString *driverId;

@end
