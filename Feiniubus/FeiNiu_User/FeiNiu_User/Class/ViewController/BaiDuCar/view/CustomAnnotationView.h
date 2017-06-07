//
//  CustomAnnotationView.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
@class CalloutView;

@interface CustomAnnotationView : MAAnnotationView

@property (nonatomic, readonly) CalloutView *calloutView;

@end
