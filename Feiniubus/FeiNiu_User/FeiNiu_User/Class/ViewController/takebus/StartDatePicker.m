//
//  StartDatePicker.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/24.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "StartDatePicker.h"

#define TEXT_COLOR [UIColor colorWithWhite:0.5 alpha:1.0]
#define SELECTED_TEXT_COLOR [UIColor darkTextColor]
#define BAR_SEL_COLOR [UIColor colorWithRed:76.0f/255.0f green:172.0f/255.0f blue:239.0f/255.0f alpha:0.8]

//Editable constants
static const float VALUE_HEIGHT = 50.0;
static const float SAVE_AREA_HEIGHT = 70.0;
static const float SAVE_AREA_MARGIN_TOP = 20.0;

static const float SV_MOMENTS_WIDTH = 100.0;
static const float SV_HOURS_WIDTH = 60.0;
static const float SV_MINUTES_WIDTH = 60.0;

//Editable values
float PICKER_HEIGHT = 150;
NSString *FONT_NAME = @"HelveticaNeue";
NSString *NOW = @"Now";

//Static macros and constants
#define SELECTOR_ORIGIN (PICKER_HEIGHT/2.0-VALUE_HEIGHT/2.0)
#define SAVE_AREA_ORIGIN_Y self.bounds.size.height-SAVE_AREA_HEIGHT
#define PICKER_ORIGIN_Y SAVE_AREA_ORIGIN_Y-SAVE_AREA_MARGIN_TOP-PICKER_HEIGHT
#define BAR_SEL_ORIGIN_Y PICKER_HEIGHT/2.0-VALUE_HEIGHT/2.0

//Custom scrollView
@interface MGPickerScrollView ()

@property (nonatomic, strong) NSArray *arrValues;
@property (nonatomic, strong) UIFont *cellFont;

@end


@implementation MGPickerScrollView

//Constants
const float LBL_BORDER_OFFSET = 8.0;

//Configure the tableView
- (id)initWithFrame:(CGRect)frame andValues:(NSArray *)arrayValues
      withTextAlign:(NSTextAlignment)align andTextSize:(float)txtSize {
    
    if(self = [super initWithFrame:frame]) {
        [self setScrollEnabled:YES];
        [self setShowsVerticalScrollIndicator:NO];
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setContentInset:UIEdgeInsetsMake(BAR_SEL_ORIGIN_Y, 0.0, BAR_SEL_ORIGIN_Y, 0.0)];
        
        _cellFont = [UIFont fontWithName:FONT_NAME size:txtSize];
        
        if(arrayValues)
            _arrValues = [arrayValues copy];
    }
    return self;
}


//Dehighlight the last cell
- (void)dehighlightLastCell {
    NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_tagLastSelected inSection:0], nil];
    [self setTagLastSelected:-1];
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
}

//Highlight a cell
- (void)highlightCellWithIndexPathRow:(NSUInteger)indexPathRow {
    [self setTagLastSelected:indexPathRow];
    NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_tagLastSelected inSection:0], nil];
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
}

@end

///////////////////////////////////////////

@interface StartDatePicker ()


@property (nonatomic, strong) NSArray *arrDays;
@property (nonatomic, strong) NSArray *arrHours;
@property (nonatomic, strong) NSArray *arrMinutes;
@property (nonatomic, strong) NSArray *arrTimes;

@property (nonatomic, strong) MGPickerScrollView *svDays;
@property (nonatomic, strong) MGPickerScrollView *svHours;
@property (nonatomic, strong) MGPickerScrollView *svMins;
@end

@implementation StartDatePicker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self initialize];
//        [self buildControl];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    [self initialize];
    [self buildControl];
}

