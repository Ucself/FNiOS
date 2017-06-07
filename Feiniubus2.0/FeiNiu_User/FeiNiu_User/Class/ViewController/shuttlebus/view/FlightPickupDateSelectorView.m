//
//  DateSelectorVV.m
//  FeiNiu_User
//
//  Created by CYJ on 16/4/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "FlightPickupDateSelectorView.h"

@interface FlightPickupDateSelectorView()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    __weak IBOutlet UIView *mainView;
    __weak IBOutlet NSLayoutConstraint *mainViewBottom;
    __weak IBOutlet UIPickerView *myPickerView;
    
    NSInteger seleMinuteIndex;
    NSMutableArray *dateArray;
}
@end

@implementation FlightPickupDateSelectorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"FlightPickupDateSelectorView" owner:self options:nil][0];
        self.frame = frame;
        self.backgroundColor = UITranslucentBKColor;
        [self initializeDates];
        myPickerView.delegate = self;
        myPickerView.dataSource = self;
    }
    return self;
}

- (void)initializeDates
{
    dateArray = @[@20,@30,@40,@50,@60,@70,@80,@90].mutableCopy;
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
    [self cancleAction:nil];
    
    if (_clickCompleteBlock) {
        int selectValue = [dateArray[seleMinuteIndex] intValue];
        _clickCompleteBlock(selectValue);
    }
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = 0;
        [view layoutIfNeeded];
    }];
}

- (IBAction)tapGesture:(id)sender {
    [self cancleAction:nil];
}

#pragma mark -- UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 1;
        case 1:
            return dateArray.count;
        case 2:
            return 1;
        default:
            break;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component == 0) {
        return pickerView.bounds.size.width/2;
    }
    else{
        return pickerView.bounds.size.width/6;
    }
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 24.f;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return @"航班到达后";
        case 1:
            return [NSString stringWithFormat:@"%@",dateArray[row]];
        case 2:
            return @"分钟";
        default:
            break;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    seleMinuteIndex = row;
    [myPickerView reloadAllComponents];
}

@end
