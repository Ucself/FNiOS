//
//  RootViewController.m
//  JRDemo
//
//  Created by tianbo on 15/7/15.
//  Copyright (c) 2015年 tianbo. All rights reserved.
//

#import "RootViewController.h"
#import <FNDataModule/EnvPreferences.h>
#import "UserPreferences.h"
#import <FNCommon/NSDate+Easy.h>

@interface RootViewController ()
{
    BOOL bSleep;
}
@end

@implementation RootViewController


-(void)viewDidLoad {
    [super viewDidLoad];
    [self showLaunchImage];
    
    //二月初时间
    NSDate *februaryEnd = [NSDate stringToDate:@"2016-02-29 23:59:59"];
    NSDate *nowData = [NSDate date];
    NSDate *earlier_date = [nowData earlierDate:februaryEnd];
    
    if ([earlier_date isEqual:nowData]) {
        
        UIImageView *splashScreen = [[UIImageView alloc] initWithFrame:self.view.bounds];
        splashScreen.image = [UIImage imageNamed:@"ad"];
        [self.view addSubview:splashScreen];
        [self.view bringSubviewToFront:splashScreen];
        [self.view setNeedsDisplay];
        
        bSleep = YES;
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (bSleep) {
        [NSThread sleepForTimeInterval:3];
    }
    
    [self goNext];
}

#pragma mark -----

-(void)goNext
{
    //根据版本号区分是否显示引导页
    NSString *locVer = [[EnvPreferences sharedInstance] getAppVersion];
    //打印当前版本
    DBG_MSG(@"The local version is %@", locVer);
    NSString *curVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (locVer && [curVer isEqualToString:locVer]) {
        //        UIViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"ContainerViewController"];
        //        [self presentViewController:c animated:NO completion:^{}];
        
        [self performSegueWithIdentifier:@"gotomain" sender:nil];
    }
    else {
        [[EnvPreferences sharedInstance] setAppVersion:curVer];
        [self performSegueWithIdentifier:@"toguide" sender:nil];
    }
}

-(void)showLaunchImage
{
    CGSize viewSize = self.view.bounds.size;
    NSString *viewOrientation = @"Portrait";    //横屏请设置成 @"Landscape"
    NSString *launchImage = nil;
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    
    UIImageView *launchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImage]];
    launchView.frame = self.view.bounds;
    launchView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:launchView];
    
}

@end
