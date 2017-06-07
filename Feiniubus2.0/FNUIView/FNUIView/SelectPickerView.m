//
//  PeopleTypeSelectorView.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/4/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "SelectPickerView.h"


#define KMainViewHeight     220
@interface SelectPickerView ()
{
//    __weak IBOutlet UIView *mainView;
//    __weak IBOutlet NSLayoutConstraint *mainViewBottom;
//    __weak IBOutlet UIPickerView *pickerView;
    
    
}

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIPickerView *pickerView;

@property(nonatomic, strong) SelectCallbackBlock completeBlock;

@property(nonatomic, strong) NSArray *items;
@end

@implementation SelectPickerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(void)showInView:(UIView*)view items:(NSArray*)items selectIndex:(NSInteger)selectIndex completion:(SelectCallbackBlock)completeBlock
{
    SelectPickerView * selView = [[SelectPickerView alloc] initWithFrameBlock:view.bounds items:items selIndex:selectIndex completion:completeBlock];
    [selView showInView:view];
}

-(instancetype)initWithFrameBlock:(CGRect)frame items:(NSArray*)items selIndex:(NSInteger)selIndex completion:(void (^)(NSInteger))completeBlock
{
    if (self = [super initWithFrame:frame]) {
        //self = [[[NSBundle mainBundle] loadNibNamed:@"SelectPickerView" owner:self options:nil] firstObject];
        self = [[SelectPickerView alloc] init];
        //self.frame = frame;
        
        _items = [NSArray arrayWithArray:items];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        //移入底部
        //mainViewBottom.constant = - self.fs_height;
        //[self layoutIfNeeded];
        self.completeBlock = completeBlock;
        //可能出现 -1 出现判断
        if (selIndex > 0 && selIndex< items.count) {
            [_pickerView selectRow:selIndex inComponent:0 animated:YES];
        }
    }
    return self;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    self.backgroundColor = UITranslucentBKColor;
    
    _mainView = [[UIView alloc] init];
    _mainView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_mainView];
    
    [_mainView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.top.equalTo(self.bottom);
        make.height.equalTo(220);
    }];
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = UIColorFromRGB(0xf4f4f4);
    [_mainView addSubview:topView];
    
    [topView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_mainView.left);
        make.top.equalTo(_mainView.top);
        make.right.equalTo(_mainView.right);
        make.height.equalTo(40);
    }];
    
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancleAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:btnCancel];
    
    [btnCancel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(15);
        make.width.equalTo(50);
        make.height.equalTo(30);
        make.centerY.equalTo(topView);
    }];
    
    UIButton *btnOK = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnOK setTitle:@"确定" forState:UIControlStateNormal];
    [btnOK setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
    [btnOK addTarget:self action:@selector(clickCompleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:btnOK];
    
    [btnOK makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topView.right).offset(-15);
        make.width.equalTo(50);
        make.height.equalTo(30);
        make.centerY.equalTo(topView);
    }];
    
    _pickerView = [[UIPickerView alloc] init];
    [_mainView addSubview:_pickerView];
    
    [_pickerView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_mainView.left);
        make.right.equalTo(_mainView.right);
        make.top.equalTo(topView.bottom);
        make.bottom.equalTo(_mainView.bottom);
    }];
}


- (IBAction)cancleAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        
        [_mainView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self);
            make.top.equalTo(self.bottom);
            make.height.equalTo(KMainViewHeight);
        }];
        
        [self layoutIfNeeded];
    }
     completion:^(BOOL finished){
         [self removeFromSuperview];
     }];
}
- (IBAction)clickCompleteAction:(UIButton *)sender
{
    if (_completeBlock) {
        self.completeBlock([_pickerView selectedRowInComponent:0]);
    }
    [self cancleAction:nil];
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [view layoutIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_mainView remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.width.equalTo(self);
            make.top.equalTo(self.bottom).offset(-KMainViewHeight);
            make.height.equalTo(KMainViewHeight);
        }];
        
        [self layoutIfNeeded];
    }];
}
- (void)hideInView:(UIView *)view
{
    [self cancleAction:nil];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
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
    return _items.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{

    return _items[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            break;
        default:
            break;
    }
}

@end
