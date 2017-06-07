//
//  TagView.h
//  FeiNiu_User
//
//  Created by tianbo on 16/6/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIView.h>

#define AutoLayoutTagsViewKeyName       "keyName"
#define AutoLayoutTagsViewKeySelected   "isSelected"

#if TARGET_INTERFACE_BUILDER
IB_DESIGNABLE
@interface AutoLayoutTagsView (IBExtension)
@property (nonatomic, assign) IBInspectable BOOL enabled;
@end
#endif

@interface AutoLayoutTagsView : BaseUIView

@property (nonatomic, assign) BOOL isEnabled;

@property (nonatomic, copy)void (^selectChangeAction)(NSArray* items);
@property (nonatomic, copy)void (^selectChangeActionDic)(NSDictionary* items);

-(void)addItems:(NSArray*)items;

//返回所需行数
-(int)addItemsDictionary:(NSDictionary*)items;

-(void)removeAll;

@end


