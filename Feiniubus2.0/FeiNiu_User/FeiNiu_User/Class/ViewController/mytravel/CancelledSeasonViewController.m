//
//  CanceledSeasonViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CancelledSeasonViewController.h"
#import "CancelledViewController.h"
#import "FeedbackViewController.h"
#import "ContainerViewController.h"
#import "UINavigationView.h"
#import <FNUIView/PlaceHolderTextView.h>

#define DefaultStr @"还有什么想说的?"

@interface CancelledSeasonViewController () <UITextViewDelegate>
{
    NSString *reasonString;
}

@property (assign, nonatomic) NSInteger reasonIndex;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewCons;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;

@property (weak, nonatomic) IBOutlet UILabel *reason1;
@property (weak, nonatomic) IBOutlet UILabel *reason2;
@property (weak, nonatomic) IBOutlet UILabel *reason3;
@property (weak, nonatomic) IBOutlet UILabel *reason4;

@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UIImageView *img3;
@property (weak, nonatomic) IBOutlet UIImageView *img4;
@property (weak, nonatomic) IBOutlet PlaceHolderTextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *btnCommit;

@property (weak, nonatomic) IBOutlet UINavigationView *navView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeightCons;

@end

@implementation CancelledSeasonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    if (_isComplain) {
        _navView.title = @"投诉";
        _navView.rightTitle = @"";
        _labelHeightCons.constant = 0;
        
        _reason1.text = @"司机态度恶劣";
        _reason2.text = @"司机迟到";
        _reason3.text = @"司机危险驾驶";
        _reason4.text = @"乘车体验不好";
    }
}

