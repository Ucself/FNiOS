//
//  MainMenuViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/7/30.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import "MainMenuViewController.h"
#import "FeedbackViewController.h"
#import "PushNotificationAdapter.h"

#import <FNUIView/REFrostedViewController.h>
#import <FNNetInterface/PushConfiguration.h>
#import <FNNetInterface/AFNetworking.h>
#import <FNUIView/UIViewController+REFrostedViewController.h>
#import <FNNetInterface/UIImageView+AFNetworking.h>

#import "UIColor+Hex.h"
#import "LoginViewController.h"
#import "User.h"
#import "CarpoolTravelStateViewController.h"
#import "TravelHistoryViewController.h"

@interface MainMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet UIView *topView;

@property (strong, nonatomic) UIImageView *headImg;   //头像
//@property (strong, nonatomic) UIButton *btnLogin;     //登录侒扭
@property (strong, nonatomic) UILabel *labelUserName;
@property (strong, nonatomic) UILabel *labelCouponNum;      //优惠券张数
@property (strong, nonatomic) UILabel *labelMileage;      //累计里程

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *array;

@end

@implementation MainMenuViewController

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"menu dealloc");
}

+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Me" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"MainMenuViewController"];
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupNavigationBar];

    [self requestUserInfo];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];

    //judge network status
    if ([NetManagerInstance reach] == AFNetworkReachabilityStatusNotReachable) {
        
        [self showAlertView:@"暂无网络"];
        
    }
    
    //image source
    self.array = @[@[@{@"img":@"yaoqing_icon", @"text":@"邀请好友"},
                     @{@"img":@"Historical_journey_icon", @"text":@"订单管理"}],
                   @[@{@"img":@"tousu_icon", @"text":@"我要投诉"},
                     @{@"img":@"jianyi_icon", @"text":@"意见建议"}],
                   @[@{@"img":@"set_icon", @"text":@"设置"}]];
//    self.array = @[@[@{@"img":@"Historical_journey_icon", @"text":@"订单管理"}],
//                   @[@{@"img":@"tousu_icon", @"text":@"我要投诉"},
//                     @{@"img":@"jianyi_icon", @"text":@"意见建议"}],
//                   @[@{@"img":@"set_icon", @"text":@"设置"}]];
    _headImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_center_head_1"]];
    [_headImg setBounds:CGRectMake(0, 0, 60, 60)];
    [self roundImageView:_headImg];
    self.tableView.tableHeaderView = [self createHeaderView];//设置头像
    
//    [self setupNavigationBar];
    self.title = @"个人中心";
}

- (void)viewDidLayoutSubviews
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self requestUserInfo];

//    [self registerNotification];
    
    self.user = [[UserPreferences sharedInstance] getUserInfo];
    if (!self.user.name) {
        [self requestUserInfo];
    }else{
        [self getUserInfomation];
    }
    [self setupNavigationBar];
    
    //self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)fixOrientation1:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (void)getUserInfomation{

    if (_user.avatar) {
        
        [_headImg setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,_user.avatar]] placeholderImage:[UIImage imageNamed:@"my_center_head_1"]];
//        
//        _headImg.image = [UIImage imageWithCGImage:_headImg.image.CGImage scale:1 orientation:UIImageOrientationRight];
        
    }else{
        [_headImg setImage:[UIImage imageNamed:@"my_center_head_1"]];
    }

    if (_user.name) {
        
        _labelUserName.text = _user.name;
        
    }else if(_user.phone){
        
        _labelUserName.text = _user.phone;
    }
}

