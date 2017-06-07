//
//  CustomTicketView.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CustomTicketView.h"
#import <FNUIView/FNUIView.h>

#define  kContentHeight    242
#define GRAY_COLOR [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1]
#define SelectedColor [UIColor colorWithRed:254/255.0 green:113/255.0 blue:75/255.0 alpha:1]

@interface CustomTicketView()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) UIView *sView;
@property (weak, nonatomic) IBOutlet UIView   *contentView;
@property (weak, nonatomic) IBOutlet UIView   *parentView;
@property (weak, nonatomic) IBOutlet UIView   *childView;
@property (weak, nonatomic) IBOutlet UILabel  *parentLabel;
@property (weak, nonatomic) IBOutlet UILabel  *childLabel;
@property (weak, nonatomic) IBOutlet UIButton *parentAddButton;
@property (weak, nonatomic) IBOutlet UIButton *parentRemoveButton;
@property (weak, nonatomic) IBOutlet UIButton *childAddButton;
@property (weak, nonatomic) IBOutlet UIButton *childRemoveButton;
@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (strong, nonatomic) NSArray *pickViewDataSource;

@end
@implementation CustomTicketView

+ (instancetype)instance
{
    CustomTicketView *view = [CustomTicketView loadFromNIB];
    return view;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [_contentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(0);
        make.width.equalTo(self);
        make.top.equalTo(self.bottom);
        make.height.equalTo(kContentHeight);
    }];
    
    [self initPickerView];
    
    self.parentView.layer.borderColor = UIColorFromRGB(0xe0e0e0).CGColor;
    self.childView.layer.borderColor = UIColorFromRGB(0xe0e0e0).CGColor;
    
//    [_peopleNumPickeView reloadAllComponents];

}

- (void)setParentAmount:(NSUInteger)parentAmount
{
    _parentAmount = parentAmount;
    if (parentAmount != 0) {
        [self setTitleText];
        self.parentLabel.text = [NSString stringWithFormat:@"%@",@(self.parentAmount)];
        [_parentRemoveButton setBackgroundColor:SelectedColor];
    }
    
    [_peopleNumPickerView selectRow:_parentAmount-1 inComponent:0 animated:YES];

}

- (void)setChildAmount:(NSUInteger)childAmount
{
    _childAmount = childAmount;
    if (childAmount != 0) {
        self.childLabel.text  = [NSString stringWithFormat:@"%@",@(self.childAmount)];
        [_childRemoveButton setBackgroundColor:SelectedColor];
        
        [self setTitleText];
    }
}

- (void)setTitleText
{
    
    self.titleLabel.text = @"出行人数";
    
//    if (self.parentAmount != 0 && self.childAmount != 0) {
//        
////        self.titleLabel.text = [NSString stringWithFormat:@"出行人数(%@),儿童票%@张",@(self.parentAmount),@(self.childAmount)];
//        
//    }else if (self.parentAmount != 0){
//        
////        self.titleLabel.text = [NSString stringWithFormat:@"出行人数(%@)",@(self.parentAmount)];
//        
//    }else if (self.childAmount != 0){
//        
////        self.titleLabel.text = [NSString stringWithFormat:@"%@张票",@(self.childAmount)];
//        
////    }else{
////        
////        self.titleLabel.text = @"出行人数";
////    }
}
#pragma mark -- init UserInterface

- (void)initPickerView{

    _pickViewDataSource = @[@"1",@"2",@"3",@"4",@"5"];
    
    [_peopleNumPickerView setDelegate:self];
    [_peopleNumPickerView setDataSource:self];

    [self.contentView addSubview:_peopleNumPickerView];
    
}


#pragma mark -- Function Methods
+ (NSString *)getTicketNum:(NSUInteger)parentAmount childAmount:(NSUInteger)childAmount
{
    NSString *str;
    
    if (parentAmount != 0 && childAmount != 0) {
        
        str = [NSString stringWithFormat:@"%@人  儿童票%@张",@(parentAmount),@(childAmount)];
        
    }else if (parentAmount != 0){
        
        str = [NSString stringWithFormat:@"%@人",@(parentAmount)];
        
    }else if (childAmount != 0){
        
        str = [NSString stringWithFormat:@"%@人",@(childAmount)];
        
    }else{
        
        str = @"出行人数";
    }
    
    return str;
}

- (void)showInView:(UIView *) view
{
    self.sView = view;
    self.tag = 111;
    if ([self.sView  viewWithTag:111]) {
        return;
    }
    
    [self.sView  addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sView);
    }];
    [self.sView  layoutIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self.sView );
            make.top.equalTo(self.sView .bottom).offset(-kContentHeight);
            make.height.equalTo(kContentHeight);
        }];
        
        [self.sView  layoutIfNeeded];
    }];
    
    if (self.parentAmount + self.childAmount == 5) {
        
        [self.parentAddButton setBackgroundColor:GRAY_COLOR];
        [self.childAddButton  setBackgroundColor:GRAY_COLOR];
    }
    
    if (self.childAmount == 2) {
        
        [self.childAddButton setBackgroundColor:GRAY_COLOR];
    }
    
}

