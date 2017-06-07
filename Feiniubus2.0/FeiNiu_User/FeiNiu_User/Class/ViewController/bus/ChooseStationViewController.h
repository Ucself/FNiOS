//
//  ChooseStationViewController.h
//  FeiNiu_User
//
//  Created by CYJ on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import "ChooseStationObj.h"
#import "ShuttleStationViewCotroller.h"

@interface ChooseStationViewController : UserBaseUIViewController

@property(nonatomic,copy) NSString *navTitle;

@property(nonatomic,assign)ShuttleStationType type;

@property(nonatomic, strong) NSString *adressName;

@property(nonatomic,copy) void (^clickPopAction)(ChooseStationObj *obj);

@end