- (void)setupNavigationBar {
    
    //[self.navigationController.navigationBar setBarTintColor:UIColor_DefGreen];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:GloabalTintColor]];
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
//    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
//    self.navigationController.navigationBar.clipsToBounds = YES;
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbkgreen"] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    
    //    UIImage *image = [UIImage imageNamed:@"my_icon"];
    //    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    //
    //    UIButton *btnLeft = [[UIButton alloc] initWithFrame:buttonFrame];
    //    [btnLeft addTarget:self action:@selector(btnMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [btnLeft setImage:image forState:UIControlStateNormal];
    //
    //    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    //    self.navigationItem.leftBarButtonItem = item;
    
    UIImage *image = [UIImage imageNamed:@"remind_icon"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width-5, image.size.height-5);
    UIButton *btnRight = [[UIButton alloc] initWithFrame:buttonFrame];
    [btnRight addTarget:self action:@selector(btnMessageClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight setImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = item;
    
    UIImageView *redDotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(btnRight.frame.size.width - 5, 0, 5, 5)];
    [redDotImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [redDotImageView.layer setBorderWidth:1];
    [redDotImageView.layer setCornerRadius:2.5];
    [redDotImageView setImage:[UIImage imageNamed:@"dot_red"]];
    [btnRight addSubview:redDotImageView];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [redDotImageView setHidden:NO];
    }else{
        [redDotImageView setHidden:YES];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     BaseUIViewController* controller = segue.destinationViewController;
    
    if ([controller isKindOfClass:[FeedbackViewController class]]) {
        FeedbackViewController *c = (FeedbackViewController*)controller;
        
        NSNumber *obj = (NSNumber*) sender;
        c.feedType = [obj intValue];
    }
    
}

- (void)roundImageView:(UIImageView*)imageView
{
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 3.0f;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
//    imageView.layer.shouldRasterize = YES;
    imageView.clipsToBounds = YES;
}

-(UIView*)createHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 180)];
    view.backgroundColor = [UIColor colorWithHex:GloabalTintColor];
    
    //[_headImg setBackgroundColor:[UIColor whiteColor]];
    
    [view addSubview:_headImg];
    [_headImg makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(60);
        make.width.equalTo(60);
        make.top.equalTo(10);
        make.centerX.equalTo(view);
    }];

    UIButton *btnbk = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnbk addTarget:self action:@selector(btnSelfInfo:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnbk];
    [btnbk makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(60);
        make.width.equalTo(60);
        make.top.equalTo(10);
        make.centerX.equalTo(view);
    }];
    
    _labelUserName = [[UILabel alloc] init];;
    _labelUserName.textColor = [UIColor whiteColor];
    _labelUserName.font = [UIFont systemFontOfSize:15];
    _labelUserName.textAlignment = NSTextAlignmentCenter;
    [view addSubview:_labelUserName];
    [_labelUserName makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(35);
        make.width.equalTo(150);
        make.top.equalTo(btnbk.bottom);
        make.centerX.equalTo(view);
    }];
    
    
    //底部view
    UIView *btmView = [[UIView alloc] init];
    btmView.backgroundColor = [UIColor whiteColor];
    [view addSubview:btmView];
    
    [btmView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view.bottom);
        make.left.equalTo(view.left);
        make.height.equalTo(65);
        make.width.equalTo(view);
    }];
    
    UIView *leftView = [[UIView alloc] init];
    //leftView.backgroundColor = [UIColor yellowColor];
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCouponsView:)];
    [leftView addGestureRecognizer:gesture];
    [btmView addSubview:leftView];
    
    UIView *rightView = [[UIView alloc] init];
    //rightView.backgroundColor = [UIColor darkGrayColor];
    [btmView addSubview:rightView];
    
    [rightView makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view.right);
        make.bottom.equalTo(view.bottom);
        make.height.equalTo(60);
        make.width.equalTo(leftView);
        make.left.equalTo(leftView.right);
    }];
    
    [leftView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.left);
        make.bottom.equalTo(view.bottom);
        make.height.equalTo(60);
        //make.width.equalTo(btnCoupon);
        make.right.equalTo(rightView.left);
    }];
    
    
    //左边按钮
    UIImageView *imgLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_ticket_icon"]];
    [leftView addSubview:imgLeft];
    
    [imgLeft makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(15);
        make.centerY.equalTo(leftView);
        make.height.equalTo(32);
        make.width.equalTo(32);
    }];
    
    UILabel *labelStatic = [UILabel new];
    labelStatic.textAlignment = NSTextAlignmentCenter;
    labelStatic.font = [UIFont systemFontOfSize:14];
    labelStatic.text = @"可用优惠券";
    [leftView addSubview:labelStatic];
    
    [labelStatic makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgLeft.right).offset(10);
        make.top.equalTo(imgLeft).offset(-3);
        make.width.equalTo(80);
        make.height.equalTo(20);
    }];
    
    _labelCouponNum = [UILabel new];
    _labelCouponNum.textAlignment = NSTextAlignmentCenter;
    _labelCouponNum.font = [UIFont systemFontOfSize:13];
    _labelCouponNum.textColor = UIColorFromRGB(0xF7582C);
    _labelCouponNum.text = @"0张";
    [leftView addSubview:_labelCouponNum];
    
    [_labelCouponNum makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgLeft.right).offset(10);
        make.top.equalTo(labelStatic.bottom);
        make.width.equalTo(80);
        make.height.equalTo(20);
    }];
    
    //右边按钮
    UIImageView *imgRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"licheng_icon"]];
    [rightView addSubview:imgRight];
    
    [imgRight makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(15);
        make.centerY.equalTo(rightView);
        make.height.equalTo(32);
        make.width.equalTo(32);
    }];
    
    labelStatic = [UILabel new];
    labelStatic.textAlignment = NSTextAlignmentCenter;
    labelStatic.font = [UIFont systemFontOfSize:14];
    labelStatic.text = @"累计里程";
    [rightView addSubview:labelStatic];
    
    [labelStatic makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgRight.right).offset(10);
        make.top.equalTo(imgRight).offset(-3);
        make.width.equalTo(70);
        make.height.equalTo(20);
    }];
    
    _labelMileage = [UILabel new];
    _labelMileage.textAlignment = NSTextAlignmentCenter;
    _labelMileage.font = [UIFont systemFontOfSize:13];
    _labelMileage.textColor = UIColorFromRGB(0xF7BA5B);
    _labelMileage.text = @"0km";
    [rightView addSubview:_labelMileage];
    
    [_labelMileage makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgRight.right).offset(10);
        make.top.equalTo(labelStatic.bottom);
        make.width.equalTo(70);
        make.height.equalTo(20);
    }];
    
    return view;
}