- (void)cancelPicker:(UIView *) view
{
    //如果传入的视图不是父视图
    if (![self.sView isEqual:view]) {
        return;
    }
    //包含视图再设置取消
    if (![self.sView  viewWithTag:111]) {
        return;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self);
            make.top.equalTo(self.bottom);
            make.height.equalTo(kContentHeight);
        }];
        
        [self layoutIfNeeded];
        
    }completion:^(BOOL finished){
        
         [self removeFromSuperview];
         
    }];
}

-(IBAction)btnCancelClick:(id)sender
{
    //取消视图
    [self cancelPicker:self.sView];
    //协议返回
    if ([self.delegate respondsToSelector:@selector(pickerTicketViewCancel)]) {
        [self.delegate pickerTicketViewCancel];
    }
}

-(IBAction)btnOKClick:(id)sender
{
    if (_parentAmount == 0) {
        _parentAmount = 1;
        _customRow    = 0;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerTicketViewOKParentAmount:childAmount:customTicketView:)])
    {
        [self.delegate pickerTicketViewOKParentAmount:self.parentAmount childAmount:self.childAmount customTicketView:self];
    }
    //取消视图
    [self cancelPicker:self.sView];
}

- (IBAction)clickBackGround:(id)sender {
    [self btnCancelClick:nil];
}

- (IBAction)removeParentTicket:(id)sender {
    
    if (self.parentAmount == 0) {
        
        return;
        
    }else if(self.parentAmount == 1){
        
        [self.parentRemoveButton setBackgroundColor:GRAY_COLOR];
    }
    
    self.parentAmount--;
    
    if (self.parentAmount + self.childAmount < 5) {
        
        if (self.childAmount < 2) {
            
          [self.childAddButton setBackgroundColor:SelectedColor];
        }
        
        [self.parentAddButton setBackgroundColor:SelectedColor];
        
    }
    
    if (self.parentAmount < self.childAmount) {
        
        self.childAmount = self.parentAmount;
        
        [self.childAddButton setBackgroundColor:SelectedColor];
        
        self.childLabel.text = [NSString stringWithFormat:@"%@",@(self.parentAmount)];
        
        if (self.parentAmount == 0) {
            
            [self.childRemoveButton setBackgroundColor:GRAY_COLOR];
        }
    }
    
    self.parentLabel.text = [NSString stringWithFormat:@"%@",@(self.parentAmount)];
    [self setTitleText];
}

- (IBAction)addParentTicket:(id)sender {
    
    if (self.parentAmount == 5) {
        
        return;
    }
    
    if (self.parentAmount + self.childAmount >= 5) {
        
        return;
    }
    
    self.parentAmount++;
    
    [self.parentRemoveButton setBackgroundColor:SelectedColor];
    [self.parentAddButton setBackgroundColor:SelectedColor];
    
    if (self.parentAmount == 5) {
        
        [self.parentAddButton setBackgroundColor:GRAY_COLOR];
        [self.childAddButton setBackgroundColor:GRAY_COLOR];
    }
    
    if (self.parentAmount + self.childAmount >= 5) {
        
        [self.parentAddButton setBackgroundColor:GRAY_COLOR];
        [self.childAddButton setBackgroundColor:GRAY_COLOR];
    }

    self.parentLabel.text = [NSString stringWithFormat:@"%@",@(self.parentAmount)];
    [self setTitleText];
}

- (IBAction)removeChildTicket:(id)sender {
    
    if (self.childAmount == 0) {
        
        return;
        
    }else if(self.childAmount == 1){
        
        [self.childRemoveButton setBackgroundColor:GRAY_COLOR];
    }
    
    self.childAmount--;
    
    if (self.parentAmount + self.childAmount < 5) {
        
        [self.childAddButton setBackgroundColor:SelectedColor];
        
        
        [self.parentAddButton setBackgroundColor:SelectedColor];
        
    }
    
    self.childLabel.text = [NSString stringWithFormat:@"%@",@(self.childAmount)];
    [self setTitleText];
}

- (IBAction)addChildTicket:(id)sender {
    
    if (self.childAmount == 2) {
        
        return;
    }
    
    if (self.parentAmount + self.childAmount == 5) {
        
        return;
    }
    
    self.childAmount++;
    
    [self.childRemoveButton setBackgroundColor:SelectedColor];
    [self.childAddButton    setBackgroundColor:SelectedColor];
    
    if (self.childAmount == 2) {
        
        [self.childAddButton setBackgroundColor:GRAY_COLOR];
    }
    
    if (self.parentAmount + self.childAmount >= 5) {
        
        [self.parentAddButton setBackgroundColor:GRAY_COLOR];
        [self.childAddButton  setBackgroundColor:GRAY_COLOR];
    }
    
    if (self.parentAmount < self.childAmount) {
        
        self.parentAmount = self.childAmount;
        
        self.parentLabel.text = [NSString stringWithFormat:@"%@",@(self.parentAmount)];
    }
    
    self.childLabel.text = [NSString stringWithFormat:@"%@",@(self.childAmount)];
    [self setTitleText];
}

#pragma mark -- UIPickerViewDelegate and DataSource


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    [_titleLabel setText:[NSString stringWithFormat:@"出行人数(%@)",_pickViewDataSource[row]]];
    
    self.parentAmount = [_pickViewDataSource[row] integerValue];
    
    _customRow = row;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [_pickViewDataSource count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return _pickViewDataSource[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 40;
}

@end
