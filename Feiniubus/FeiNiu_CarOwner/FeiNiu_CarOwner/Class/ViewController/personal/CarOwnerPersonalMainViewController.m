//
//  CarOwnerPersonalMainViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerPersonalMainViewController.h"
#import "CustomCollectionViewLayout.h"
#import "ProtocolCarOwner.h"
#import "CarOwnerInforModel.h"

@interface CarOwnerPersonalMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@property (nonatomic,strong) CarOwnerInforModel *dataModel;
//注销按钮
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButtonItem;


@end

@implementation CarOwnerPersonalMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
    [self setNavigationBarSelf];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //获取统计数据
    [self startWait];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:[NSDictionary new] urlSuffix:Kurl_ownersStatistics requestType:KRequestType_ownersStatistics];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark ---
/**
 *  初始化界面数据
 */
-(void) initInterface
{
    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    //设置注销车辆按钮字体大小
    [_logoutButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    [_mainCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    
    //隐藏返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
}

//设置导航栏目
-(void)setNavigationBarSelf
{
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xFFFFFF)];
    [self.navigationController.navigationBar setTintColor:UIColorFromRGB(0x333333)];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x333333)}];
    //iOS7 增加滑动手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
//注销按钮点击
- (IBAction)logoutButtonClick:(id)sender {
    //弹出登录窗口
    //鉴权失效重置token
    [[EnvPreferences sharedInstance] setToken:nil];
    [[EnvPreferences sharedInstance] setUserId:nil];
    
    //故事版
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //登录相关控制器
    UINavigationController *loginNav = [storyboard instantiateViewControllerWithIdentifier:@"loginNavControllerId"];
    //先进入登录进行测试
    [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    //重置别名
    //重新设置标签和别名
    [[PushConfiguration sharedInstance] resetTagAndAlias];
//    //注册通知别名
//    [[PushConfiguration sharedInstance] resetAlias];
//    [[PushConfiguration sharedInstance] resetTag];
}


#pragma mark --- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 4;
            break;
        default:
            break;
    }
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *tempCell ;
    
    switch (indexPath.section)
    {
        case 0:
        {
            tempCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"topViewIdent" forIndexPath:indexPath];
            UILabel *allCountLabel = (UILabel*)[tempCell viewWithTag:101];
            allCountLabel.text = @"0";
            if (_dataModel) {
                allCountLabel.text = [[NSString alloc] initWithFormat:@"%.0f",_dataModel.totalAmount/100.f];
            }
            //元
//            UILabel *yuanLabel = (UILabel*)[tempCell viewWithTag:102];
            //收入长度
//            int amountLength = allCountLabel.text.length;
//            [yuanLabel remakeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(tempCell.centerX).offset(amountLength * 22);
//            }];
        }
            break;
        default:
        {
            tempCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"middleViewIdent" forIndexPath:indexPath];
            UIImageView *headImageView = (UIImageView*)[tempCell viewWithTag:101];
            UILabel *nameLabel = (UILabel*)[tempCell viewWithTag:102];
            UILabel *numberLabel = (UILabel*)[tempCell viewWithTag:103];
            switch (indexPath.row) {
                case 0:
                {
                    [headImageView setImage:[UIImage imageNamed:@"centerCar"]];
                    nameLabel.text = @"注册车辆数";
                    numberLabel.text = @"0台";
                    if (_dataModel) {
                        numberLabel.text = [[NSString alloc] initWithFormat:@"%@台",_dataModel.vehicleAmount];
                    }
                }
                    break;
                case 1:
                {
                    [headImageView setImage:[UIImage imageNamed:@"centerDriver"]];
                    nameLabel.text = @"注册驾驶员数";
                    numberLabel.text = @"0人";
                    if (_dataModel) {
                        numberLabel.text = [[NSString alloc] initWithFormat:@"%@人",_dataModel.driverAmount];
                    }
                }
                    break;
                case 2:
                {
                    [headImageView setImage:[UIImage imageNamed:@"centerOder"]];
                    nameLabel.text = @"总接单数";
                    numberLabel.text = @"0单";
                    if (_dataModel) {
                        numberLabel.text = [[NSString alloc] initWithFormat:@"%@单",_dataModel.orderAmount];
                    }
                }
                    break;
                case 3:
                {
                    [headImageView setImage:[UIImage imageNamed:@"centerMileage"]];
                    nameLabel.text = @"总里程数";
                    numberLabel.text = @"0km";
                    if (_dataModel) {
                        numberLabel.text = [[NSString alloc] initWithFormat:@"%@km",_dataModel.mileage];
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
    }
    
    return tempCell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    //返回布局
//    UICollectionReusableView *tempReusable;
//    return tempReusable;
//}

#pragma mark --- UICollectionViewDelegateFlowLayout 
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return CGSizeMake(deviceWidth, 170);
            break;
        default:
            break;
    }
    return CGSizeMake(deviceWidth/2, 100);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 0)
    {
        return UIEdgeInsetsMake(0, 0, 11, 0);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    ResultDataModel *resultParse = (ResultDataModel*)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_ownersStatistics:
        {
            if (resultParse.resultCode == 0) {
                _dataModel = [[CarOwnerInforModel alloc] initWithDictionary:resultParse.data];
                //重新加载数据
                [_mainCollectionView reloadData];
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
            
        default:
            break;
    }
}
/**
 *  请求返回失败
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}
@end