#pragma mark-
- (void)btnLoginClick:(id)sender
{
    LoginViewController *c = [[self storyboard] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)btnSelfInfo:(id)sender {
    [self performSegueWithIdentifier:@"touserinfo" sender:nil];
}

- (IBAction)btnBackClick:(id)sender {

    [self.frostedViewController hideMenuViewController];
}

- (void)tapCouponsView:(UITapGestureRecognizer *)paramSender
{
    [self performSegueWithIdentifier:@"tocoupons" sender:nil];
}

- (IBAction)btnMessageClick:(id)sender {
    [self performSegueWithIdentifier:@"tomessage" sender:nil];
}
#pragma mark - 

- (void)setUser:(User *)user{
    _user = user;
    self.labelUserName.text = _user.name;
    self.labelCouponNum.text = [NSString stringWithFormat:@"%@ 张", _user.couponsAmount];
    self.labelMileage.text = [NSString stringWithFormat:@"%@ KM", _user.accumulateMileage];
}
#pragma mark - 
- (void)requestUserInfo{
//    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_GetUserInfo params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
    }];
}
#pragma mark - RequestCallBack
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_GetUserInfo) {
        
        NSDictionary *member = resultData.data[@"member"];
        
        User *user = [[User alloc]initWithDictionary:member];
        
        self.user = user;
        
        [self getUserInfomation];
        
        [[UserPreferences sharedInstance] setUserInfo:user];
        
//      [self getUserInfomation];//获取用户信息
        
    }
    
}

