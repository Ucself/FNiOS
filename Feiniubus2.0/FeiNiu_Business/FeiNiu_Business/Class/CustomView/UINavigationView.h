//
//  UINavigationVIew.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>

@protocol UINavigationViewDelegate <NSObject>

-(void)navigateionViewBack;
-(void)navigateionViewRight;

@end

IB_DESIGNABLE
@interface UINavigationView : BaseUIView

@property (nonatomic, weak) IBOutlet id <UINavigationViewDelegate> delegate;

@property (nonatomic, strong) IBInspectable NSString *title;
@property (nonatomic, strong) IBInspectable UIImage *leftImage;
@property (nonatomic, strong) IBInspectable UIImage *rightImage;
@property (nonatomic, strong) IBInspectable NSString *rightTitle;
@property (nonatomic, strong) IBInspectable UIColor *rightTitleColor;


@end