- (void)initUI
{
     _textView.delegate = self;
    
    _reason1.textColor = UIColor_DefOrange;
    _img1.image = [UIImage imageNamed:@"checkbox_check"];
    
    reasonString = _reason1.text;
    _textView.placeHolder = @"有什么想说的";
    _textView.numberLimit = 50;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [_view1 addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [_view2 addGestureRecognizer:tap2];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [_view3 addGestureRecognizer:tap3];
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [_view4 addGestureRecognizer:tap4];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tapGesture:(UITapGestureRecognizer*)gesture
{
    UIView *view = gesture.view;
    if (view == _view1) {
        _reason1.textColor = UIColor_DefOrange;
        _reason2.textColor = [UIColor darkTextColor];
        _reason3.textColor = [UIColor darkTextColor];
        _reason4.textColor = [UIColor darkTextColor];
        
        _img1.image = [UIImage imageNamed:@"checkbox_check"];
        _img2.image = [UIImage imageNamed:@"checkbox"];
        _img3.image = [UIImage imageNamed:@"checkbox"];
        _img4.image = [UIImage imageNamed:@"checkbox"];
        
        reasonString = _reason1.text;
    }
    else if (view == _view2) {
        _reason1.textColor = [UIColor darkTextColor];
        _reason2.textColor = UIColor_DefOrange;
        _reason3.textColor = [UIColor darkTextColor];
        _reason4.textColor = [UIColor darkTextColor];
        
        _img1.image = [UIImage imageNamed:@"checkbox"];
        _img2.image = [UIImage imageNamed:@"checkbox_check"];
        _img3.image = [UIImage imageNamed:@"checkbox"];
        _img4.image = [UIImage imageNamed:@"checkbox"];
        
        reasonString = _reason2.text;
    }
    else if (view == _view3) {
        _reason1.textColor = [UIColor darkTextColor];
        _reason2.textColor = [UIColor darkTextColor];
        _reason3.textColor = UIColor_DefOrange;
        _reason4.textColor = [UIColor darkTextColor];
        
        _img1.image = [UIImage imageNamed:@"checkbox"];
        _img2.image = [UIImage imageNamed:@"checkbox"];
        _img3.image = [UIImage imageNamed:@"checkbox_check"];
        _img4.image = [UIImage imageNamed:@"checkbox"];
        
        reasonString = _reason3.text;
    }
    else if (view == _view4) {
        _reason1.textColor = [UIColor darkTextColor];
        _reason2.textColor = [UIColor darkTextColor];
        _reason3.textColor = [UIColor darkTextColor];
        _reason4.textColor = UIColor_DefOrange;
        
        _img1.image = [UIImage imageNamed:@"checkbox"];
        _img2.image = [UIImage imageNamed:@"checkbox"];
        _img3.image = [UIImage imageNamed:@"checkbox"];
        _img4.image = [UIImage imageNamed:@"checkbox_check"];
        
        reasonString = _reason4.text;
    }
    
    
}

#pragma mark -
-(void)navigationViewRightClick
{
    CancelledSeasonViewController *c = [CancelledSeasonViewController instanceWithStoryboardName:@"FeiniuOrder"];
    c.isComplain = YES;
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)btnBKClick:(id)sender {
    [_textView resignFirstResponder];
}

- (IBAction)btnCommitClick:(id)sender
{
    [self startWait];
    
    NSString *content = _textView.text;
    if (_textView.text && _textView.text.length > 0) {
        content = [NSString stringWithFormat:@"%@, %@", reasonString, _textView.text];
    }
    else {
        content = reasonString;
    }
    
    if (_isComplain) {    //投诉
//        [NetManagerInstance sendRequstWithType:EmRequestType_Feedback params:^(NetParams *params) {
//            params.method = EMRequstMethod_POST;
//            
//            params.data = @{@"phone": [UserPreferInstance getUserInfo].phone,
//                            @"content": content};
//        }];
    }
    else {    //取消原因
        [NetManagerInstance sendRequstWithType:EmRequestType_PostCancelReason params:^(NetParams *params) {
            params.method = EMRequstMethod_POST;
            params.data = @{@"orderId": _orderID,
                            @"content": content};
        }];
    }
    
}

- (IBAction)clickTapContentView:(UITapGestureRecognizer *)sender
{
    [_textView resignFirstResponder];
}


-(void)gotoCancelledViewController
{
//    ContainerViewController *container = (ContainerViewController *)[[UIApplication sharedApplication].keyWindow.rootViewController presentedViewController];
//    UINavigationController *nav = (UINavigationController *)container.contentViewController;
//    UIViewController *rootVC = [nav.viewControllers firstObject];
//    
//    CancelledViewController *next = [CancelledViewController instanceWithStoryboardName:@"FeiniuOrder"];
//    next.orderId = _orderID;
//    [nav setViewControllers:@[rootVC, next] animated:YES];
//    
//    [self.navigationController popToRootViewControllerAnimated:NO];
    

    CancelledViewController *next = [CancelledViewController instanceWithStoryboardName:@"FeiniuOrder"];
    next.orderId = _orderID;
    
    NSMutableArray *array =  [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [array removeObjectAtIndex:array.count-1];
    [array addObject:next];
    
    [self.navigationController setViewControllers:array animated:YES];

}

#pragma mark http
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    ResultDataModel *resultData = notification.object;
    if (resultData.type == EmRequestType_PostCancelReason) {    //取消订单原因
        [self stopWait];
        //[self performSegueWithIdentifier:@"CancelledViewController" sender:_orderID];
        [self gotoCancelledViewController];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
    }
    else if (resultData.type == EmRequestType_Feedback) {
        [self stopWait];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

#pragma mark-
- (void)keyboardWillShow:(NSNotification *)notif {
    
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
//    CGRect rectForSelfView = self.contentView.frame;
//    rectForSelfView.origin.y = -rect.size.height + 64;
//    self.contentView.frame = rectForSelfView;
    _contentViewCons.constant = -rect.size.height + 64;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2];
//    CGRect rectForSelfView = self.contentView.frame;
//    rectForSelfView.origin.y = 64;
//    self.contentView.frame = rectForSelfView;
    _contentViewCons.constant = 0;
    [UIView commitAnimations];
}


//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"CancelledViewController"]) {
//        CancelledViewController *controller = [segue destinationViewController];
//        controller.orderId = _orderID;
//    }
//}


@end
