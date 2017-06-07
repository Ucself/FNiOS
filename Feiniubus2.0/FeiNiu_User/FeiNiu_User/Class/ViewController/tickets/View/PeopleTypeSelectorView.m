//
//  PeopleTypeSelectorView.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/4/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "PeopleTypeSelectorView.h"

@implementation PeopleTypeSelectorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrameBlock:(CGRect)frame passengerType:(PassengerTypeEnum)passengerType completion:(void (^)(int))completeBlock
{
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"PeopleTypeSelectorView" owner:self options:nil] firstObject];
        self.frame = frame;
        self.backgroundColor = UITranslucentBKColor;
        myPickerView.delegate = self;
        myPickerView.dataSource = self;
        //移入底部
        mainViewBottom.constant = - self.frame.size.height;
        [self layoutIfNeeded];
        self.completeBlock = completeBlock;
        self.passengerType = passengerType;
        [myPickerView selectRow:passengerType == PassengerTypeAll ? 0 : 1 inComponent:0 animated:YES];
    }
    return self;
}


- (IBAction)cancleAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = - self.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (IBAction)clickCompleteAction:(UIButton *)sender
{
    if (_completeBlock) {
        self.completeBlock(_passengerType);
    }
    [self cancleAction:nil];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = 0;
        [view layoutIfNeeded];
    }];
}
- (void)hideInView:(UIView *)view
{
    [self cancleAction:nil];
}

#pragma mark -- UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            return @"全价票";
            break;
        case 1:
            return @"儿童/军残半价票";
            break;
        default:
            break;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            _passengerType = PassengerTypeAll;
            break;
        case 1:
            _passengerType = PassengerTypeHalf;
            break;
        default:
            break;
    }
}

@end
