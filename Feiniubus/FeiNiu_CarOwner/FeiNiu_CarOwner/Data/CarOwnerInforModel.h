//
//  CarOwnerInforModel.h
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarOwnerInforModel : UIView

//总收入
@property(nonatomic,assign) float totalAmount;
//车辆数
@property(nonatomic,strong) NSString *vehicleAmount;
//驾驶员数量
@property(nonatomic,strong) NSString *driverAmount;
//总接单数
@property(nonatomic,strong) NSString *orderAmount;
//总里程数
@property(nonatomic,strong) NSString *mileage;


//使用字典初始化
-(id)initWithDictionary:(NSDictionary*)dictionary;
@end
