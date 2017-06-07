//
//  PeopleTypeSelectorView.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/4/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FNUIView/BaseUIView.h>

typedef void (^SelectCallbackBlock)(NSInteger selIndex);

@interface SelectPickerView : BaseUIView <UIPickerViewDelegate,UIPickerViewDataSource>
{
    

}

+(void)showInView:(UIView*)view items:(NSArray*)items selectIndex:(NSInteger)selectIndex completion:(SelectCallbackBlock)completeBlock;

//- (void)showInView:(UIView *)view;
//- (void)hideInView:(UIView *)view;

@end
