//
//  UINavigationVIew.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UINavigationVIew.h"

@interface UINavigationView ()
{
    int rightBtnWidth;
}
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIButton *btnLeft;
@property (nonatomic, strong) UIButton *btnRight;
@property (nonatomic, strong) UIView *line;
@end

@implementation UINavigationView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

//运行从IB中加载
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}

//渲染传入IB中
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}


-(void)initUI
{
    rightBtnWidth = 40;
    _labelTitle = [[UILabel alloc] init];
    _labelTitle.textColor = UIColor_DefOrange;
    _labelTitle.font = [UIFont boldSystemFontOfSize:17];
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    _labelTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:_labelTitle];
    
    _btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnLeft.contentMode = UIViewContentModeScaleAspectFit;
    [_btnLeft addTarget:self action:@selector(btnLeftClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnLeft];
    
    _btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnRight.contentMode = UIViewContentModeScaleAspectFit;
    [_btnRight setTitleColor:UIColor_DefOrange forState:UIControlStateNormal];
    _btnRight.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [_btnRight addTarget:self action:@selector(btnRightClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_btnRight];
    
    _line = [[UIView alloc] init];
    _line.backgroundColor = [UIColor lightGrayColor];
    
    [self setBackgroundColor:UIColorFromRGB(0xF4F4F4)];
    [self addSubview:_line];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _labelTitle.frame = CGRectMake(60, 20, self.bounds.size.width-120, self.bounds.size.height-20);
    
    _btnLeft.frame = CGRectMake(10, 27, 50, 30);
    
    _btnRight.frame = CGRectMake(self.bounds.size.width-rightBtnWidth-10, 27, rightBtnWidth, 30);
    
    _line.frame = CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5);
}

-(void)setRightTitleColor:(UIColor *)rightTitleColor
{
    [self.btnRight setTitleColor:rightTitleColor forState:UIControlStateNormal];
}


-(void)setTitle:(NSString *)title
{
    self.labelTitle.text = title;
}

-(void)setLeftImage:(UIImage *)leftImage
{
    if (leftImage) {
        _leftImage = leftImage;
        [self.btnLeft setImage:self.leftImage forState:UIControlStateNormal];
    }
    
}

-(void)setRightImage:(UIImage *)rightImage
{
    if (rightImage) {
        _rightImage = rightImage;
        [self.btnRight setImage:self.rightImage forState:UIControlStateNormal];
    }
    
}

-(void)setRightTitle:(NSString *)rightTitle
{
    if (!rightTitle || rightTitle.length == 0){
        self.btnRight.userInteractionEnabled = NO;
        [self.btnRight setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        self.btnRight.userInteractionEnabled = YES;
        _rightTitle = rightTitle;
        [self.btnRight setTitle:self.rightTitle forState:UIControlStateNormal];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:_btnRight.titleLabel.font,
                                     NSParagraphStyleAttributeName:paragraphStyle.copy};
        CGSize labelSize = [_btnRight.titleLabel.text boundingRectWithSize:CGSizeMake(80, 30)
                                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                     attributes:attributes
                                                        context:nil].size;
        
        rightBtnWidth = labelSize.width + 10;
        [self setNeedsLayout];
    }
}

#pragma mark -
-(void)btnLeftClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(navigateionViewBack)]) {
        [self.delegate navigateionViewBack];
    }
}

-(void)btnRightClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(navigateionViewRight)]) {
        [self.delegate navigateionViewRight];
    }
}

@end
