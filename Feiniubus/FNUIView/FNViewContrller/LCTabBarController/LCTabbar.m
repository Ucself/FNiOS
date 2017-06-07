//
//  LCTabbar.m
//  LuoChang
//
//  Created by Rick on 15/4/29.
//  Copyright (c) 2015年 Rick. All rights reserved.
//

#import "LCTabbar.h"
#import "LCTabBarController.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LCTabbar()<UINavigationControllerDelegate>
{
    LCTabBarButton *_selectedBarButton;
}
@end

@implementation LCTabbar

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addBarButtons];
    }
    return self;
}

-(void) addBarButtons{
    for (int i = 0 ; i<5 ; i++) {
        LCTabBarButton *btn = [[LCTabBarButton alloc] init];
        CGFloat btnW = self.frame.size.width/5;
        CGFloat btnX = i * btnW;
        CGFloat btnY = 0;
        
        CGFloat btnH = self.frame.size.height;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        NSString *imageName = [NSString stringWithFormat:@"TabBar%d",i];
        NSString *selImageName = [NSString stringWithFormat:@"TabBar%dSel",i];
        NSString *title;
        if (i==0) {
            title = @"车辆信息";
        }else if(i==1){
            title = @"司机信息";
        }else if(i==2){
            imageName = @"TabBarGrabOrder";
            selImageName =@"TabBarGrabOrderSel";
        }else if(i==3){
            title = @"任务信息";
        }else if(i==4){
            title = @"个人中心";
        }
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:selImageName] forState:UIControlStateSelected];
        btn.tag = i;
        if (i!=2) {
            [btn setTitle:title forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize: 10.0];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleColor:UIColorFromRGB(0xFF5A37) forState:UIControlStateSelected];
            [btn setTitleColor:RGB(128, 128, 128) forState:UIControlStateNormal];
            [self addSubview:btn];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
        }
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //不选中其他四个
//        if(i == 2){
//            [self btnClick:btn];
//        }
    }
}


-(void) btnClick:(UIButton *)button{
    [self.delegate changeNav:_selectedBarButton.tag to:button.tag];
    _selectedBarButton.selected = NO;
    button.selected = YES;
    _selectedBarButton = (LCTabBarButton *)button;
}


@end
