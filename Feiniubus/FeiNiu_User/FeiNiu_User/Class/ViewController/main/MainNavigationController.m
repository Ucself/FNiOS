//
//  MainNavigationController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    
    //注册网络请求通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFinished:) name:KNotification_RequestFinished object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(httpRequestFailed:) name:KNotification_RequestFailed object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
}


-(void)httpRequestFinished:(NSNotification *)notification
{
    
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    
//    NSDictionary *dict = notification.object;
//    
//    NSError *error = [dict objectForKey:@"error"];
//    int type = [[dict objectForKey:@"type"] intValue];
//    FUResultParse *result = [[FUResultParse alloc] initWithErrorInfo:error reqType:type];
//    
//    DBG_MSG(@"httpRequestFailed: resultcode= %d", result.resultCode);
//    
//    if (result.resultCode == 401 || result.resultCode == 403) {
//        //鉴权失效重置token
//        [[UserPreferences sharedInstance] setToken:nil];
//        [[UserPreferences sharedInstance] setUserId:nil];
//        
//        return ;
//    }
}

@end
