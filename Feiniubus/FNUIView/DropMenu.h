//
//  DropMenu.h
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/17.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropMenu;
@protocol DropMenuDelegate <NSObject>

- (void) dropMenu:(DropMenu*)dropMenu selectedIndex:(int)index;

@end

@interface DropMenu : UIView
{
    
}
@property(nonatomic, assign) id delegate;


-(instancetype)initWithItems:(NSArray*)items parentView:(UIView*)parentView;


-(void)setText:(NSString*)text;
@end
