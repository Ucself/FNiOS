//
//  UserCustomAlertView.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserCustomAlertView.h"
#import <FNCommon/NSString+CalculateSize.h>

#define AlertTag 0x123

@interface UserCustomAlertView ()
{
    int contentWidth;
}
@property (strong, nonatomic)  UILabel *lblTitle;
@property (strong, nonatomic)  UILabel *lblMessage;
@property (strong, nonatomic)  UIButton *btnCancel;
@property (strong, nonatomic)  UIButton *btnOK;
@property (strong, nonatomic)  UIView *contentView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopConstraint;

@end
@implementation UserCustomAlertView
+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)msg delegate:(id<UserCustomAlertViewDelegate>)delegate{
    //UserCustomAlertView *alert = [[[NSBundle mainBundle] loadNibNamed:@"UserCustomAlertView" owner:self options:nil] firstObject];
    UserCustomAlertView *alert = [[UserCustomAlertView alloc] init];
    alert.title = title;
    alert.message = msg;
    alert.delegate = delegate;
    alert.contentView.layer.cornerRadius = 10;
    //alert.contentView.clipsToBounds = YES;
    [alert.btnOK setTitle:@"确定" forState:UIControlStateNormal];
    alert.btnCancel = nil;
    return alert;
}
+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)msg delegate:(id<UserCustomAlertViewDelegate>)delegate buttons:(NSArray *)buttonsTitle{
    //UserCustomAlertView *alert = [[[NSBundle mainBundle] loadNibNamed:@"UserCustomAlertView" owner:self options:nil] firstObject];
    UserCustomAlertView *alert = [[UserCustomAlertView alloc] init];
    alert.title = title;
    alert.message = msg;
    alert.delegate = delegate;
    alert.contentView.layer.cornerRadius = 10;
    //alert.contentView.clipsToBounds = YES;
    if ([buttonsTitle firstObject] && [[buttonsTitle firstObject] isKindOfClass:[NSString class]]) {
        [alert.btnOK setTitle:[buttonsTitle firstObject] forState:UIControlStateNormal];
    }
    if (buttonsTitle.count > 1 && [buttonsTitle lastObject] && [[buttonsTitle lastObject] isKindOfClass:[NSString class]]) {
        [alert.btnCancel setTitle:[buttonsTitle lastObject] forState:UIControlStateNormal];
    }
    else {
        alert.btnCancel = nil;
    }
    return alert;
}

-(instancetype)init
{
    self  = [super init];
    if (self) {
        [self initUI];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.message || self.message.length == 0) {
        [_lblTitle remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.top.equalTo(_contentView.top).offset(35);
        }];
    }
    else {
        
        if (_disableDismiss) {
            [_lblTitle remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_contentView);
                make.top.equalTo(_contentView.top).offset(28);
            }];
            
            _lblMessage.textAlignment = NSTextAlignmentLeft;
            [_lblMessage remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_lblTitle.bottom).offset(20);
                make.left.equalTo(25);
                make.right.equalTo(_contentView.right).offset(-25);
            }];
            
            float height = [_lblMessage.text heightWithFont:[UIFont systemFontOfSize:13] constrainedToWidth:249];
            [_contentView remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(contentWidth);
                make.height.equalTo(height + 145);
                make.centerX.equalTo(self);
                make.centerY.equalTo(self);
            }];
        }
    }
    
    
    if (self.btnCancel == nil) {
        [_btnOK setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
        [_contentView sendSubviewToBack:_btnOK];
        [_btnOK makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_contentView.left);
            make.bottom.equalTo(_contentView.bottom);
            make.height.equalTo(50);
            make.right.equalTo(_contentView.right);

        }];
    }
}

-(void)setIsLongMessage:(BOOL)isLongMessage{
    
    _isLongMessage = isLongMessage;
    
    if (_isLongMessage) {
        contentWidth = 295;
    }
    else {
        contentWidth = 249;
    }
    [_contentView updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contentWidth);
    }];
}
-(void)setDisableDismiss:(BOOL)disableDismiss
{
    _disableDismiss = disableDismiss;
    if (_disableDismiss) {
        contentWidth = 295;
        
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic_niuniu"]];
        [_contentView addSubview:view];
        
        [view makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.bottom.equalTo(_contentView.top).offset(20);
            make.width.equalTo(140);
            make.height.equalTo(84);
        }];
        
    }
    else {
        contentWidth = 249;
    }
}

