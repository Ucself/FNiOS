//
//  ShareViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/22.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "ShareViewController.h"
#import <FNUIView/FXBlurView.h>
#import "UMSocialSnsPlatformManager.h"
#import "UMSocialAccountManager.h"
#import <FNNetInterface/UIImageView+AFNetworking.h>

NSString *const kShareContentUrl = @"url";
NSString *const kShareContentMessage = @"title";
NSString *const kShareContentImageUrl = @"imageUrl";
NSString *const kShareContentDesc = @"description";


@interface ShareViewController (){
    NSMutableDictionary *_shareContentDic;
    UIImage             *_shareImage;
}

@property (weak, nonatomic) IBOutlet UIButton *btnShare;
//动态显示描述lbj添加
@property (weak, nonatomic) IBOutlet UIImageView *imageShare;
@property (weak, nonatomic) IBOutlet UILabel *labelShare;

//
//@property (nonatomic, strong) UIButton *btnWeiXin;
//@property (nonatomic, strong) UIButton *btnCircles;
//@property (nonatomic, strong) UIButton *btnSina;
@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _btnShare.layer.cornerRadius = 5;
    _btnShare.layer.masksToBounds = YES;
//    _btn1.layer.borderWidth = 0.6;
//    _btn1.layer.borderColor = [UIColorFromRGB(0xcdcdcd) CGColor];
    [self requestShareContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    //防止3DTouch 进入的时候，释放掉
    [self hideSharePanel];
}


-(UIView*)buttonView:(NSString*)title image:(UIImage*)image action:(SEL)action
{
    UIView *view = [[UIView alloc] init];
    //view.backgroundColor = [UIColor blackColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    [view addSubview:label];
    
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view);
        make.height.equalTo(20);
        make.width.equalTo(view);
        make.centerX.equalTo(view);
    }];
    
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.width.equalTo(view);
        make.top.equalTo(view);
        make.bottom.equalTo(label).offset(-10);
    }];
    
    return view;
}

-(UIView*)shareView
{
    FXBlurView *view = [[FXBlurView alloc] init];
    view.dynamic = NO;
    view.blurRadius = 40;
    view.tintColor = UIColorFromRGB(0x26547b);
    
    //view.backgroundColor = [UIColor colorWithHue:.5 saturation:.5 brightness:.5 alpha:.8];;
    
    UILabel *label = [UILabel new];
    label.text = @"分享到";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [view addSubview:label];
    
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(100);
        make.centerX.equalTo(view);
        make.width.equalTo(100);
        make.height.equalTo(24);
    }];
    
    //第一行
    UIView *btnWx = [self buttonView:@"微信" image:[UIImage imageNamed:@"wechat_icon"] action:@selector(btnWeixinClick)];
    [view addSubview:btnWx];
    UIView *btnCircles = [self buttonView:@"朋友圈" image:[UIImage imageNamed:@"friend_icon"] action:@selector(btnCirclesClick)];
    [view addSubview:btnCircles];
    UIView *btnSina = [self buttonView:@"新浪微博" image:[UIImage imageNamed:@"weibo_icon"] action:@selector(btnSinaClick)];
    [view addSubview:btnSina];
    
    [btnWx makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.bottom).offset(30);
        make.left.equalTo(view).offset(20);
        make.height.equalTo(100);
        make.width.equalTo(btnCircles);
    }];
    
    [btnCircles makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnWx.top);
        make.left.equalTo(btnWx.right);
        make.height.equalTo(100);
        make.width.equalTo(btnSina);
    }];
    
    [btnSina makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnWx.top);
        make.left.equalTo(btnCircles.right);
        make.right.equalTo(view.right).offset(-20);
        make.height.equalTo(100);
        make.width.equalTo(btnWx);
    }];
    
    //第二行
    UIView *btnQQ = [self buttonView:@"QQ" image:[UIImage imageNamed:@"qq_icon"] action:@selector(btnQQClick)];
    [view addSubview:btnQQ];
    UIView *btnKongjian = [self buttonView:@"QQ空间" image:[UIImage imageNamed:@"kongjian_icon"] action:@selector(btnKongjianClick)];
    [view addSubview:btnKongjian];
    UIView *btnTencent = [self buttonView:@"腾讯微博" image:[UIImage imageNamed:@"txwb_icon"] action:@selector(btnTencentClick)];
    [view addSubview:btnTencent];
    
    [btnQQ makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnSina.bottom).offset(20);
        make.left.equalTo(view).offset(20);
        make.height.equalTo(100);
        make.width.equalTo(btnKongjian);
    }];
    
    [btnKongjian makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnQQ.top);
        make.left.equalTo(btnQQ.right);
        make.height.equalTo(100);
        make.width.equalTo(btnTencent);
    }];
    
    [btnTencent makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnQQ.top);
        make.left.equalTo(btnKongjian.right);
        make.right.equalTo(view.right).offset(-20);
        make.height.equalTo(100);
        make.width.equalTo(btnQQ);
    }];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"close_white"];
    [btnClose setImage:image forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnClose];
    
    [btnClose makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.bottom.equalTo(view.bottom).offset(-20);
        make.height.equalTo(image.size.height);
        make.width.equalTo(image.size.width);
    }];
    
 
    return view;
}

