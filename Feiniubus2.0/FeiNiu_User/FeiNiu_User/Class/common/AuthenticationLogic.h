//
//  AuthenticationLogic.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/7/27.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AuthenticationLogic : NSObject

@property(nonatomic,strong) UIViewController *viewController;

+(AuthenticationLogic*)sharedInstance;
//初始化所需数据
-(void)addUserData:(UIViewController*)viewController;
@end
