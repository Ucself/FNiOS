//
//  OrderListViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/10.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "OrderMainViewController.h"
#import "LoginViewController.h"
#import "AuthorizeCache.h"
#import "FeiNiu_User-Swift.h"


@interface OrderMainViewController ()<UIScrollViewDelegate>
{
    int specIndex;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (strong, nonatomic) NSMutableArray *arControllers;

@end

@implementation OrderMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置颜色
    [self.segControl setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xB1B1B5),NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} forState:UIControlStateNormal];
    self.segControl.layer.masksToBounds = true;
    self.segControl.layer.cornerRadius = 14.0;
    self.segControl.layer.borderWidth = 1;
    self.segControl.layer.borderColor = UIColorFromRGB(0xBBBBBF).CGColor;
    
    [self.segControl addTarget:self action:@selector(segControlAction:) forControlEvents:UIControlEventValueChanged];
    
    [self initControllers];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.segControl.selectedSegmentIndex = specIndex;
    if (specIndex == 0) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else if (specIndex == 1) {
        [self.scrollView setContentOffset:CGPointMake(deviceWidth, 0) animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initControllers{
    float width = [UIScreen mainScreen].bounds.size.width;
    self.scrollView.contentSize = CGSizeMake(width*2, 0);
    self.arControllers = [NSMutableArray array];
    
    ScheduleOrderListViewController *schedule = [ScheduleOrderListViewController instanceWithStoryboardName:@"MyTravel"];
    [self.arControllers addObject:schedule];
    ShuttleBusOrderListViewController *shuttle = [ShuttleBusOrderListViewController instanceWithStoryboardName:@"MyTravel"];
    [self.arControllers addObject:shuttle];
    
    schedule.view.frame = self.scrollView.bounds;
    [self.scrollView addSubview:schedule.view];
    [self addChildViewController:schedule];

    [schedule viewWillAppear:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


#pragma mark -
-(void)setSelectIndex:(int)index
{
    specIndex = index;
}

-(void)segControlAction:(UISegmentedControl*)seg
{
    NSInteger index = seg.selectedSegmentIndex;
    specIndex = (int)index;
    
    
    if (index == 0) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else if (index == 1) {
        [self.scrollView setContentOffset:CGPointMake(deviceWidth, 0) animated:NO];
    }
}


- (IBAction)btnMenuClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    UIViewController *controller = self.arControllers[index];
    if (index == 1) {
        if (!controller.view.superview) {
            controller.view.frame = scrollView.bounds;
            [self.scrollView addSubview:controller.view];
            [self addChildViewController:controller];
        }
    }
    
    [controller viewWillAppear:YES];
}

@end
