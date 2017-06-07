//
//  TaskFilterView.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "TaskFilterView.h"
#import <FNUIView/BaseUIView.h>
#import <FNCommon/FNCommon.h>

#define kContentHeight 120

@interface TaskFilterView()<UITextFieldDelegate>
{
    UIView *parentView;
    
}

@property (weak, nonatomic) IBOutlet UITextField *startPriceText;
@property (weak, nonatomic) IBOutlet UITextField *endPriceText;
@property (weak, nonatomic) IBOutlet UIButton *dayTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *weekTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *monthTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *currentTaskButton;
@property (weak, nonatomic) IBOutlet UIButton *completeTaskButton;


@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

//容器视图
@property (weak, nonatomic) IBOutlet UIView *contentView;



@end

@implementation TaskFilterView



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)awakeFromNib
{
    //设置透明背景色
    self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround)];
    [self addGestureRecognizer:gesture];
    //设置父窗口点击取消键盘
    UIGestureRecognizer *contentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelKeyboard)];
    [_contentView addGestureRecognizer:contentGesture];
    //设置圆角
    [self setRounded];
    //设置选择的值
//    [self setViewValue];
}
//设置传入的值
-(void)setViewValue
{
    //价格值设置
//    if (_startPrice) {
        _startPriceText.text = [[NSString alloc] initWithFormat:@"%.0f",_startPrice];
//    }
    if (_endPrice) {
        _endPriceText.text = [[NSString alloc] initWithFormat:@"%.0f",_endPrice];
    }
    //设置订单时间
    switch (_dateType) {
        case FilterTimeTypeDay:
        {
            [_dayTimeButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
            [_dayTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
            break;
        case FilterTimeTypeWeek:
        {
            [_weekTimeButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
            [_weekTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
            break;
        case FilterTimeTypeMonth:
        {
            [_monthTimeButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
            [_monthTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    //设置任务状态
    switch (_taskType) {
        case FilterTaskTypeCurrent:
        {
            [_currentTaskButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
            [_currentTaskButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
            break;
        case FilterTaskTypeComplete:
        {
            [_completeTaskButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
            [_completeTaskButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

//设置按钮的圆角
-(void)setRounded
{
    //设置按钮的圆角
    //起始价格
    _startPriceText.layer.borderWidth = 1.f;
    _startPriceText.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _startPriceText.layer.cornerRadius = 4;
    _startPriceText.delegate = self;
    _endPriceText.layer.borderWidth = 1.f;
    _endPriceText.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _endPriceText.layer.cornerRadius = 4;
    _endPriceText.delegate = self;
    //当日
    _dayTimeButton.layer.borderWidth = 1.f;
    _dayTimeButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _dayTimeButton.layer.cornerRadius = 4;
    //当周
    _weekTimeButton.layer.borderWidth = 1.f;
    _weekTimeButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _weekTimeButton.layer.cornerRadius = 4;
    //当月
    _monthTimeButton.layer.borderWidth = 1.f;
    _monthTimeButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _monthTimeButton.layer.cornerRadius = 4;
    //任务
    _currentTaskButton.layer.borderWidth = 1.f;
    _currentTaskButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _currentTaskButton.layer.cornerRadius = 4;
    _completeTaskButton.layer.borderWidth = 1.f;
    _completeTaskButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _completeTaskButton.layer.cornerRadius = 4;
    //按钮
    _okButton.layer.borderWidth = 1.f;
    _okButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _okButton.layer.cornerRadius = 4;
    _resetButton.layer.borderWidth = 1.f;
    _resetButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _resetButton.layer.cornerRadius = 4;
    
}

-(void)tapBackGround
{
    //取消键盘
    [self cancelKeyboard];
//    if (parentView) {
//        [self cancelSelect:parentView];
//    }
}
//取消键盘
-(void)cancelKeyboard
{
    [self.startPriceText resignFirstResponder];
    [self.endPriceText resignFirstResponder];
}
#pragma mark ---
- (IBAction)dayClick:(id)sender {
    
    [_dayTimeButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
    [_dayTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_weekTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_weekTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_monthTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_monthTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    _dateType = FilterTimeTypeDay;
    
}

- (IBAction)weekClick:(id)sender {
    
    [_dayTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_dayTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_weekTimeButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
    [_weekTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_monthTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_monthTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    _dateType = FilterTimeTypeWeek;
    
}

- (IBAction)yearClick:(id)sender {
    
    [_dayTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_dayTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_weekTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_weekTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_monthTimeButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
    [_monthTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _dateType = FilterTimeTypeMonth;
    
}

- (IBAction)currentTaskClick:(id)sender {
    
    [_currentTaskButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
    [_currentTaskButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_completeTaskButton setBackgroundColor:[UIColor whiteColor]];
    [_completeTaskButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    _taskType = FilterTaskTypeCurrent;
}

- (IBAction)completeTaskClick:(id)sender {
    
    [_currentTaskButton setBackgroundColor:[UIColor whiteColor]];
    [_currentTaskButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_completeTaskButton setBackgroundColor:UIColorFromRGB(0xFF5A37)];
    [_completeTaskButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _taskType = FilterTaskTypeComplete;
}

- (IBAction)okClick:(id)sender {
    _startPrice = [_startPriceText.text floatValue];
    _endPrice = [_endPriceText.text floatValue];
    //回调协议
    if ([self.delegate respondsToSelector:@selector(taskFilterViewOK:selectEndPrice:selectFilterTimeType:selectFilterTaskType:)]) {
        [self.delegate taskFilterViewOK:_startPrice selectEndPrice:_endPrice selectFilterTimeType:_dateType selectFilterTaskType:_taskType];
    }
    
    [self cancelSelect:parentView];
}

- (IBAction)resetClick:(id)sender {
    
    _startPriceText.text = @"";
    _endPriceText.text = @"";
    [_dayTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_dayTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_weekTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_weekTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_monthTimeButton setBackgroundColor:[UIColor whiteColor]];
    [_monthTimeButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_currentTaskButton setBackgroundColor:[UIColor whiteColor]];
    [_currentTaskButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    [_completeTaskButton setBackgroundColor:[UIColor whiteColor]];
    [_completeTaskButton setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateNormal];
    
    //回调协议
    if ([self.delegate respondsToSelector:@selector(taskFilterViewViewReset)]) {
        [self.delegate taskFilterViewViewReset];
    }
    //消除筛选框
    [self cancelSelect:parentView];
}

#pragma mark ----

- (void)showInView:(UIView *) view
{
    self.tag = 11110;
    if ([view viewWithTag:11110]) {
        return;
    }
    
    parentView = view;
    
    [view addSubview:self];
    //全部视图
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    //容器视图
    [_contentView remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.bottom);
    }];
    
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(kContentHeight);
            make.bottom.equalTo(view);
        }];
        [view layoutIfNeeded];
    }];
}

- (void)cancelSelect:(UIView *) view
{
    //包含视图再设置取消
    if (![view viewWithTag:11110]) {
        return;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self);
            make.top.equalTo(self.bottom);
            make.height.equalTo(kContentHeight);
        }];
        [view layoutIfNeeded];
    }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}


#pragma mark -- - (void)textFieldDidEndEditing:(UITextField *)textField; 
//开始编辑的时候键盘遮住输入框
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    //转换到当前坐标
    //动画还原
    [UIView animateWithDuration:0.50f animations:^{
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(kContentHeight);
            make.bottom.equalTo(self).offset(-215);
        }];
    }];
}
//动画视图还原
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:_startPriceText])
    {
        _startPrice = [_startPriceText.text floatValue];
    }
    else if ([textField isEqual:_endPriceText])
    {
        _endPrice = [_endPriceText.text floatValue];
    }
    //动画还原
    [UIView animateWithDuration:0.50f animations:^{
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(kContentHeight);
            make.bottom.equalTo(self);
        }];
    }];
}
@end








