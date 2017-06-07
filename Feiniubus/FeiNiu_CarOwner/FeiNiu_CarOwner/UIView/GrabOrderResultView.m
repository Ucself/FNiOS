//
//  GrabOrderResultView.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/21.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "GrabOrderResultView.h"
#import <FNCommon/Common.h>

#define kContentHeight 230

@interface GrabOrderResultView ()
{
    UIView *parentView;
}

@end

@implementation GrabOrderResultView


//
-(void)awakeFromNib
{
    //设置透明背景色
    self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
    //设置协议
    [_submitButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    //设置圆角
    [self setRounded];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)buttonClick:(id)sender
{
    //执行协议
    if ( self &&[self.delegate respondsToSelector:@selector(submitButtonClick:)]) {
        [self.delegate submitButtonClick:self];
    }
    
    [self cancelSelect:parentView];
}

//设置按钮的圆角
-(void)setRounded
{
    //外部视图圆角
    //    _contentView.layer.borderWidth = 1.f;
    //    _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    _contentView.layer.cornerRadius = 4;
    //按钮圆角
    _submitButton.layer.borderWidth = 1.f;
    _submitButton.layer.borderColor = UIColorFromRGB(0xFF5A37).CGColor;
    _submitButton.layer.cornerRadius = 4;
}

-(void)setDisplayType:(DisplayType)displayType
{
    switch (displayType) {
        case DisplayTypeSuccess:
        {
            [_headImage setImage:[UIImage imageNamed:@"grabOrderSuccess"]];
            [_tipFirstInfor setText:@"抢单成功"];
            [_tipSecondInfor setText:@"请等待用户付款"];
        }
            break;
        case DisplayTypeFailure:
        {
            [_headImage setImage:[UIImage imageNamed:@"grabOrderFailure"]];
            [_tipFirstInfor setText:@"抢单失败"];
            [_tipSecondInfor setText:@"请这次订单被人抢走，下次快一点哟"];
        }
            break;
        default:
            break;
    }
}

#pragma mark ----

- (void)showInView:(UIView *) view
{
    self.tag = 11102;
    if ([view viewWithTag:11102]) {
        return;
    }
    parentView = view;
    [view addSubview:self];
    //全部视图
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    //容器视图
    //    [_contentView remakeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.equalTo(self);
    //        make.centerY.equalTo(self);
    //        make.width.equalTo(30);
    //        make.height.equalTo(30);
    //    }];
    
    [view layoutIfNeeded];
    [UIView animateWithDuration:0.0 animations:^{
        
        [_contentView remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
            make.width.equalTo(281);
            make.height.equalTo(230);
        }];
        [view layoutIfNeeded];
    }];
}

- (void)cancelSelect:(UIView *) view
{
    //包含视图再设置取消
    if (![view viewWithTag:11102]) {
        return;
    }
    
    [UIView animateWithDuration:0.0
                     animations:^{
                         //                         [_contentView remakeConstraints:^(MASConstraintMaker *make){
                         //                             make.centerX.equalTo(self);
                         //                             make.centerY.equalTo(self);
                         //                             make.width.equalTo(0);
                         //                             make.height.equalTo(0);
                         //                         }];
                         [view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}


@end
