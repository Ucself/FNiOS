//
//  CalloutView.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CalloutView.h"


@implementation CalloutView


+ (instancetype)sharedInstance{
    
    CalloutView *view = [[[NSBundle mainBundle] loadNibNamed:@"CalloutView" owner:self options:nil] firstObject];

    return view;
}


- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20 - 40, 45)];
        _addressLabel.textColor = [UIColor blackColor];
        _addressLabel.font = Font(15);
        _addressLabel.numberOfLines = 2;
        [self addSubview:_addressLabel];
        
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_addressLabel.frame), self.frame.size.width - 20, .5f)];
        line.backgroundColor = [UIColor colorWithWhite:.8 alpha:.8];
        [self addSubview:line];
        
        _minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(line.frame) + 10, self.frame.size.width - 20, 20)];
        _minuteLabel.textColor = [UIColor blackColor];
        _minuteLabel.font = Font(13);
        [self addSubview:_minuteLabel];
        _minuteLabel.text = @"接送车最快20分钟就来接驾";
        
        _backButton = [UIButton buttonWithType:0];
        _backButton.frame = CGRectMake(self.frame.size.width - 30 - 10, 10, 30, 45);
        [_backButton setImage:[UIImage imageNamed:@"arrows_right"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(calloutJumpAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        _backgroundButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
        [_backgroundButton addTarget:self action:@selector(jumpClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundButton];
        
    }
    return self;
}


- (void)setMinuteWithString:(NSString*)_str{
    if (_str && _str.length > 0) {
        NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"接送车最快%@就来接驾",_str]];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1 green:172/255.f blue:41/255.f alpha:1] range:NSMakeRange(5,_str.length)];
        _minuteLabel.attributedText = attString;
    }
}


- (void)jumpClick{
    
    if (_delegate && [_delegate respondsToSelector:@selector(jumpAction)]) {
        [self.delegate jumpAction];
    }
}

- (void)calloutJumpAction:(id)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(jumpAction)]) {
        [self.delegate jumpAction];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
