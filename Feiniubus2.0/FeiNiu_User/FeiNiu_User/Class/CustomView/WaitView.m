//
//  WaitView.m
//  GTunes
//
//  Created by huangzan on 09-5-4.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WaitView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+bundle.h"

@interface WaitView ()
{
    UIView *viewBK;
    UIImageView *ivProgress;
    UILabel * textLabel;

}
@property (nonatomic, retain) UILabel * textLabel;

@end

@implementation WaitView
@synthesize textLabel;

+ (WaitView *) sharedInstance 
{
    static WaitView *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[WaitView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    
    return instance;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) 
	{
		[self setBackgroundColor:[UIColor clearColor]];
		//[self setBackgroundColor:[UIColor redColor]];
        viewBK = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 115, 65)];
        viewBK.backgroundColor = [UIColor whiteColor];
        viewBK.layer.cornerRadius = 5;
        [self addSubview:viewBK];
        
        
        ivProgress = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 58, 10)];
        [viewBK addSubview:ivProgress];
        
        NSArray *arImgs = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"loading_00000"],
                           [UIImage imageNamed:@"loading_00001"],
                           [UIImage imageNamed:@"loading_00002"],
                           [UIImage imageNamed:@"loading_00003"],
                           [UIImage imageNamed:@"loading_00004"],
                           [UIImage imageNamed:@"loading_00005"],
                           [UIImage imageNamed:@"loading_00006"],
                           [UIImage imageNamed:@"loading_00007"],
                           [UIImage imageNamed:@"loading_00008"],
                           [UIImage imageNamed:@"loading_00009"],
                           [UIImage imageNamed:@"loading_000010"],
                           [UIImage imageNamed:@"loading_000011"],
                           [UIImage imageNamed:@"loading_000012"],
                           [UIImage imageNamed:@"loading_000013"],
                           [UIImage imageNamed:@"loading_000014"],
                           [UIImage imageNamed:@"loading_000015"], nil];
        ivProgress.animationImages = arImgs;
        ivProgress.animationDuration = 3;
        ivProgress.animationRepeatCount = 0;
		
		textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		textLabel.backgroundColor = [UIColor clearColor];
		textLabel.opaque = NO;
		[textLabel  setTextAlignment:NSTextAlignmentCenter];
		textLabel.baselineAdjustment=UIBaselineAdjustmentAlignCenters;		
		textLabel.textColor = [UIColor darkGrayColor];
		textLabel.highlightedTextColor = [UIColor blackColor];
		textLabel.font = [UIFont systemFontOfSize:15.0];
        textLabel.text = @"努力加载中...";
		[viewBK addSubview:textLabel];
        [textLabel sizeToFit];

	}
	return self;
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	
    viewBK.center = self.center;
	
    CGRect frame = viewBK.bounds;
    
    
    ivProgress.center = CGPointMake(self.center.x, self.center.y -10);

    textLabel.frame = CGRectMake(0,
                                 self.center.y + 30,
                                 frame.size.width,
                                 30);
    
}

- (void)dealloc
{
    self.textLabel = nil;
}

-(void)start{
    
    if (![[[UIApplication sharedApplication] keyWindow] viewWithTag:18990]) {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
        self.tag = 18990;

        [ivProgress startAnimating];
    }
}


-(void)stop{
    if (ivProgress.isAnimating) {
        [ivProgress stopAnimating];
    }
	[self removeFromSuperview];
}


-(void)setStateText:(NSString*)text
{
	[textLabel setText:text];
	[self layoutSubviews];
	[self setNeedsDisplay];
}

@end