-(void)initUI
{
    contentWidth = 249;
    
    self.backgroundColor = UITranslucentBKColor;
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];

    [_contentView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contentWidth);
        make.height.equalTo(143);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    
    _btnOK = [UIButton buttonWithType:UIButtonTypeSystem];
    _btnOK.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_btnOK setTitleColor:UITextColor_LightGray forState:UIControlStateNormal];
    [_btnOK addTarget: self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btnOK];
    
    _btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
    _btnCancel.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_btnCancel setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
    [_btnCancel addTarget: self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_btnCancel];
    
    [_btnOK makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView.left);
        make.bottom.equalTo(_contentView.bottom);
        make.height.equalTo(44);
        make.right.equalTo(_btnCancel.left);
        make.width.equalTo(_btnCancel.width);
    }];
    
    [_btnCancel makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_contentView.right);
        make.bottom.equalTo(_contentView.bottom);
        make.height.equalTo(44);
        make.left.equalTo(_btnOK.right);
        make.width.equalTo(_btnOK.width);
    }];
    
    
    UIView *infoView = [[UIView alloc] init];
    //infoView.backgroundColor = [UIColor greenColor];
    [_contentView addSubview:infoView];
    
    [infoView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView.left);
        make.top.equalTo(_contentView.top);
        make.right.equalTo(_contentView.right);
        make.bottom.equalTo(_btnOK.top);
    }];
    
    _lblTitle = [[UILabel alloc] init];
    _lblTitle.textColor = UITextColor_Black;
    _lblTitle.font = [UIFont systemFontOfSize:18];
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    _lblTitle.tag = 1001;
    [_contentView addSubview:_lblTitle];
    
    [_lblTitle makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_contentView);
        make.top.equalTo(_contentView.top).offset(20);
    }];
    
    _lblMessage = [[UILabel alloc] init];
    _lblMessage.textColor = UITextColor_LightGray;
    _lblMessage.font = [UIFont systemFontOfSize:13];
    _lblMessage.textAlignment = NSTextAlignmentCenter;
    _lblMessage.numberOfLines = 0;
    _lblMessage.lineBreakMode = NSLineBreakByWordWrapping;
    
    [_contentView addSubview:_lblMessage];
    [_lblMessage makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_contentView);
        make.top.equalTo(_contentView.top).offset(50);
        make.width.equalTo(_contentView.width);
    }];
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = UIColorFromRGB(0xE6E6E6);
    [_contentView addSubview:line1];
    
    [line1 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView.left);
        make.right.equalTo(_contentView.right);
        make.bottom.equalTo(_btnOK.top);
        make.height.equalTo(0.5);
    }];
    
    UIView *line2 = [[UIView alloc] init];
    line2.backgroundColor = UIColorFromRGB(0xE6E6E6);
    [_contentView addSubview:line2];
    
    [line2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_btnOK.right);
        make.top.equalTo(_btnOK.top);
        make.height.equalTo(_btnOK.height);
        make.width.equalTo(0.5);
        
    }];

}

#pragma mark - Setter && Getter
- (void)setTitle:(NSString *)title{
    _title = title;
    
    NSRange range = [title rangeOfString:@"\n"];
    if (range.location != NSNotFound) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 1.5;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, title.length)];
        
        _lblTitle.attributedText = attributedString;
    }
    else {
        _lblTitle.text = title;
    }
}
- (void)setMessage:(NSString *)message{
    
    message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _message = message;
    _lblMessage.text = message;
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3.0];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];
    _lblMessage.attributedText = attributedString;
    _lblMessage.textAlignment = NSTextAlignmentCenter;
}
//- (NSString *)title{
//    return _lblTitle.text;
//}
//- (NSString *)message{
//    return _lblMessage.text;
//}
#pragma mark - Public
- (void)showInView:(UIView *)view{
    if (self.superview) {   // || [view viewWithTag:AlertTag]
        return;
    }
    //self.tag = AlertTag;
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
    if (!self.disableDismiss) {
        [self hide:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(userAlertView:dismissWithButtonIndex:)]) {
        [self.delegate userAlertView:self dismissWithButtonIndex:1];
    }
}
- (IBAction)actionOK:(UIButton *)sender {
    if (!self.disableDismiss) {
        [self hide:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(userAlertView:dismissWithButtonIndex:)]) {
        [self.delegate userAlertView:self dismissWithButtonIndex:0];
    }
}

@end