-(void)showSharePanel
{
    UIView *view = [self shareView];
    view.tag = 12345;
    [KWindow addSubview:view];
    
    view.frame = CGRectMake(0, ScreenH, ScreenW, ScreenH);
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:0.3f];
    view.frame = CGRectMake(0, 0, ScreenW, ScreenH);
    [UIView commitAnimations];
    
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:1.0 animations:^{
        
        [view makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(KWindow);
        }];
//        [view layoutIfNeeded];
    }];
}

-(void)hideSharePanel
{
    UIView *view = [KWindow viewWithTag:12345];
    if (view == nil) {
        return;
    }
    
    view.frame = CGRectMake(0, 0, ScreenW, ScreenH);
    [UIView beginAnimations:@"Animation" context:nil];
    [UIView setAnimationDuration:0.3f];
    view.frame = CGRectMake(0, ScreenH, ScreenW, ScreenH);
    [UIView commitAnimations];
    
    
    [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.3];

//    [UIView animateWithDuration:0.4 animations:^{
//        UIView *view = [KWindow viewWithTag:12345];
//        if (view) {
//            [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.4];
////            [view removeFromSuperview];
//        }
//    }];
}
#pragma mark - HTTP Request
- (void)requestShareContent{
    User *user = [[UserPreferences sharedInstance] getUserInfo];
    if (!user || !user.phone) {
        [self showTip:@"信息异常，手机号为空。" WithType:FNTipTypeFailure hideDelay:1.5];
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_GetShareContent params:^(NetParams *params) {
        params.data = @{@"phone":user.phone};
    }];
}
#pragma mark - HTTP Response
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    //NSDictionary *result = resultData.data;
    //_shareContentDic = [NSMutableDictionary dictionary];
    
    if (type == FNUserRequestType_GetShareContent) {
        if (resultData.resultCode == 0) {
            NSDictionary *result = resultData.data;
            result = result[@"data"];
            _shareContentDic = [NSMutableDictionary dictionary];
            
            [_shareContentDic setObject:[NSString stringWithFormat:@"%@", result[kShareContentUrl]] forKey:kShareContentUrl];
            [_shareContentDic setObject:[NSString stringWithFormat:@"%@", result[kShareContentMessage]] forKey:kShareContentMessage];
            [_shareContentDic setObject:[NSString stringWithFormat:@"%@", result[kShareContentImageUrl]] forKey:kShareContentImageUrl];
            [_shareContentDic setObject:[NSString stringWithFormat:@"%@", result[kShareContentDesc]] forKey:kShareContentDesc];
            [self setUPShareContent];
            
            //动态设置显示图片和描述 lbj 添加
            if ([result objectForKey:@"locImage"]) {
                [_imageShare setImageWithURL:[result objectForKey:@"locImage"] placeholderImage:[UIImage imageNamed:@"friend_img"]];
            }
            if ([result objectForKey:@"locDesc"]) {
                [_labelShare setText:[result objectForKey:@"locDesc"]];
            }
            
        }else{
            [self showTip:resultData.message WithType:FNTipTypeFailure hideDelay:1];
        }
    }
}

#pragma mark - 
// 分享数据
- (void)umSocialService:(void (^)(UMSocialControllerService *service))block{
    
    if (_shareImage) {
        UMSocialData *data = [[UMSocialData alloc]initWithIdentifier:@"飞牛BUS" withTitle:_shareContentDic[kShareContentDesc]];
        data.shareText = _shareContentDic[kShareContentMessage];
        
        data.shareImage = _shareImage;
        
        UMSocialControllerService *service = [[UMSocialControllerService alloc]initWithUMSocialData:data];
        if (block) {
            block(service);
        }
    }else{
        [self startWait];
        NSOperationQueue *getShareContentQueue = [[NSOperationQueue alloc]init];
        getShareContentQueue.name = @"GetShareContentQueue";
        getShareContentQueue.maxConcurrentOperationCount = 1;
        [getShareContentQueue addOperationWithBlock:^{
            UMSocialData *data = [[UMSocialData alloc]initWithIdentifier:@"飞牛BUS" withTitle:_shareContentDic[kShareContentDesc]];
            data.shareText = _shareContentDic[kShareContentMessage];
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_shareContentDic[kShareContentImageUrl]]];
            _shareImage = [UIImage imageWithData:imageData];
            data.shareImage = _shareImage;
            
            UMSocialControllerService *service = [[UMSocialControllerService alloc]initWithUMSocialData:data];
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                [self stopWait];
                if (block) {
                    block(service);
                }
            }];
        }];
    }
}
//- (UMSocialControllerService *)umSocialService{
//    
//    return nil;
//}
- (void)setUPShareContent{
    // QQ
    [UMSocialData defaultData].extConfig.qqData.url = _shareContentDic[kShareContentUrl];
    [UMSocialData defaultData].extConfig.qqData.title = _shareContentDic[kShareContentMessage];

    // QZone
    [UMSocialData defaultData].extConfig.qzoneData.url = _shareContentDic[kShareContentUrl];
    [UMSocialData defaultData].extConfig.qzoneData.title = _shareContentDic[kShareContentMessage];

    // 朋友圈
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _shareContentDic[kShareContentUrl];
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = _shareContentDic[kShareContentMessage];
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;

    // 微信好友
    [UMSocialData defaultData].extConfig.wechatSessionData.url = _shareContentDic[kShareContentUrl];
    [UMSocialData defaultData].extConfig.wechatSessionData.title = _shareContentDic[kShareContentMessage];
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;

    // sina 微博
//    [UMSocialData defaultData].extConfig.sinaData.url = _shareContentDic[kShareContentUrl];

}
- (void)sharedImage:(void (^)(UIImage *image))block{
    if (_shareImage) {
        if (block) {
            block(_shareImage);
        }
        return;
    }else{
        [self startWait];
        NSOperationQueue *getShareContentQueue = [[NSOperationQueue alloc]init];
        getShareContentQueue.name = @"GetShareImageQueue";
        getShareContentQueue.maxConcurrentOperationCount =  1;
        [getShareContentQueue addOperationWithBlock:^{
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_shareContentDic[kShareContentImageUrl]]];
            _shareImage = [UIImage imageWithData:imageData];
            
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                [self stopWait];
                if (block) {
                    block(_shareImage);
                }
            }];
        }];
    }
}

