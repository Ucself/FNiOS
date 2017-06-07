//
//  TIpView.m
//  ELive
//
//  Created by  on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "TipsView.h"
#import <QuartzCore/QuartzCore.h>

@interface TipsView ()

@property (nonatomic, assign) ShowAlignment alignment;
@end

@implementation TipsView


+(id)sharedInstance
{
    static TipsView *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        CGRect rt = [[UIScreen mainScreen] bounds];
        instance = [[TipsView alloc] initWithFrame:rt];
    });

	return instance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.alpha = 0.8;
        self.backgroundColor = [UIColor blackColor];
        [self.layer setCornerRadius:5.0];
        
        _alignment = EmShowBottom;
        
        CGRect rt = frame;
        rt.origin.x = 0;
        rt.origin.y = 0;
        _textLabel = [[UILabel alloc] initWithFrame:rt];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:17.0];
        _textLabel.numberOfLines=2;
        [_textLabel sizeToFit];
        [self addSubview:_textLabel];
    } 
    return self;
}

- (void)layoutSubviews
{	
	[super layoutSubviews];
    
    CGRect rcScreen = [UIScreen mainScreen].bounds;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:_textLabel.font,
                                 NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize labelSize = [_textLabel.text boundingRectWithSize:CGSizeMake(240, 100)
                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil].size;
    
//    CGSize labelSize = [textLabel.text sizeWithFont:font constrainedToSize:CGSizeMake(rcScreen.size.width,2000) lineBreakMode:NSLineBreakByCharWrapping];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width+20, labelSize.height+20);
    
    if (_alignment == EmShowBottom) {
        self.center = CGPointMake(rcScreen.size.width/2, rcScreen.size.height - 200);
    }
    else {
        self.center = CGPointMake(rcScreen.size.width/2, rcScreen.size.height/2);
    }
    
    _textLabel.frame = self.bounds;
}

-(void)dealloc
{

}

- (void)showTips:(NSString*)info
{
    _textLabel.text = info;
    [self setNeedsLayout];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    [self performSelector:@selector(hideTipView) withObject:self afterDelay:2.5];
}

-(void)showTips:(NSString*)info alignment:(ShowAlignment)alignment
{
    _textLabel.text = info;
    _alignment = alignment;
    [self setNeedsLayout];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    [self performSelector:@selector(hideTipView) withObject:self afterDelay:2.5];
}

-(void)hideTipView
{
    [self removeFromSuperview];
}

@end
