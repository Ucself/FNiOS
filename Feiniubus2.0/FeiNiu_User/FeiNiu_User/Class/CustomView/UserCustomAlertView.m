//
//  UserCustomAlertView.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserCustomAlertView.h"


#define AlertTag 0x123

@interface UserCustomAlertView ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopConstraint;

@end
@implementation UserCustomAlertView
+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)msg delegate:(id<UserCustomAlertViewDelegate>)delegate{
    UserCustomAlertView *alert = [[[NSBundle mainBundle] loadNibNamed:@"UserCustomAlertView" owner:self options:nil] firstObject];
    alert.title = title;
    alert.message = msg;
    alert.delegate = delegate;
    alert.contentView.layer.cornerRadius = 6;
    alert.contentView.clipsToBounds = YES;
    return alert;
}
+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)msg delegate:(id<UserCustomAlertViewDelegate>)delegate buttons:(NSArray *)buttonsTitle{
    UserCustomAlertView *alert = [[[NSBundle mainBundle] loadNibNamed:@"UserCustomAlertView" owner:self options:nil] firstObject];
    alert.title = title;
    alert.message = msg;
    alert.delegate = delegate;
    alert.contentView.layer.cornerRadius = 6;
    alert.contentView.clipsToBounds = YES;
    if ([buttonsTitle firstObject] && [[buttonsTitle firstObject] isKindOfClass:[NSString class]]) {
        [alert.btnOK setTitle:[buttonsTitle firstObject] forState:UIControlStateNormal];
    }
    if (buttonsTitle.count > 1 && [buttonsTitle lastObject] && [[buttonsTitle lastObject] isKindOfClass:[NSString class]]) {
        [alert.btnCancel setTitle:[buttonsTitle lastObject] forState:UIControlStateNormal];
    }
    return alert;
}
#pragma mark - Setter && Getter
- (void)setTitle:(NSString *)title{
    _lblTitle.text = title;
}
- (void)setMessage:(NSString *)message{
    _lblMessage.text = message;
}
- (NSString *)title{
    return _lblTitle.text;
}
- (NSString *)message{
    return _lblMessage.text;
}
#pragma mark - Public
- (void)showInView:(UIView *)view{
    if (self.superview || [view viewWithTag:AlertTag]) {
        return;
    }
    self.tag = AlertTag;
    self.frame = view.bounds;
    
    [view addSubview:self];
    self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(1.1, 1.1);

    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05 animations:^{
            self.contentView.transform = CGAffineTransformIdentity;
        }];
    }];
}
- (void)hide:(BOOL)animated{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
//        self.contentTopConstraint.constant = self.frame.size.height;
//        self.contentView.alpha = 0;
//        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Actions
- (IBAction)actionCancel:(UIButton *)sender {
    [self hide:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(userAlertView:dismissWithButtonIndex:)]) {
        [self.delegate userAlertView:self dismissWithButtonIndex:1];
    }
}
- (IBAction)actionOK:(UIButton *)sender {
    [self hide:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(userAlertView:dismissWithButtonIndex:)]) {
        [self.delegate userAlertView:self dismissWithButtonIndex:0];
    }
}

@end
