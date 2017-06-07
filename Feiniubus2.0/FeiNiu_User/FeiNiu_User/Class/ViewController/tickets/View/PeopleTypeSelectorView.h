//
//  PeopleTypeSelectorView.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/4/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int , PassengerTypeEnum) {
    PassengerTypeAll = 1,  //普通票
    PassengerTypeHalf = 3,  //普通票
};


typedef void (^CallbackBlock)(int passengerType);

@interface PeopleTypeSelectorView : UIView <UIPickerViewDelegate,UIPickerViewDataSource>
{
    __weak IBOutlet UIView *mainView;
    __weak IBOutlet NSLayoutConstraint *mainViewBottom;
    __weak IBOutlet UIPickerView *myPickerView;

}

@property(nonatomic,assign) PassengerTypeEnum passengerType;  //1普通票 3半票
@property(nonatomic,strong) CallbackBlock completeBlock;

-(instancetype)initWithFrameBlock:(CGRect)frame passengerType:(PassengerTypeEnum)passengerType completion:(void (^)(int))completeBlock;
- (void)showInView:(UIView *)view;
- (void)hideInView:(UIView *)view;

@end
