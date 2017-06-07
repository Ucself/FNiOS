//
//  DriverCombinationTaskModel.h
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/11/9.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverCombinationTaskModel : NSObject

//任务类型 1 包车任务 2是拼车任务
@property (nonatomic,assign) int taskType;
//任务状态 1 按钮为（开始任务） 2 按钮为（结束任务） 3 按钮为（任务完成）
@property (nonatomic,assign) int taskState;
//任务开始时间
@property (nonatomic,strong) NSDate *taskStartDate;
//任务对象
@property (nonatomic,strong) NSObject *taskObject;

@end
