//
//  PopoverMenu.h
//  XinRanApp
//
//  Created by tianbo on 15-2-3.
//  Copyright (c) 2015年 mac.com All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^dismissBlock)(void);
typedef void (^selectBlock)(int index);

@interface PopoverMenu : UIView
{
    
}
@property (nonatomic, copy) dismissBlock dismissHandler;
@property (nonatomic, copy) selectBlock selectHandler;

- (void)showAtPoint:(CGPoint)point inView:(UIView *)view items:(NSArray*)items;

- (void)dismiss;
@end


@interface MenuItem : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIImage *image;

-(instancetype) initWithText:(NSString*)text image:(UIImage*)image;
@end
