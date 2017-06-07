//
//  CallCarTopPlaceView.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CallCarTopPlaceView.h"

@interface CallCarTopPlaceView()

@end

@implementation CallCarTopPlaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"CallCarTopPlaceView" owner:self options:nil][0];
        
    }
    return self;
}

@end