- (void)httpRequestFailed:(NSNotification *)notification{
    [self stopWait];
    
    NSDictionary *dict = notification.object;
    NSError *error = [dict objectForKey:@"error"];
    
    DBG_MSG(@"httpRequestFailed: error = %@", error);
    
    if (error.code == 401 || error.code == 403) {
        //        [self showTipsView:@"鉴权失效，请登录！"];
        //鉴权失效重置token
        [[UserPreferences sharedInstance] setToken:nil];
        [[UserPreferences sharedInstance] setUserId:nil];
        
        // 进入登录界面
        [LoginViewController presentAtViewController:self.frostedViewController needBack:YES requestToHomeIfCancel:YES completion:^{
            
        } callBalck:^(BOOL isSuccess, BOOL needToHome) {
            if (!isSuccess) {
                [self btnBackClick:nil];
            }else{
                [self requestUserInfo];
            }
        }];
        
        //重置别名
        [[PushConfiguration sharedInstance] resetAlias];
    }else{
        [self showTip:error.localizedDescription WithType:FNTipTypeFailure];
    }
}

#pragma mark-
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 50;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 2;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section == 0) {
//        return 3;
//    }
//    else if (section == 1) {
//        return 2;
//    }
//    else if (section == 2) {
//        return 1;
//    }
//    return 0;
    return [self.array[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
 
    cell = [tableView dequeueReusableCellWithIdentifier:@"mainmenutableviewcell"];
    //cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    cell.detailTextLabel.text = @"";
    if (indexPath.section == 0) {
        NSDictionary *dcit = self.array[0][indexPath.row];
        cell.textLabel.text = [dcit objectForKey:@"text"];
        cell.imageView.image = [UIImage imageNamed:[dcit objectForKey:@"img"]];
        
//        if (indexPath.row == 0) {
//           cell.detailTextLabel.text = @"推荐好友,立即免单";
//            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
//            cell.detailTextLabel.textColor = [UIColor grayColor];
//        }
        
        
    }
    else if (indexPath.section == 1) {
        NSDictionary *dcit = self.array[1][indexPath.row];
        cell.textLabel.text = [dcit objectForKey:@"text"];
        cell.imageView.image = [UIImage imageNamed:[dcit objectForKey:@"img"]];
    }
    else if (indexPath.section == 2) {
        NSDictionary *dcit = self.array[2][indexPath.row];
        cell.textLabel.text = [dcit objectForKey:@"text"];
        cell.imageView.image = [UIImage imageNamed:[dcit objectForKey:@"img"]];
    }
    
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //DBG_MSG(@"select row %ld", indexPath.row);
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"toshare" sender:nil];
            }
            else if (indexPath.row == 1) {
//                [self performSegueWithIdentifier:@"tomystroke" sender:nil];
                [self.navigationController pushViewController:[TravelHistoryViewController instanceFromStoryboard] animated:YES];
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"tofeedback" sender:[NSNumber numberWithInt:FeedbackType_Complain]];
            }
            else if (indexPath.row == 1) {
                [self performSegueWithIdentifier:@"tofeedback" sender:[NSNumber numberWithInt:FeedbackType_Suggest]];
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"tomore" sender:nil];
            }
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark -- register notification

//- (void)registerNotification{
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPromptAnimation:) name:@"showPrompt" object:nil];
//}

#pragma mark -- prompt animation

- (void)showAlertView:(NSString *)text{
    
//    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];
//    [self.view addSubview:hud];
//    
//    [hud show:YES];
//    [hud setLabelText:text];
//    [hud setMode:MBProgressHUDModeText];
//    [hud hide:YES afterDelay:2];
//    
//    if (hud.hidden == YES) {
//        [hud removeFromSuperview];
//    }
}

//- (void)showPromptAnimation:(NSNotification *)notification{
//
//    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];
//    [self.view addSubview:hud];
//    
//    [hud show:YES];
//    [hud setLabelText:notification.object[@"content"]];
//    [hud setMode:MBProgressHUDModeText];
//    [hud hide:YES afterDelay:2];
//    
//    if (hud.hidden == YES) {
//        [hud removeFromSuperview];
//    }
//}

@end
