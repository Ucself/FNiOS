//
//  EvaluationViewController.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"

@interface EvaluationViewController : UserBaseUIViewController
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, assign) BOOL hasEvaluation;    //是否有评价

@end
