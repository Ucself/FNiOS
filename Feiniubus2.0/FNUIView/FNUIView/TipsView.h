//
//  TIpView.h
//  ELive
//
//  Created by  on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    EmShowCenter,
    EmShowBottom,

} ShowAlignment;

@interface TipsView : UIView
{
   
}
@property (nonatomic, retain) UILabel *textLabel;

+(id)sharedInstance;
-(void)showTips:(NSString*)info;
-(void)showTips:(NSString*)info alignment:(ShowAlignment)alignment;
@end