- (void)initialize {
    
    _arrDays = @[@"马上用车",
                 @"明天",
                 @"后天",
                ];
    
    _arrTimes = @[NOW,
                  @"10:00 AM",
                  @"1:00 PM",
                  @"4:30 PM",
                  @"7:00 PM",
                  @"8:30 PM",
                  @"1:00 AM",
                  ];
    
    
    NSMutableArray *arrHours = [[NSMutableArray alloc] initWithCapacity:24];
    for(int i=1; i<=24; i++) {
        [arrHours addObject:[NSString stringWithFormat:@"%@%d",(i<10) ? @"0":@"", i]];
    }
    _arrHours = [NSArray arrayWithArray:arrHours];
    
    //Create array Minutes
    NSMutableArray *arrMinutes = [[NSMutableArray alloc] initWithCapacity:60];
    for(int i=0; i<60; i++) {
        [arrMinutes addObject:[NSString stringWithFormat:@"%@%d",(i<10) ? @"0":@"", i]];
    }
    _arrMinutes = [NSArray arrayWithArray:arrMinutes];
    
    
}

- (void)buildControl {
    //self.backgroundColor = [UIColor yellowColor];
    UIView *pickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, PICKER_ORIGIN_Y, self.frame.size.width, PICKER_HEIGHT)];
    [pickerView setBackgroundColor:self.backgroundColor];
    
    //Create bar selector
    //UIView *barSel = [[UIView alloc] initWithFrame:CGRectMake(0.0, BAR_SEL_ORIGIN_Y, self.frame.size.width, VALUE_HEIGHT)];
    //[barSel setBackgroundColor:BAR_SEL_COLOR];
    
    _svDays = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, SV_MOMENTS_WIDTH, PICKER_HEIGHT) andValues:_arrDays withTextAlign:NSTextAlignmentRight andTextSize:16.0];
    _svDays.tag = 0;
    [_svDays setDelegate:self];
    [_svDays setDataSource:self];
    
    //Create the second column (hours) of the picker
    _svHours = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(SV_MOMENTS_WIDTH, 0.0, SV_HOURS_WIDTH, PICKER_HEIGHT) andValues:_arrHours withTextAlign:NSTextAlignmentCenter  andTextSize:22.0];
    _svHours.tag = 1;
    [_svHours setDelegate:self];
    [_svHours setDataSource:self];
    
    //Create the third column (minutes) of the picker
    _svMins = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(_svHours.frame.origin.x+SV_HOURS_WIDTH, 0.0, SV_MINUTES_WIDTH, PICKER_HEIGHT) andValues:_arrMinutes withTextAlign:NSTextAlignmentCenter andTextSize:22.0];
    _svMins.tag = 2;
    [_svMins setDelegate:self];
    [_svMins setDataSource:self];
    
    //Layer gradient
    CAGradientLayer *gradientLayerTop = [CAGradientLayer layer];
    gradientLayerTop.frame = CGRectMake(0.0, 0.0, pickerView.frame.size.width, PICKER_HEIGHT/2.0);
    gradientLayerTop.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, (id)self.backgroundColor.CGColor, nil];
    gradientLayerTop.startPoint = CGPointMake(0.0f, 0.7f);
    gradientLayerTop.endPoint = CGPointMake(0.0f, 0.0f);
    
    CAGradientLayer *gradientLayerBottom = [CAGradientLayer layer];
    gradientLayerBottom.frame = CGRectMake(0.0, PICKER_HEIGHT/2.0, pickerView.frame.size.width, PICKER_HEIGHT/2.0);
    gradientLayerBottom.colors = gradientLayerTop.colors;
    gradientLayerBottom.startPoint = CGPointMake(0.0f, 0.3f);
    gradientLayerBottom.endPoint = CGPointMake(0.0f, 1.0f);
    
    [self addSubview:pickerView];
    
    //[pickerView addSubview:barSel];
    
    //Add scrollViews
    [pickerView addSubview:_svDays];
    [pickerView addSubview:_svHours];
    [pickerView addSubview:_svMins];
    
    [pickerView.layer addSublayer:gradientLayerTop];
    [pickerView.layer addSublayer:gradientLayerBottom];
    
    //Set the time to now
    [self setTime:NOW];
    [self switchToDay:0];
}

- (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:locale];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

