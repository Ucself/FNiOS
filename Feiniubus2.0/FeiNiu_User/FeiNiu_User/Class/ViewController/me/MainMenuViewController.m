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
#import "PushConfiguration.h"
#import <FNNetInterface/AFNetworking.h>
#import <FNUIView/UIViewController+REFrostedViewController.h>
#import <FNUIView/FXBlurView.h>
#import <FNUIView/UIColor+Hex.h>
#import "LoginViewController.h"

#import "AuthorizeCache.h"
#import "UserPreferences.h"

#import "FeiNiu_User-Swift.h"

@interface MainMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *phone;

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *array;


//适配iphone5
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headImgLeftCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowRightCons;

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];

    
    //image source
    self.array = @[@{@"img":@"icon_PC_my_schedule",
                     @"text":@"我的行程"},
                   @{@"img":@"icon_PC_ticket",
                     @"text":@"我的车票"},
                   @{@"img":@"icon_PC_privilege",
                     @"text":@"优惠券"},
                   @{@"img":@"icon_PC_road_24*22",
                     @"text":@"申请线路"},
//                   @{@"img":@"icon_PC_gift",
//                     @"text":@"邀请有奖"},
//                   @{@"img":@"icon_PC_activity_center",
//                     @"text":@"活动中心"},
                   @{@"img":@"icon_PC_more",
                     @"text":@"更多"},
                   
//                   @{@"img":@"menu_ico_coupon",
//                     @"text":@"优惠券"},
//                   @{@"img":@"menu_ico_share",
//                     @"text":@"邀请有奖"},
//                   @{@"img":@"menu_ico_message",
//                     @"text":@"消息中心"},
//                   @{@"img":@"menu_ico_suggest",
//                     @"text":@"投诉建议"},
//                   @{@"img":@"menu_ico_help",
//                     @"text":@"常见问题帮助"},
//                   @{@"img":@"menu_ico_contact",
//                     @"text":@"联系客服"},
//                   @{@"img":@"menu_ico_set",
//                     @"text":@"设置"},
//                   @{@"img":@"menu_ico_set",
//                     @"text":@"线路申请"},
//                   @{@"img":@"menu_ico_set",
//                     @"text":@"通勤车状态测试"},
//                   @{@"img":@"menu_ico_set",
//                     @"text":@"通勤车评价测试"},
                   ];


//    NSString *token = [[AuthorizeCache sharedInstance] getAccessToken];
//    if (token && token.length != 0) {
//        [self requestUserInfo];
//    }


}

- (void)initUI
{
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    
//    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
//    
//    FXBlurView *blurView = [[FXBlurView alloc] init];
//    blurView.dynamic = NO;
//    blurView.blurRadius = 40;
//    blurView.tintColor = UIColorFromRGB(0x26547b);
//    [self.view addSubview:blurView];
//    [self.view sendSubviewToBack:blurView];
//    [blurView makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headViewClick:)];
    [self.headView addGestureRecognizer:tap];
    
    
    if (deviceHeight < 667) {
        _headImgLeftCons.constant = 20;
        _arrowRightCons.constant = 10;
    }
}

- (void)viewDidLayoutSubviews
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.user = [UserPreferInstance getUserInfo];
    NSString *token = [[AuthorizeCache sharedInstance] getAccessToken];
    if (token && token.length!=0) {
        if (!self.user.name) {
            [self requestUserInfo];
        }else{
            [self setUserViews];
        }
    }
    
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



