//
//  EvaluationViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "EvaluationViewController.h"
#import "CancelledSeasonViewController.h"
#import "WebContentViewController.h"

#import <FNUIView/RatingBar.h>
#import <FNUIView/PlaceHolderTextView.h>

//#import "UMSocialSnsPlatformManager.h"
//#import "UMSocialAccountManager.h"
#import "SharePanelView.h"

#import "ShuttleModel.h"

@interface EvaluationViewController () <RatingBarDelegate, UITextViewDelegate>
{
    NSMutableDictionary *_shareContentDic;
    UIImage             *_shareImage;
}
@property (strong, nonatomic) SharePanelView *sharePanel;

@property (weak, nonatomic) IBOutlet UIImageView *imgDriverHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelDriverName;
@property (weak, nonatomic) IBOutlet UILabel *labelPlateNumber;
@property (weak, nonatomic) IBOutlet RatingBar *ratingRecord;
@property (weak, nonatomic) IBOutlet UILabel *labelScore;

//已评价
@property (weak, nonatomic) IBOutlet UIView *viewDone;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelSalePrice;
@property (weak, nonatomic) IBOutlet UILabel *labelRealPrice;

@property (weak, nonatomic) IBOutlet RatingBar *ratingBarInvalid;
@property (weak, nonatomic) IBOutlet UILabel *labelContent;


//未评价
@property (weak, nonatomic) IBOutlet UIView *viewUndone;
@property (weak, nonatomic) IBOutlet RatingBar *ratingBarValid;
@property (weak, nonatomic) IBOutlet PlaceHolderTextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *btnCommit;

@property (strong, nonatomic) NSDictionary *dictEvlt;
@property (strong, nonatomic) ShuttleModel *order;

@end

@implementation EvaluationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    
    self.viewUndone.hidden = YES;
    self.viewDone.hidden = YES;
    
    //查询订单信息
    [NetManagerInstance sendRequstWithType:EmRequestType_GetDedicatedOrder params:^(NetParams *params) {
        params.data = @{@"orderId":self.orderId}; //测试ID
    }];
    
    if (self.hasEvaluation) {
        [self startWait];
        [NetManagerInstance sendRequstWithType:EmRequestType_GetDedicatedAppraise params:^(NetParams *params) {
            params.data = @{@"orderId":self.orderId};
        }];
    }
    else {
        self.viewUndone.hidden = NO;
        [self refreshUI];
    }
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
   
}

-(void)onApplicationEnterBackGround
{
    [self.textView resignFirstResponder];
}

- (void)initUI
{
    _textView.delegate = self;
    _textView.placeHolder = @"有什么想说的";
    _textView.numberLimit = 50;
    
    _ratingRecord.isIndicator = YES;
    _ratingBarInvalid.isIndicator = YES;
    _ratingBarValid.isIndicator = NO;
    
    [_ratingRecord setImageDeselected:@"small_star_nor" halfSelected:@"" fullSelected:@"small_star_press" andDelegate:self];
    
    [_ratingBarValid setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];
    [_ratingBarInvalid setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];
}

- (void)refreshUI
{
    [_imgDriverHeader setImage:[UIImage imageNamed:@"menu_header_large"]];
    _imgDriverHeader.image = [self fixOrientation:_imgDriverHeader.image];
    [self roundImageView:_imgDriverHeader];
    
    
    if (self.hasEvaluation) {
        _viewDone.hidden = NO;
        _viewUndone.hidden = YES;
        
        _labelPrice.text = [NSString stringWithFormat:@"%.2f元", [self.order.amount intValue]/100.0];
        _labelSalePrice.text = [NSString stringWithFormat:@"%.2f元", self.order.couponsAmount/100.0];
        _labelRealPrice.text = [NSString stringWithFormat:@"%.2f元", self.order.paymentAmount/100.0];
        
        [_ratingRecord setRating:[_dictEvlt[@"driverLevel"] floatValue]];
        _labelScore.text = [NSString stringWithFormat:@"%@分", _dictEvlt[@"driverLevel"]];
        _labelDriverName.text = _dictEvlt[@"driverName"];
        _labelPlateNumber.text = _dictEvlt[@"license"];
        
        _ratingBarInvalid.rating = [_dictEvlt[@"score"] floatValue];
        _labelContent.text = _dictEvlt[@"content"];
        
        [_imgDriverHeader setImageWithURL:[NSURL URLWithString:_dictEvlt[@"driverAvatar"]] placeholderImage:[UIImage imageNamed:@"menu_header_large"]];
        
    }
    else {
        _viewDone.hidden = YES;
        _viewUndone.hidden = NO;
        
//        [_ratingRecord setRating:[self.order.driver.driverLevel floatValue]];
//        _labelScore.text = [NSString stringWithFormat:@"%@分", self.order.driver.driverLevel];
//        _labelDriverName.text = self.order.driver.name;
//        _labelPlateNumber.text = self.order.driver.license;
        
        [_imgDriverHeader setImageWithURL:[NSURL URLWithString:self.order.driver.avatar] placeholderImage:[UIImage imageNamed:@"menu_header_large"]];
    }
}

