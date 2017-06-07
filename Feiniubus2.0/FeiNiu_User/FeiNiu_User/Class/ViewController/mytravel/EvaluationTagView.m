//
//  TagView.m
//  FeiNiu_User
//
//  Created by tianbo on 16/6/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "EvaluationTagView.h"
#import <FNCommon/NSString+CalculateSize.h>



#if TARGET_INTERFACE_BUILDER
@implementation EvaluationTagView(IBExtension)
-(void)setEnabled:(BOOL)enabled
{
    self.isEnabled = enabled;
}

@end
#endif


@interface EvaluationTagView ()

@property (nonatomic, assign) BOOL isEnabled;
@end
@implementation EvaluationTagView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        
    }
    return self;
}

-(void)addItems:(NSArray*)items
{
    int top = 0;
    int left = 5;
    UIView *previous = nil;
    for (int i=0; i<items.count; i++) {
        NSString *text = items[i];
        
        int width = [text widthWithFont:[UIFont systemFontOfSize:13] constrainedToHeight:25]+15;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitle:text forState:UIControlStateNormal];
        if (self.isEnabled) {
            btn.userInteractionEnabled = YES;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:UIColor_DefOrange] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[self imageWithColor:UIColor_DefOrange] forState:UIControlStateSelected];
        }
        else {
            btn.userInteractionEnabled = NO;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self imageWithColor:UIColor_DefOrange] forState:UIControlStateNormal];
        }

        
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        
        if (previous) {
            int scope = self.frame.size.width - previous.frame.origin.x - previous.frame.size.width - 10;
            if (scope > width) {
                left = previous.frame.origin.x + previous.frame.size.width +5;
            }
            else {
                previous = nil;
                left = 5;
                top += 30;
            }
        }
        
        
        btn.frame = CGRectMake(left, top, width, 25);
        
        [self addSubview:btn];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        previous = btn;
    }
}

-(void)setIsEnabled:(BOOL)isEnabled
{
    _isEnabled = isEnabled;
    
    //[self addItems:@[@"车还不错, 很准时", @"司机不错", @"很准时"]];
}

- (UIImage*)imageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
    
}


-(void)btnClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    
    for (UIButton *btn in self.subviews) {
        
    }
    
    if (self.selectChangeAction) {
        self.selectChangeAction(nil);
    }
}
@end



