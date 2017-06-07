//
//  CHScanViewController.h
//  CHWaterCleaner
//
//  Created by Nick on 15/5/22.
//  Copyright (c) 2015年 ChangHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriverBaseViewController.h"
#import "DriverCarpoolingTaskModel.h"

@interface CHScanViewController : DriverBaseViewController

@property (nonatomic,strong) DriverCarpoolingTaskModel *driverTaskModel;

@end
