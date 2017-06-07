//
//  AuthenticationLogic.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/7/27.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "AuthenticationLogic.h"
#import <FNDataModule/ResultDataModel.h>
#import <FNNetInterface/FNNetInterface.h>
#import "PushConfiguration.h"
#import "AuthorizeCache.h"
#import "ComTempCache.h"
#import "LoginViewController.h"

@interface AuthenticationLogic()

@property(nonatomic,assign) BOOL isrefresh;

@end

@implementation AuthenticationLogic


+(AuthenticationLogic*)sharedInstance
{
    static AuthenticationLogic *instance = nil;
    static dispatch_once_t once;
    _dispatch_once(&once, ^{
        instance = [[self alloc] init];
        //注册网络请求通知
    });
    
    return instance;
}



-(void)addUserData:(UIViewController*)viewController{
    self.viewController = viewController;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFinished:) name:KNotification_RequestFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFailed:) name:KNotification_RequestFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotification:) name:KNotification_AuthenticationFail object:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)refreshNotification:(NSNotification *)notification
{
    //如果在刷新，则直接返回
    if (_isrefresh) {
        return;
    }
    _isrefresh = YES;
    //刷新一次 鉴权失败且不是已经刷新过一次
    ResultDataModel *result = (ResultDataModel *)notification.object;
    if (result.type != EMRequestType_RefreshToken && result.code == EmCode_TokenOverdue) {
        
        //没有刷新Token 直接登陆
        if (![[AuthorizeCache sharedInstance] getRefreshToken] || [[[AuthorizeCache sharedInstance] getRefreshToken] isEqualToString:@""]) {
            [self toLoginViewController];
            return;
        }
        
        DBG_MSG(@"鉴权令牌刷新");
        [NetManagerInstance sendFormRequstWithType:EMRequestType_RefreshToken params:^(NetParams *params) {
            params.method = EMRequstMethod_POST;
            params.data = @{@"refresh_token":[[AuthorizeCache sharedInstance] getRefreshToken],
                            @"grant_type":@"refresh_token",
                            @"client_id":KClient_id,
                            @"terminal":@"PG",
                            };
        }];
    }
    else{
        _isrefresh = NO;
    }
}

-(void)httpRequestFinished:(NSNotification *)notification
{
    ResultDataModel *result = (ResultDataModel *)notification.object;
    //重新鉴权令牌刷新登陆成功
    if (result.type == EMRequestType_RefreshToken) {
        DBG_MSG(@"鉴权令牌刷新成功");
        _isrefresh = NO;
        NSString *token = [result.data objectForKey:@"id_token"];
        NSString *refreshToken = [result.data objectForKey:@"refresh_token"];
        NSString *alias = [result.header objectForKey:@"feiniu_alias"];
        //NSString *userId = [result.data objectForKey:@"user_id"];
        if (token) {    //保存token
            [[AuthorizeCache sharedInstance] setAccessToken:token];
            [[AuthorizeCache sharedInstance] setRefreshToken:refreshToken];
            
            // 1 为用户角色, 用户端
            [NetManagerInstance setAuthorization:[[NSString alloc] initWithFormat:@"Bearer %@",token]];
            // 注册通知别名
            [[PushConfiguration sharedInstance] setAlias:PassengerAlias userAlias:alias];
        }
        //此处再刷新一次上次请求的数据
        [NetManagerInstance reloadRecordData];
    }
}
/**
 *  @author Nick
 *
 *  失败统一处理
 *
 *  @param notification
 */
- (void)httpRequestFailed:(NSNotification *)notification{
    
    ResultDataModel *result = notification.object;
    //已经刷新过且返回失败
    if (result.code == EmCode_RefreshTokenError && result.type == EMRequestType_RefreshToken) {
        DBG_MSG(@"鉴权令牌刷新失败");
        _isrefresh = NO;
        //鉴权失效重置token
        [[AuthorizeCache sharedInstance] clean];
        //重置别名
        [[PushConfiguration sharedInstance] resetAlias];
        //重置联系人
        [ComTempCache removeObjectWithKey:KeyContactList];
        [self toLoginViewController];
        return;
    }
}


- (void)toLoginViewController {
    if (!self.viewController) {
        return;
    }
    //进入登录界面
    UIViewController *root = self.viewController;
    [LoginViewController presentAtViewController:root needBack:YES requestToHomeIfCancel:NO completion:^{
        
    } callBalck:^(BOOL isSuccess, BOOL needToHome) {
        _isrefresh = NO;
        
        if (!isSuccess) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (needToHome) {
//                    [self.navigationController popToRootViewControllerAnimated:NO];
//                }
//                else if (!_isNotAuthBack) {
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
            });
            
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:KLoginSuccessNotification object:nil];
            
        }
    }];
}

@end
