//
//  TagView.h
//  FeiNiu_User
//
//  Created by tianbo on 16/6/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>

#if TARGET_INTERFACE_BUILDER

IB_DESIGNABLE
@interface EvaluationTagView (IBExtension)
@property (nonatomic, assign) IBInspectable BOOL enabled;
@end
#endif


@interface EvaluationTagView : BaseUIView


@property (nonatomic, copy)void (^selectChangeAction)(NSArray* items);


-(void)addItems:(NSArray*)items;



@end