- (void)setTime:(NSString *)time {
    //Get the string
    NSString *strTime;
    if([time isEqualToString:NOW])
        strTime = [self stringFromDate:[NSDate date] withFormat:@"hh:mm a"];
    else
        strTime = (NSString *)time;
    
    //Split
    NSArray *comp = [strTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" :"]];
    
    //Set the tableViews
    [_svHours dehighlightLastCell];
    [_svMins dehighlightLastCell];
    
    //Center the other fields
    [self centerCellWithIndexPathRow:([comp[0] intValue]%12)-1 forScrollView:_svHours];
    [self centerCellWithIndexPathRow:[comp[1] intValue] forScrollView:_svMins];
}

//Switch to the previous or next day
- (void)switchToDay:(NSInteger)dayOffset {
    //Calculate and save the new date
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [NSDateComponents new];
    
    //Set the offset
    [offsetComponents setDay:dayOffset];
    
//    NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:_selectedDate options:0];
//    _selectedDate = newDate;
//    
//    //Show new date
//    [_lblWeekDay setText:[self stringFromDate:_selectedDate withFormat:@"EEEE"]];
//    [_lblDayMonth setText:[self stringFromDate:_selectedDate withFormat:@"dd LLLL yyyy"]];
}

//Center the value in the bar selector
- (void)centerValueForScrollView:(MGPickerScrollView *)scrollView {
    
    //Takes the actual offset
    float offset = scrollView.contentOffset.y;
    
    //Removes the contentInset and calculates the prcise value to center the nearest cell
    offset += scrollView.contentInset.top;
    int mod = (int)offset%(int)VALUE_HEIGHT;
    float newValue = (mod >= VALUE_HEIGHT/2.0) ? offset+(VALUE_HEIGHT-mod) : offset-mod;
    
    //Calculates the indexPath of the cell and set it in the object as property
    NSInteger indexPathRow = (int)(newValue/VALUE_HEIGHT);
    
    //Center the cell
    [self centerCellWithIndexPathRow:indexPathRow forScrollView:scrollView];
}

//Center phisically the cell
- (void)centerCellWithIndexPathRow:(NSUInteger)indexPathRow forScrollView:(MGPickerScrollView *)scrollView {
    
    if(indexPathRow >= [scrollView.arrValues count]) {
        indexPathRow = [scrollView.arrValues count]-1;
    }
    
    float newOffset = indexPathRow*VALUE_HEIGHT;
    
    //Re-add the contentInset and set the new offset
    newOffset -= BAR_SEL_ORIGIN_Y;
    [scrollView setContentOffset:CGPointMake(0.0, newOffset) animated:YES];
    
    //Highlight the cell
    [scrollView highlightCellWithIndexPathRow:indexPathRow];
    
    //Automatic setting of the time
    if(scrollView == _svDays) {
        [self setTime:@"10:00"];
        //[self setTime:_arrTimes[indexPathRow]];
    }

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![scrollView isDragging]) {
        [self centerValueForScrollView:(MGPickerScrollView *)scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self centerValueForScrollView:(MGPickerScrollView *)scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    MGPickerScrollView *sv = (MGPickerScrollView *)scrollView;
    
    [sv dehighlightLastCell];
}

#pragma - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MGPickerScrollView *sv = (MGPickerScrollView *)tableView;
    return [sv.arrValues count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"reusableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    MGPickerScrollView *sv = (MGPickerScrollView *)tableView;
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:sv.cellFont];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell.textLabel setTextColor:(indexPath.row == sv.tagLastSelected) ? SELECTED_TEXT_COLOR : TEXT_COLOR];
//    [cell.textLabel setFont:(indexPath.row == sv.tagLastSelected) ? [UIFont systemFontOfSize:18] :[UIFont systemFontOfSize:15] ];
    [cell.textLabel setText:sv.arrValues[indexPath.row]];
    
    if (sv == self.svDays) {
        cell.textLabel.textColor = UIColor_DefGreen;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return VALUE_HEIGHT;
}
@end
