//
//  CharterTravelStateViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/18.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"
@class CharterSuborderItem;

@interface CharterTravelStateViewController : UserBaseUIViewController
@property (nonatomic, strong) CharterSuborderItem *suborder;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblBusInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblKM;
@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblDestination;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
- (void)setupUI;
@end


@interface CharterTravelStatePrepareViewController : CharterTravelStateViewController{
    NSTimer *_waitTimer;
    NSInteger   _startIndex;
}
@property (weak, nonatomic) IBOutlet CircleProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *btnTimeout;
@end

@interface CharterTravelStateGrabbedViewController : CharterTravelStateViewController{
    NSTimer *_timer;
    int _startIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *lblTimer;

@end




@interface CharterTravelStateWaitForPayViewController : CharterTravelStateViewController

@end


@interface CharterTravelStatePayedViewController : CharterTravelStateViewController

@end


@interface CharterTravelStateRefundViewController : CharterTravelStateViewController

@end