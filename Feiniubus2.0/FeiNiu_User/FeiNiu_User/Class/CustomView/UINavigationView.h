//
//  UINavigationVIew.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UINavigationViewDelegate <NSObject>

-(void)navigationViewBackClick;
-(void)navigationViewRightClick;

@end

IB_DESIGNABLE
@interface UINavigationView : UIView

@property (nonatomic, weak) IBOutlet id <UINavigationViewDelegate> delegate;

@property (nonatomic, strong) IBInspectable NSString *title;
@property (nonatomic, strong) IBInspectable UIImage *leftImage;
@property (nonatomic, strong) IBInspectable UIImage *rightImage;
@property (nonatomic, strong) IBInspectable NSString *rightTitle;
@property (nonatomic, strong) IBInspectable UIColor *rightTitleColor;


@end
