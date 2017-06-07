//
//  CustomAnnotationView.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CalloutView.h"

@interface CustomAnnotationView ()

@property (nonatomic, readwrite, strong) CalloutView *calloutView;

@end

@implementation CustomAnnotationView

- (instancetype)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {

//        self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

//        _calloutView = [CalloutView sharedInstance];
        
    }

    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{

    if (self.selected == selected)
    {
        return;
    }
    
    if (selected){
        
//        _calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x, - CGRectGetHeight(_calloutView.bounds) / 2.f + self.calloutOffset.y - 20);
        
        _calloutView.addressLabel.text = self.annotation.subtitle;

        _calloutView.minuteLabel.text  = @"20分钟";

//        _calloutView.center = CGPointMake(160, 100);
//        [ addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    [super setSelected:selected animated:animated];

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
