//
//  StartDatePicker.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/24.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FNUIVIEW/BaseUIView.h>

//Scroll view
@interface MGPickerScrollView : UITableView

@property NSInteger tagLastSelected;

- (void)dehighlightLastCell;
- (void)highlightCellWithIndexPathRow:(NSUInteger)indexPathRow;

@end




@interface StartDatePicker : UIView<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end
