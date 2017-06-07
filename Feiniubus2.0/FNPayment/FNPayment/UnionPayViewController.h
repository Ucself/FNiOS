//
//  UnionPayViewController.h
//  FNPayment
//
//  Created by tianbo on 2016/11/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIViewController.h>



@interface UnionPayViewController : BaseUIViewController

@property (nonatomic, copy) void (^successCallback)(BOOL success);

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *body;

@end