- (void)setUserViews{

    UIImage *defaultImag = [_user.gender isEqualToString:@"Female"]  ? [UIImage imageNamed:@"icon_woman_122*122"] : [UIImage imageNamed:@"icon_man_122*122"];
    
    if (_user.avatar) {
        [self.headImg setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:defaultImag];
    }else {
        [_headImg setImage:defaultImag];
    }
    
    _headImg.image = [self fixOrientation:_headImg.image];
    [self roundImageView:_headImg];

    if (_user.name) {
        
        _userName.text = _user.name;
        
    }else if(_user.phone){
        
        _phone.text = _user.phone;
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

- (void)roundImageView:(UIImageView*)imageView
{
    int radiuis = imageView.frame.size.width / 2;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = radiuis;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 0.0f;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
//    imageView.layer.shouldRasterize = YES;
    imageView.clipsToBounds = YES;
}

#pragma mark-
- (void)btnLoginClick:(id)sender
{
    LoginViewController *c = [[self storyboard] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.navigationController pushViewController:c animated:YES];
}

-(void)headViewClick:(id)sender
{
    //[self.frostedViewController hideMenuViewController];
    [[NSNotificationCenter defaultCenter] postNotificationName:KMenuDidSelectNotification object:[NSNumber numberWithInteger:11]];
}


#pragma mark-

- (void)setUser:(User *)user{
    _user = user;
    self.userName.text = _user.name;
    self.phone.text = _user.phone;
}
#pragma mark-
- (void)requestUserInfo{
//    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_GetAccount params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
    }];
}

#pragma mark - RequestCallBack
- (void)httpRequestFinished:(NSNotification *)notification{
    
    [super httpRequestFinished:notification];
    [self stopWait];
    
    ResultDataModel *result = (ResultDataModel *)notification.object;
    if (result.type == EmRequestType_GetAccount) {
        
        User *user = [User mj_objectWithKeyValues:result.data];//[[User alloc]initWithDictionary:member];
        self.user = user;
        
        
        [self setUserViews];
        [UserPreferInstance setUserInfo:user];
    }
    else if (result.type == EmRequestType_CommuteApplyGet) {
        NSDictionary *dict = (NSDictionary*)result.data;
        if (dict.count == 0) {
            //申请页面
            [[NSNotificationCenter defaultCenter] postNotificationName:KMenuDidSelectNotification object:[NSNumber numberWithInteger:3]];
        }
        else {
            //申请过的页面
            [[NSNotificationCenter defaultCenter] postNotificationName:KMenuDidSelectNotification
                                                                object:[NSNumber numberWithInteger:10]
                                                              userInfo:@{@"homeAddr":dict[@"on_address"],
                                                                         @"componyAddr":dict[@"off_address"],
                                                                         @"onworkTime":dict[@"on_duty_time"],
                                                                         @"offworkTime":dict[@"off_duty_time"]}];
        }
    }

}

- (void)httpRequestFailed:(NSNotification *)notification{
    return [super httpRequestFailed:notification];
//    [self stopWait];
//    
//    NSDictionary *dict = notification.object;
//    NSError *error = [dict objectForKey:@"error"];
//    
//    DBG_MSG(@"httpRequestFailed: error = %@", error);
//    
//    if (error.code == 401 || error.code == 403) {
//        //        [self showTipsView:@"鉴权失效，请登录！"];
//        //鉴权失效重置token
//        [UserPreferInstance setToken:nil];
//        [UserPreferInstance setUserId:nil];
//        
//        // 进入登录界面
//        [LoginViewController presentAtViewController:self.frostedViewController needBack:YES requestToHomeIfCancel:YES completion:^{
//            
//        } callBalck:^(BOOL isSuccess, BOOL needToHome) {
//            if (!isSuccess) {
//                [self btnBackClick:nil];
//            }else{
//                [self requestUserInfo];
//            }
//        }];
//        
//        //重置别名
//        [[PushConfiguration sharedInstance] resetAlias];
//    }else{
//        [self showTip:error.localizedDescription WithType:FNTipTypeFailure];
//    }
}

#pragma mark-
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
 
    cell = [tableView dequeueReusableCellWithIdentifier:@"mainmenutableviewcell"];
    cell.textLabel.textColor = UITextColor_Black;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    NSDictionary *dcit = self.array[indexPath.row];
    cell.textLabel.text = [dcit objectForKey:@"text"];
    cell.imageView.image = [UIImage imageNamed:[dcit objectForKey:@"img"]];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3) {
        [self startWait];
        [NetManagerInstance sendRequstWithType:EmRequestType_CommuteApplyGet params:^(NetParams *params) {
        }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:KMenuDidSelectNotification object:[NSNumber numberWithInteger:indexPath.row]];
    }
    
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColorFromRGB(0xececec);
    return view;
}

//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = UIColorFromRGB(0xececec);
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0.5;
//}


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
