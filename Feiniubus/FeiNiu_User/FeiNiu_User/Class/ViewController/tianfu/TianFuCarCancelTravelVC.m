//
//  TianFuCarCancelTravelVC.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/11/9.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TianFuCarCancelTravelVC.h"

@interface TianFuCarCancelTravelVC ()<UITextViewDelegate>{
    
    UILabel *_placeholdLabel;
}

@property (strong, nonatomic) IBOutlet UIImageView *topImageView;

@property (strong, nonatomic) IBOutlet UIButton *firstButton;
@property (strong, nonatomic) IBOutlet UIButton *secondeButton;
@property (strong, nonatomic) IBOutlet UIButton *thirdButton;
@property (strong, nonatomic) IBOutlet UIButton *fourthButton;

@property (strong, nonatomic) IBOutlet UITextView *causeTextView;

@end

@implementation TianFuCarCancelTravelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- init property

- (void)initTextView{
    
    _placeholdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _causeTextView.frame.size.width, 40)];
    
    [_placeholdLabel setNumberOfLines:2];
    [_placeholdLabel setText:@"以上原因都不是，请填写具体原因，方便我们处理~"];
    [_placeholdLabel setFont:[UIFont systemFontOfSize:14]];
    [_placeholdLabel setTextColor:[UIColor grayColor]];
    
    [_causeTextView addSubview:_placeholdLabel];
}

#pragma mark -- Button Event

- (IBAction)submitOrderButtonClick:(id)sender {
    
}


#pragma mark -- textview delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (![text isEqualToString:@""]){
        
        _placeholdLabel.hidden = YES;
        
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1){
        
        _placeholdLabel.hidden = NO;
    }
    
    return YES;
}

@end
