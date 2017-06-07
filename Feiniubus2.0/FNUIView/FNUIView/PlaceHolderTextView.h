//
//  LYTextView.h
//  LUSIR
//
//  Created by tb on 15/4/22.
//  Copyright (c) 2015年 feiniu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceHolderTextView : UITextView

@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, assign) int numberLimit;
@property (nonatomic, assign) BOOL limitNumberHidden;

@end
