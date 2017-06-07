//
//  LoginInputView.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/30.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>

@interface LoginInputView :BaseUIView

@property (nonatomic, assign) int limit;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, assign) BOOL rightViewAlway;

-(void)setLeftImageNormal:(UIImage*)imageNormal imageHigh:(UIImage*)imageHigh;

-(void)setRightButton:(UIButton*)button width:(CGFloat)width hight:(CGFloat)hight;


-(void)resignFirstResponder;
-(void)becomeFirstResponder;
@end
