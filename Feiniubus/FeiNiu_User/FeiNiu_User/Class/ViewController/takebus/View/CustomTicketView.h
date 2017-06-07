//
//  CustomTicketView.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTicketView;

@protocol CustomTicketViewDelegate <NSObject>

@optional

- (void)pickerTicketViewCancel;
- (void)pickerTicketViewOKParentAmount:(NSUInteger)parentAmount
                           childAmount:(NSUInteger)childAmount
                      customTicketView:(CustomTicketView *)ticketView;
@end

@interface CustomTicketView : UIView

@property (nonatomic, assign) id<CustomTicketViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger parentAmount;
@property (nonatomic, assign) NSUInteger childAmount;
@property (nonatomic) NSInteger customRow;
@property (strong, nonatomic) IBOutlet UIPickerView *peopleNumPickerView;


+ (instancetype)instance;
+ (NSString *)getTicketNum:(NSUInteger)parentAmount childAmount:(NSUInteger)childAmount;

- (void)showInView:(UIView *) view;

@end
