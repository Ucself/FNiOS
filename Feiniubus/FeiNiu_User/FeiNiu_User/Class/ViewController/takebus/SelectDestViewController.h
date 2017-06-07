//
//  SelectDestViewController.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/24.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIViewController.h>
#import "UserBaseUIViewController.h"

@interface SelectDestViewController : UserBaseUIViewController
{
    
}

@property (nonatomic, assign)int pageId;
@property (nonatomic, weak)NSMutableString *adCodeId;
@property (nonatomic, strong)NSString* defaultName;
@end
