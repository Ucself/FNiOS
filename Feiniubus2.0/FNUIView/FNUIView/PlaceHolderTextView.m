//
//  LYTextView.m
//  LUSIR
//
//  Created by tb on 15/4/22.
//  Copyright (c) 2015年 feiniu. All rights reserved.
//

#import "PlaceHolderTextView.h"
//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND

//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

#define kDefaultFont [UIFont systemFontOfSize:14]
#define kPlaceHolderColor [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1]

@interface PlaceHolderTextView () <UITextViewDelegate>
{
    UILabel *_tipLabel;
    UILabel *_numberLabel;
    NSString *curText;
}
@end

@implementation PlaceHolderTextView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
        
        [self createContent];
    }
    return self;
}

-(instancetype)init
{
    self  = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
        
        [self createContent];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    [self createContent];
    UIFont *tipFont = (self.font == nil)?kDefaultFont:self.font;
//    CGSize size = [placeHolder sizeWithAttributes:@{NSFontAttributeName:tipFont}];
//    CGRect tipFrame = _tipLabel.frame;
//    tipFrame.size = size;
//    _tipLabel.frame = tipFrame;
    _tipLabel.font = tipFont;
    _tipLabel.text = _placeHolder;
}

- (void)setText:(NSString *)text
{
    super.text = text;
    if (text.length>0) {
        _tipLabel.hidden = YES;
    }
}

//- (void)setFrame:(CGRect)frame
//{
//    super.frame = frame;
//    [self createContent];
//    CGRect tipFrame = _tipLabel.frame;
//    tipFrame.origin.x = 5;
//    tipFrame.origin.y = 7;
//    _tipLabel.frame = tipFrame;
////    CGRect numberFrame = _numberLabel.frame;
////    numberFrame.origin.y = frame.size.height-numberFrame.size.height;
////    numberFrame.origin.x = frame.size.width-numberFrame.size.width;
////    _numberLabel.frame = numberFrame;
//}

- (void)setFont:(UIFont *)font
{
    super.font = font;
    [self createContent];
    _tipLabel.font = font;
    _numberLabel.font = font;
}

- (void)setNumberLimit:(int)numberLimit
{
    _numberLimit = numberLimit;
    [self createContent];
    UIFont *tipFont = (self.font == nil)?kDefaultFont:self.font;
//    CGSize size = [[NSString stringWithFormat:@"%d",_numberLimit] sizeWithAttributes:@{NSFontAttributeName:tipFont}];
//    CGRect tipFrame = _numberLabel.frame;
//    tipFrame.size = size;
//    tipFrame.origin.x -= size.width;
//    tipFrame.origin.y -= size.height;
//    _numberLabel.frame = tipFrame;
    _numberLabel.font = tipFont;
    _numberLabel.text = [NSString stringWithFormat:@"%ld/%d", self.text.length, _numberLimit];
}

- (void)setLimitNumberHidden:(BOOL)limitNumberHidden
{
    _limitNumberHidden = limitNumberHidden;
    [self createContent];
    if (_limitNumberHidden) {
        _numberLabel.hidden = YES;
    }else{
        _numberLabel.hidden = NO;
    }
}

- (void)createContent
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = kPlaceHolderColor;
        [self addSubview:_tipLabel];
        
        [_tipLabel makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(20);
            make.top.equalTo(6);
            make.left.equalTo(5);

        }];
    }
//    if (self.delegate == nil) {
//        self.delegate = self;
//    }
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textColor = kPlaceHolderColor;
        [self addSubview:_numberLabel];
        
        [_numberLabel makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(80);
            make.height.equalTo(20);
            make.bottom.equalTo(self.bottom).offset(20);
            make.right.equalTo(self.right);
        }];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSMutableString *showText = [[NSMutableString alloc] initWithString:textView.text];
    [showText replaceCharactersInRange:range withString:text];
    if (showText.length>0) {
        _tipLabel.hidden = YES;
    }else{
        _tipLabel.hidden = NO;
    }
    if (showText.length <= _numberLimit) {
        _numberLabel.text = [NSString stringWithFormat:@"%d",_numberLimit-(int)showText.length];
        return YES;
    }else{
        if (_numberLimit == 0) {
            return YES;
        }
        return NO;
    }
}

-(void)textViewDidChange:(NSNotification*)notification
{
    if (self.text.length>0) {
        _tipLabel.hidden = YES;
    }else{
        _tipLabel.hidden = NO;
    }
    if (self.text.length <= _numberLimit) {
        _numberLabel.text = [NSString stringWithFormat:@"%ld/%d", self.text.length, _numberLimit];
        curText = self.text;
    }else{
        if (_numberLimit == 0) {
            curText = self.text;
        }
        self.text = curText;
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