- (void)shareTo:(NSString *)type{
    if (!_shareContentDic) {
        [self showTip:@"暂未获取到分享内容，请稍候再试！" WithType:FNTipTypeFailure];
        return;
    }
    [self sharedImage:^(UIImage *image) {
        UMSocialUrlResource *resouce = [[UMSocialUrlResource alloc]initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:_shareContentDic[kShareContentUrl]];
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:_shareContentDic[kShareContentDesc] image:image location:nil urlResource:resouce presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
            }
        }];
    }];
}
#pragma mark-
- (IBAction)btnShareClick:(id)sender {
    [self showSharePanel];
}

-(void)btnWeixinClick
{
    [self shareTo:UMShareToWechatSession];
//    [self umSocialService:^(UMSocialControllerService *service) {
//        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
//        snsPlatform.snsClickHandler(self, service, YES);
//    }];
    

//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
//            
//            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
//            
//        }
//        
//    });
    [self hideSharePanel];
}

-(void)btnCirclesClick
{
    [self shareTo:UMShareToWechatTimeline];

//    [self umSocialService:^(UMSocialControllerService *service) {
//        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatTimeline];
//        snsPlatform.snsClickHandler(self, service, YES);
//    }];
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:];
//    snsPlatform.snsClickHandler(self, [self umSocialService], YES);

//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        
//        //          获取微博用户名、uid、token等
//        
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToWechatTimeline];
//            
//            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
//            
//        }});
    [self hideSharePanel];
}

-(void)btnSinaClick
{
    [self shareTo:UMShareToSina];

//    [self umSocialService:^(UMSocialControllerService *service) {
//        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
//        snsPlatform.snsClickHandler(self, service, YES);
//    }];
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:];
//    snsPlatform.snsClickHandler(self, [self umSocialService], YES);

//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        
//        //          获取微博用户名、uid、token等
//        
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
//            
//            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
//            
//        }});
    [self hideSharePanel];
}

-(void)btnQQClick
{
    [self shareTo:UMShareToQQ];
    
    
//    [self umSocialService:^(UMSocialControllerService *service) {
//        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
//        snsPlatform.snsClickHandler(self, service, YES);
//    }];
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:];
//    
//    snsPlatform.snsClickHandler(self, [self umSocialService], YES);
    [self hideSharePanel];
}

-(void)btnKongjianClick
{
    [self shareTo:UMShareToQzone];

//    [self umSocialService:^(UMSocialControllerService *service) {
//        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQzone];
//        snsPlatform.snsClickHandler(self, service, YES);
//    }];
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:];
//    snsPlatform.snsClickHandler(self, [self umSocialService], YES);

//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        
//        //          获取微博用户名、uid、token等
//        
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQzone];
//            
//            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
//            
//        }});
    [self hideSharePanel];
}

-(void)btnTencentClick
{
    [self shareTo:UMShareToTencent];

//    [self umSocialService:^(UMSocialControllerService *service) {
//        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToTencent];
//        snsPlatform.snsClickHandler(self, service, YES);
//    }];
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName: ];
//    snsPlatform.snsClickHandler(self, [self umSocialService], YES);

//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        
//        //          获取微博用户名、uid、token等
//        
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToTencent];
//            
//            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
//            
//        }});
    [self hideSharePanel];

}

-(void)btnCloseClick
{
    [self hideSharePanel];
}

#pragma shared respone



@end