#pragma mark -
-(void)navigationViewRightClick
{
    CancelledSeasonViewController *c = [CancelledSeasonViewController instanceWithStoryboardName:@"FeiniuOrder"];
    c.isComplain = YES;
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)btnBKClikc:(id)sender {
    [self.textView resignFirstResponder];
}

- (IBAction)btnCommitClick:(id)sender {

    [self.textView resignFirstResponder];
    if (self.ratingBarValid.rating < 1) {
        [self showTipsView:@"请为我们的服务打分"];
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_PostDedicatedAppraise params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"orderId":self.orderId,
                        @"level":[NSNumber numberWithInt:self.ratingBarValid.rating],
                        @"content":self.textView.text};
    }];
}
- (IBAction)btnShareClick:(id)sender {
    [self requestShareContent];
}

- (IBAction)btnRuleClick:(id)sender {
    WebContentViewController *webViewController = [WebContentViewController instanceWithStoryboardName:@"Me"];
    webViewController.vcTitle = @"计价规则";
    webViewController.urlString = HTMLAddr_CallFeiniuRule;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)btnCallDriverClick:(id)sender {
    NSString *phone = nil;
    if (_hasEvaluation) {
        phone = _dictEvlt[@"driverPhone"];
    }
    else {
        phone = self.order.driver.phone;
    }
    UserCustomAlertView *view = [UserCustomAlertView alertViewWithTitle:@"拨打司机电话" message:phone delegate:self buttons:@[ @"取消",@"呼叫"]];
    [view showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex{
    if (btnIndex == 1) {
        NSString *phone = nil;
        if (_hasEvaluation) {
            phone = _dictEvlt[@"driverPhone"];
        }
        else {
            phone = self.order.driver.phone;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]]];
    }
}

#pragma mark to keyboard events
-(void) autoMovekeyBoard: (float) h{
    CGRect frame = self.view.frame;
    CGRect btnFrame = [self.viewUndone convertRect:self.btnCommit.frame toView:self.view];
    int offset = btnFrame.origin.y + btnFrame.size.height;

    if (h != 0) {
        int height = deviceHeight - h;
        if (offset > height) {
            frame.origin.y = frame.origin.y - (offset - height + 10);
        }
        self.view.frame = frame;
    }
    else {
        frame.origin.y = 0;
        self.view.frame = frame;
    }
    

    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

    CGRect keyboardRect = [aValue CGRectValue];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self autoMovekeyBoard:keyboardRect.size.height];

}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self autoMovekeyBoard:0];
        
    //横屏时隐藏键盘按钮处理
    [self resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return NO;
        
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - image handle
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
    imageView.layer.borderColor = UIColor_DefOrange.CGColor;
    imageView.layer.borderWidth = 1.0f;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    //    imageView.layer.shouldRasterize = YES;
    imageView.clipsToBounds = YES;
}

