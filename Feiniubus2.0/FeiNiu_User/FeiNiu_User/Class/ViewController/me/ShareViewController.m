//
//  ShareViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/22.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "ShareViewController.h"


#import <FNNetInterface/UIImageView+AFNetworking.h>
#import "UserPreferences.h"
#import <UMSocialCore/UMSocialCore.h>
#import "SharePanelView.h"


@interface ShareViewController (){
    NSMutableDictionary *_shareContentDic;
    UIImage             *_shareImage;

}
@property (strong, nonatomic) SharePanelView *sharePanel;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    //请求分享数据
    [self requestShareContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showSharePanel];
}

-(SharePanelView*)sharePanelView
{
    if (self.sharePanel == nil) {
        self.sharePanel = [[SharePanelView alloc] init];
        
        __weak typeof(self) weakSelf = self;
        self.sharePanel.clickAction = ^(int params){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            switch (params) {
                case Action_Wx:
                    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
                        [strongSelf shareTo:UMSocialPlatformType_WechatSession];
                        [strongSelf hideSharePanel:YES];
                    }
                    else{
                        [strongSelf showTipsView:@"未安装微信"];
                    }
                    
                    break;
                case Action_Circles:
                    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatTimeLine]) {
                        [strongSelf shareTo:UMSocialPlatformType_WechatTimeLine];
                        [strongSelf hideSharePanel:YES];
                    }
                    else{
                        [strongSelf showTipsView:@"未安装微信"];
                    }
                    
                    break;
                case Action_Sina:
                    [strongSelf shareTo:UMSocialPlatformType_Sina];
                    [strongSelf hideSharePanel:YES];
                    break;
                case Action_QQ:
                    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]) {
                        [strongSelf shareTo:UMSocialPlatformType_QQ];
                        [strongSelf hideSharePanel:YES];
                    }
                    else{
                        [strongSelf showTipsView:@"未安装QQ"];
                    }
                    
                    break;
                case Action_Kongjian:
                    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_Qzone]) {
                        [strongSelf shareTo:UMSocialPlatformType_Qzone];
                        [strongSelf hideSharePanel:YES];
                    }
                    else{
                        [strongSelf showTipsView:@"未安装QQ空间"];
                    }
                    break;
                case Action_Tencent:
                    [strongSelf shareTo:UMSocialPlatformType_TencentWb];
                    [strongSelf hideSharePanel:YES];
                    break;
                case Action_Close:
                    [strongSelf hideSharePanel:YES];
                    break;
                    
                default:
                    break;
            }
        };
    }
    
    return self.sharePanel;
}

-(void)showSharePanel
{
    
    [self.controller addChildViewController:self];
    [self didMoveToParentViewController:self.controller];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
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
        
    });
}

-(void)hideSharePanel:(BOOL)animated
{
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        UIView *view = [[self sharePanelView] panel];
        //view.frame = CGRectMake(0, 0, ScreenW, ScreenH);
        if (animated) {
            [UIView beginAnimations:@"Animation" context:nil];
            [UIView setAnimationDuration:0.3f];
            view.frame = CGRectMake(0, ScreenH, ScreenW, ScreenH);
            [UIView commitAnimations];
            
            [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:.3];
            [self performSelector:@selector(removeFromParentViewController) withObject:nil afterDelay:.3];
        }
        else {
            [view removeFromSuperview];
            [self removeFromParentViewController];
        }
    });
}
#pragma mark - HTTP Request
- (void)requestShareContent{
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_CommuteShare params:^(NetParams *params) {
        params.data = @{@"id":self.commuteId ? self.commuteId : @""};
    }];
}
#pragma mark - HTTP Response
- (void)httpRequestFinished:(NSNotification *)notification{
    
    [super httpRequestFinished:notification];
    [self stopWait];
    ResultDataModel *result = (ResultDataModel *)notification.object;
    
    if (result.type == EmRequestType_CommuteShare) {
        _shareContentDic = [NSMutableDictionary dictionaryWithDictionary:result.data];
    }
}

- (void) httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
    [self hideSharePanel:YES];
}

#pragma mark - share
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

- (void)shareTo:(UMSocialPlatformType)platformType{
    if (!_shareContentDic) {
        [self showTip:@"暂未获取到分享内容，请稍候再试！" WithType:FNTipTypeFailure];
        return;
    }
    [self sharedImage:^(UIImage *image) {
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:_shareContentDic[kShareTitle]
                                                                             descr:_shareContentDic[kShareDescription]
                                                                         thumImage:image];
        shareObject.webpageUrl = _shareContentDic[kShareUrl];
        messageObject.shareObject = shareObject;
        
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self.controller completion:^(id data, NSError *error) {
            if (error) {
                NSLog(@"************Share fail with error %@*********",error);
            }else{
                NSLog(@"response data is %@",data);
            }
        }];

    }];
}

@end