#pragma mark 请求结果
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = notification.object;
    if (resultData.type == EmRequestType_GetDedicatedAppraise) {       //获取评价
        [self stopWait];
        
        self.viewUndone.hidden = YES;
        self.dictEvlt = resultData.data;
        [self refreshUI];
    }
    else if (resultData.type == EmRequestType_PostDedicatedAppraise) {    //提交评价
        [self showTipsView:@"评价成功"];
        
        self.hasEvaluation = YES;
        //取评价后数据
        [NetManagerInstance sendRequstWithType:EmRequestType_GetDedicatedAppraise params:^(NetParams *params) {
            params.data = @{@"orderId":self.orderId};
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
    }
    else if (resultData.type == EmRequestType_GetDedicatedOrder) {       //获取订单详情
        [self stopWait];
        self.order = [ShuttleModel mj_objectWithKeyValues:resultData.data[@"order"]];
        [self refreshUI];
    }
    else {
        if (resultData.type == EmRequestType_ShareContent) {
            [self stopWait];
            _shareContentDic = [NSMutableDictionary dictionaryWithDictionary:resultData.data];
            
            [self setUPShareContent];
            [self showSharePanel];
        }
    }
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

#pragma mark- shareview
- (void)setUPShareContent{
    // QQ
//    [UMSocialData defaultData].extConfig.qqData.url = _shareContentDic[kShareUrl];
//    [UMSocialData defaultData].extConfig.qqData.title = _shareContentDic[kShareTitle];
    
    // QZone
//    [UMSocialData defaultData].extConfig.qzoneData.url = _shareContentDic[kShareUrl];
//    [UMSocialData defaultData].extConfig.qzoneData.title = _shareContentDic[kShareTitle];
    
    // 朋友圈
//    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _shareContentDic[kShareUrl];
//    [UMSocialData defaultData].extConfig.wechatTimelineData.title = _shareContentDic[kShareTitle];
//    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
    
    // 微信好友
//    [UMSocialData defaultData].extConfig.wechatSessionData.url = _shareContentDic[kShareUrl];
//    [UMSocialData defaultData].extConfig.wechatSessionData.title = _shareContentDic[kShareTitle];
//    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeWeb;
    
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
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_shareContentDic[kShareImageUrl]]];
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
//        UMSocialUrlResource *resouce = [[UMSocialUrlResource alloc]initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:_shareContentDic[kShareUrl]];
//        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:_shareContentDic[kShareDescription] image:image location:nil urlResource:resouce presentedController:self completion:^(UMSocialResponseEntity *response){
//            if (response.responseCode == UMSResponseCodeSuccess) {
//                NSLog(@"分享成功！");
//            }
//        }];
    }];
}


-(SharePanelView*)sharePanelView
{
    if (self.sharePanel == nil) {
        self.sharePanel = [[SharePanelView alloc] init];
        
//        __weak typeof(self) weakSelf = self;
//        self.sharePanel.clickAction = ^(int params){
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            switch (params) {
//                case Action_Wx:
//                    [strongSelf shareTo:UMShareToWechatSession];
//                    [strongSelf hideSharePanel:NO];
//                    break;
//                case Action_Circles:
//                    [strongSelf shareTo:UMShareToWechatTimeline];
//                    [strongSelf hideSharePanel:NO];
//                    break;
//                case Action_Sina:
//                    [strongSelf shareTo:UMShareToSina];
//                    [strongSelf hideSharePanel:NO];
//                    break;
//                case Action_QQ:
//                    [strongSelf shareTo:UMShareToQQ];
//                    [strongSelf hideSharePanel:NO];
//                    break;
//                case Action_Kongjian:
//                    [strongSelf shareTo:UMShareToQzone];
//                    [strongSelf hideSharePanel:NO];
//                    break;
//                case Action_Tencent:
//                    [strongSelf shareTo:UMShareToTencent];
//                    [strongSelf hideSharePanel:NO];
//                    break;
//                case Action_Close:
//                    [strongSelf hideSharePanel:YES];
//                    break;
//                    
//                default:
//                    break;
//            }
//        };
    }
    
    return self.sharePanel;
}

-(void)showSharePanel
{
    UIView *view = [[self sharePanelView] panel];
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
    }];
}

-(void)hideSharePanel:(BOOL)animated
{
    UIView *view = [[self sharePanelView] panel];
    //view.frame = CGRectMake(0, 0, ScreenW, ScreenH);
    if (animated) {
        [UIView beginAnimations:@"Animation" context:nil];
        [UIView setAnimationDuration:0.3f];
        view.frame = CGRectMake(0, ScreenH, ScreenW, ScreenH);
        [UIView commitAnimations];
        
        [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.3];
    }
    else {
        [view removeFromSuperview];
    }
}

- (void)requestShareContent{
//    User *user = [UserPreferInstance getUserInfo];
//    if (!user || !user.phone) {
//        [self showTip:@"信息异常，手机号为空。" WithType:FNTipTypeFailure hideDelay:1.5];
//        return;
//    }
    
    if (!_shareContentDic) {
        [self startWait];
        [NetManagerInstance sendRequstWithType:EmRequestType_ShareContent params:^(NetParams *params) {
            
        }];
    }
    else {
        [self setUPShareContent];
        [self showSharePanel];
    }
    
}
@end
