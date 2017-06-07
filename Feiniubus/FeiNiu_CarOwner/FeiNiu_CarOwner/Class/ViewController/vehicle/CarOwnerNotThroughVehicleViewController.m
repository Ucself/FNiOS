//
//  CarOwnerNotThroughVehicleViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerNotThroughVehicleViewController.h"
#import "ProtocolCarOwner.h"
#import <FNDataModule/DataVersionCache.h>
#import <FNUIView/SelectView.h>
#import <FNUIView/DatePickerView.h>
#import <FNUIView/CustomPickerView.h>
#import <FNUIView/CustomAlertView.h>
#import <FNNetInterface/UIImageView+AFNetworking.h>
#import "CarOwnerCompanySearchViewController.h"

#define companyNameMark         @"companyName"
#define businessScopeMark       @"businessScope"
#define vehicleLicenseMark      @"vehicleLicense"
#define seatNumberMark          @"seatNumber"
#define vehicleLevelMark        @"vehicleLevel"
#define fuelTypeMark            @"fuelType"
#define registTimeMark          @"registTime"
#define operateCertificateMark  @"operateCertificate"
#define carPhotosMark           @"carPhotos"

@interface CarOwnerNotThroughVehicleViewController ()<UITableViewDelegate,UITableViewDataSource,CustomPickerViewDelegate,CustomAlertViewDelegate,CompanySearchViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    SelectType curSelType;    //当前选择类型
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

//*****临时不需要
@property (weak, nonatomic) IBOutlet UITableView *errorTableView;
@property (weak, nonatomic) IBOutlet UIView *errorTopView;
//*****

//时间选择器
@property (nonatomic, strong) DatePickerView *datePicker;
//上传选择器
@property (nonatomic, strong) SelectView *selectView;
//其他类别选择器
@property (nonatomic, strong) CustomPickerView *pickerView;
//选择上传的图片类型
@property (nonatomic, assign) int uploadTag;

@end

@implementation CarOwnerNotThroughVehicleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

/**
 *  添加车辆测试接口
 *
 *  @param sender 接口测试
 */
- (IBAction)addVehicleClick:(id)sender {
    
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    [tempDic setObject:[[NSNumber alloc] initWithLong:535423453] forKey:@"companyId"];
    [tempDic setObject:[[NSNumber alloc] initWithLong:535423453] forKey:@"businessScopeId"];
    [tempDic setObject:@"fasfs川A" forKey:@"licensePlate"];
    [tempDic setObject:[[NSNumber alloc] initWithInt:34] forKey:@"seatAmount"];
    [tempDic setObject:[[NSNumber alloc] initWithInt:535423453] forKey:@"length"];
    [tempDic setObject:[[NSNumber alloc] initWithInt:535423453] forKey:@"status"];
    [tempDic setObject:[[NSNumber alloc] initWithInt:535423453] forKey:@"driverId"];
    [tempDic setObject:[[NSNumber alloc] initWithLong:535423453] forKey:@"vehicleType"];
    [tempDic setObject:[DateUtils formatDate:[NSDate new] format:@"yyyy-MM-dd HH:mm:ss"] forKey:@"authTime"];
    
    //点击添加车辆
    [[ProtocolCarOwner sharedInstance] postInforWithNSDictionary:tempDic urlSuffix:Kurl_vehicle requestType:KRequestType_postvehicle];
}
//传参数
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CarOwnerBaseViewController* controller = segue.destinationViewController;
    if ([controller isKindOfClass:[CarOwnerCompanySearchViewController class]]) {
        controller.delegate = self;
    }
}
#pragma mark ---
/**
 *  初始化界面
 */
-(void) initInterface
{
    //设置数据源
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.errorTableView.delegate = self;
    self.errorTableView.dataSource = self;
    
    //设置上部高度 此处不需要，需要统一滚动
    [self.errorTableView makeConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(35.f*3+10.f);
        make.height.equalTo(0.f);
    }];
    
    if (!_errorInfo) {
        _errorInfo = [[NSMutableArray alloc] init];
        //初始化错误数据
        NSDictionary *dic0 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误1", companyNameMark,nil];
        [_errorInfo addObject:dic0];
        NSDictionary *dic1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误2", businessScopeMark,nil];
        [_errorInfo addObject:dic1];
        NSDictionary *dic2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误3", vehicleLicenseMark,nil];
        [_errorInfo addObject:dic2];
        NSDictionary *dic3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误4", seatNumberMark,nil];
        [_errorInfo addObject:dic3];
        NSDictionary *dic4 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误5", vehicleLevelMark,nil];
        [_errorInfo addObject:dic4];
        NSDictionary *dic5 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误6", fuelTypeMark,nil];
        [_errorInfo addObject:dic5];
        NSDictionary *dic6 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误7", registTimeMark,nil];
        [_errorInfo addObject:dic6];
        NSDictionary *dic7 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误8", operateCertificateMark,nil];
        [_errorInfo addObject:dic7];
        NSDictionary *dic8 = [[NSDictionary alloc] initWithObjectsAndKeys:@"错误9", carPhotosMark,nil];
        [_errorInfo addObject:dic8];
    }
    
    //展示屏蔽数据请求
    return;
    //检测缓存版本是否更新
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:[NSDictionary new] urlSuffix:KUrl_Cache requestType:KRequestType_GetCache];
    //获取本地的经营范围
    _businessScopeArray = [[DataVersionCache sharedInstance] getBusinessScope];
    //获取本地的车辆等级
    _vehicleLevelArray = [[DataVersionCache sharedInstance] getVehicleLevel];
    
    
}
/**
 *  显示选择方式
 *
 *  @param type 显示方式
 */
-(void)showSelectView:(SelectType)type
{
    curSelType = type;
    
    if (!self.selectView) {
        self.selectView = [[SelectView alloc] init];
        self.selectView.delegate = self;
    }
    
    self.selectView.type = type;
    
    [self.selectView showInView:self.view];
}

//点击上传图片弹出功能
-(void)imageUploadClick:(UITapGestureRecognizer *)recognizer
{
    //标示谁点击了上传
    _uploadTag = (int)recognizer.view.tag;
    //弹出选择类型
    if (!_selectView) {
        _selectView = [[SelectView alloc] initWithFrame:self.view.frame];
    }
    _selectView.delegate = self;
    _selectView.labelTitle.text = @"选择上传方式";
    [_selectView.btn1 setTitle:@"拍照" forState:UIControlStateNormal];
    [_selectView.btn2 setTitle:@"本地图片" forState:UIControlStateNormal];
    //设置背景颜色
    [_selectView.btn1 setBackgroundColor:UIColorFromRGB(0xFF5A37)];
    [_selectView.btn2 setBackgroundColor:UIColorFromRGB(0xFF5A37)];
    //设置字体颜色
    [_selectView.btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectView.btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    [_selectView showInView:[[UIApplication sharedApplication] keyWindow]];
    //    [_selectView showInView:self.view];
}

//错误的数据源
-(void) setChangError:(NSString*)errorKey
{
    //如果修改了错误，根据key值删除数据
    for (int i=0 ; i < _errorInfo.count; i++) {
        NSArray *allKeys = [_errorInfo[i] allKeys];
        //如果存在这个错误信息，删除这个对象
        if (allKeys && allKeys.count>0 && [allKeys[0] isEqual:errorKey] ) {
            [_errorInfo removeObject:_errorInfo[i]];
        }
    }
}

#pragma mark --DatePickerViewDelegate
- (void)pickerViewCancel
{
    [_datePicker cancelPicker:[[UIApplication sharedApplication] keyWindow]];
}
- (void)pickerViewOK:(NSString*)date
{
    _registTime = date;
    //上户时间更新
    [self setChangError:registTimeMark];
    [self.mainTableView reloadData];
    [_datePicker cancelPicker:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark ---SelectViewDelegate
- (void)selectViewCancel
{
    [_selectView cancelSelect:[[UIApplication sharedApplication] keyWindow]];
}
- (void)selectView:(int)index;
{
    //消除视图展示
    [_selectView cancelSelect:[[UIApplication sharedApplication] keyWindow]];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    switch (index) {
        case 0:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            break;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark --- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //返回的图片对象
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //拼装数据结构
    NSMutableDictionary *tempDic;
    
    if (!_operateCertificate) {
        _operateCertificate = [[NSMutableArray alloc] initWithCapacity:4];
        [_operateCertificate addObject:[NSMutableDictionary new]];
        [_operateCertificate addObject:[NSMutableDictionary new]];
        [_operateCertificate addObject:[NSMutableDictionary new]];
        [_operateCertificate addObject:[NSMutableDictionary new]];
    }
    if (!_carPhotos) {
        _carPhotos = [[NSMutableArray alloc] initWithCapacity:3];
        [_carPhotos addObject:[NSMutableDictionary new]];
        [_carPhotos addObject:[NSMutableDictionary new]];
        [_carPhotos addObject:[NSMutableDictionary new]];
    }
    
    switch (_uploadTag) {
        case 1111:
        {
            //运营证1
            if (_operateCertificate.count >=1 && [_operateCertificate objectAtIndex:0]) {
                tempDic = [_operateCertificate objectAtIndex:0];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_operateCertificate insertObject:tempDic atIndex:0];
            }
            [self setChangError:operateCertificateMark];
        }
            break;
        case 1112:
        {
            //运营证2
            if (_operateCertificate.count >=2 && [_operateCertificate objectAtIndex:1]) {
                tempDic = [_operateCertificate objectAtIndex:1];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_operateCertificate insertObject:tempDic atIndex:1];
            }
            [self setChangError:operateCertificateMark];
        }
            break;
        case 1113:
        {
            //运营证3
            if (_operateCertificate.count >=3 && [_operateCertificate objectAtIndex:2]) {
                tempDic = [_operateCertificate objectAtIndex:2];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_operateCertificate insertObject:tempDic atIndex:2];
            }
            [self setChangError:operateCertificateMark];
        }
            break;
        case 1114:
        {
            //运营证4
            if (_operateCertificate.count >=4 && [_operateCertificate objectAtIndex:3]) {
                tempDic = [_operateCertificate objectAtIndex:3];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_operateCertificate insertObject:tempDic atIndex:3];
            }
            [self setChangError:operateCertificateMark];
        }
            break;
        case 2111:
        {
            //车辆照片1
            if ( _carPhotos.count >= 1 && [_carPhotos objectAtIndex:0]) {
                tempDic = [_carPhotos objectAtIndex:0];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_carPhotos insertObject:tempDic atIndex:0];
            }
            [self setChangError:carPhotosMark];
        }
            break;
        case 2112:
        {
            //车辆照片2
            if ( _carPhotos.count >= 2 && [_carPhotos objectAtIndex:1]) {
                tempDic = [_carPhotos objectAtIndex:1];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_carPhotos insertObject:tempDic atIndex:1];
            }
            [self setChangError:carPhotosMark];
        }
            break;
        case 2113:
        {
            //车辆照片3
            if ( _carPhotos.count >= 3 && [_carPhotos objectAtIndex:2]) {
                tempDic = [_carPhotos objectAtIndex:2];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_carPhotos insertObject:tempDic atIndex:2];
            }
            [self setChangError:carPhotosMark];
        }
            break;
        default:
            break;
    }
    
    //重新刷数据展示
    [self.mainTableView reloadData];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- CompanySearchViewControllerDelegate
-(void)seachCompanySelected:(NSObject*)companyInfor
{
    if (!companyInfor || [companyInfor isEqual:@""]) {
        return;
    }
    //更改了公司名称
    [self setChangError:companyNameMark];
    _companyName = (NSString*)companyInfor;
    [self.mainTableView reloadData];
}
#pragma mark -- CustomAlertViewDelegate
- (void)customAlertViewCancel
{
    
}
- (void)customAlertViewOK:(NSString*)result  useType:(int)useType
{
    if (useType == 2) {
        self.vehicleLicense = result;
    }
    //燃油类别数据更改
    [self setChangError:vehicleLicenseMark];
    [self.mainTableView reloadData];
}
#pragma mark --- CustomPickerViewDelegate
//确定
- (void)pickerViewOK:(int)index useType:(int)useType
{
    switch (useType) {
        case 1:
        {
            //经营范围
            _businessScope = [_businessScopeArray objectAtIndex:index];
            [self setChangError:businessScopeMark];
        }
            break;
        case 3:
        {
            //座位数
            _seatNumber = [_seatNumberArray objectAtIndex:index];
            [self setChangError:seatNumberMark];
        }
            break;
        case 4:
        {
            //车辆等级
            _vehicleLevel = [_vehicleLevelArray objectAtIndex:index];
            [self setChangError:vehicleLevelMark];
        }
        case 5:
        {
            //燃油类别
            _fuelType = [_fuelTypeArray objectAtIndex:index];
            [self setChangError:fuelTypeMark];
        }
            break;
        default:
            break;
    }
    [self.mainTableView reloadData];
}

#pragma mark --- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //错误的数据
    if ([tableView isEqual:self.errorTableView]) {
        return 30.f;
    }
    
    switch (indexPath.section) {
        case 0:
            return 30.f;
            break;
        case 1:
            return 46.f;
            break;
        case 2:
            return 127.f;
            break;
        case 3:
            return 127.f;
            break;
        default:
            break;
    }
    return 1.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //错误的数据
    if ([tableView isEqual:self.errorTableView]) {
        return 0.f;
    }
    //错误信息头部为0
    if (section == 0 || section == 1) {
        return 0.f;
    }
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //错误的数据
    if ([tableView isEqual:self.errorTableView]) {
        return [UIView new];
    }
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //错误的数据
    if ([tableView isEqual:self.errorTableView]) {
        return;
    }
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    [self performSegueWithIdentifier:@"toSeachCompany" sender:self];
                }
                    break;
                case 1:
                {
                    if (!self.businessScopeArray) {
                        self.businessScopeArray = [[NSMutableArray alloc] init];
                    }
                    [self.businessScopeArray addObject:@"省际包车客运"];
                    [self.businessScopeArray addObject:@"市际包车客运"];
                    [self.businessScopeArray addObject:@"县际包车客运"];
                    [self.businessScopeArray addObject:@"省际包车客运"];
                    [self.businessScopeArray addObject:@"市际包车客运"];
                    [self.businessScopeArray addObject:@"县际包车客运"];
                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:self.businessScopeArray useType:(int)indexPath.row];
                    _pickerView.delegate = self;
                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 2:
                {
                    //填写车辆牌照
                    CustomAlertView *alertView = [[CustomAlertView alloc] initWithFrame:self.view.frame alertName:@"当日期望毛利" alertInputContent:(NSString*)_vehicleLicense alertUnit:@"" keyboardType:UIKeyboardTypeDefault useType:(int)indexPath.row];
                    alertView.delegate = self;
                    [alertView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 3:
                {
                    if (!_seatNumberArray) {
                        _seatNumberArray = [[NSMutableArray alloc] init];
                    }
                    [_seatNumberArray addObject:@"座位1"];
                    [_seatNumberArray addObject:@"座位2"];
                    [_seatNumberArray addObject:@"座位3"];
                    [_seatNumberArray addObject:@"座位4"];
                    [_seatNumberArray addObject:@"座位5"];
                    [_seatNumberArray addObject:@"座位6"];
                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:_seatNumberArray useType:(int)indexPath.row];
                    _pickerView.delegate = self;
                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 4:
                {
                    if (!_vehicleLevelArray) {
                        _vehicleLevelArray = [[NSMutableArray alloc] init];
                    }
                    [_vehicleLevelArray addObject:@"车辆等级1"];
                    [_vehicleLevelArray addObject:@"车辆等级2"];
                    [_vehicleLevelArray addObject:@"车辆等级3"];
                    [_vehicleLevelArray addObject:@"车辆等级4"];
                    [_vehicleLevelArray addObject:@"车辆等级5"];
                    [_vehicleLevelArray addObject:@"车辆等级6"];
                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:_vehicleLevelArray useType:(int)indexPath.row];
                    _pickerView.delegate = self;
                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 5:
                {
                    if (!_fuelTypeArray) {
                        _fuelTypeArray = [[NSMutableArray alloc] init];
                    }
                    [_fuelTypeArray addObject:@"燃油类别1"];
                    [_fuelTypeArray addObject:@"燃油类别2"];
                    [_fuelTypeArray addObject:@"燃油类别3"];
                    [_fuelTypeArray addObject:@"燃油类别4"];
                    [_fuelTypeArray addObject:@"燃油类别5"];
                    [_fuelTypeArray addObject:@"燃油类别6"];
                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:_fuelTypeArray useType:(int)indexPath.row];
                    _pickerView.delegate = self;
                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 6:
                {
                    if(!_datePicker)
                    {
                        _datePicker = [[DatePickerView alloc] initWithFrame:self.view.frame];
                    }
                    _datePicker.delegate = self;
                    [_datePicker showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                default:
                    break;
            }
            break;
        case 2:
        {
        
        }
            break;
        case 3:
        {
        
        }
            break;
        default:
            break;
    }
}
#pragma mark --- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //错误的数据
    if ([tableView isEqual:self.errorTableView]) {
        return 1;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //错误的数据
    if ([tableView isEqual:self.errorTableView]) {
        return 3;
    }
    
    switch (section) {
        case 0:
            return _errorInfo.count;
            break;
        case 1:
            return 7;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        default:
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell = nil;
    
    //错误的数据
    if ([tableView isEqual:self.errorTableView]) {
        tempCell = [tableView dequeueReusableCellWithIdentifier:@"errorInforCellIdent"];
        
        return tempCell;
    }
    
    switch (indexPath.section) {
        case 0:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"errorInforCellIdent"];
            UILabel *errorLabel = (UILabel*)[tempCell viewWithTag:101];
            NSDictionary *tempDic = (NSDictionary *)[_errorInfo objectAtIndex:indexPath.row];
            NSArray *keys = [tempDic allKeys];
            //展示错误数据
            if (keys.count > 0) {
                errorLabel.text = (NSString*)[tempDic objectForKey:keys[0]] ;
            }
            
        }
            break;
        case 1:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"basicInforCellIdent"];
            UILabel *titleLabel = (UILabel*)[tempCell viewWithTag:101];
            UILabel *detailTextLabel = (UILabel*)[tempCell viewWithTag:102];
            //设置颜色
            titleLabel.textColor = UIColorFromRGB(0x030303);
            detailTextLabel.textColor = UIColorFromRGB(0x333333);
            
            switch (indexPath.row) {
                case 0:
                {
                    titleLabel.text=@"公司名称";
                    //根据数据源判断显示内容
                    if (_companyName)
                    {
                        detailTextLabel.text = (NSString*)_companyName;
                    }
                    else
                    {
                        detailTextLabel.text=@"请选择公司名称";
                    }
                }
                    
                    break;
                case 1:
                {
                    titleLabel.text=@"经营范围";
                    //根据数据源判断显示内容
                    if (_businessScope)
                    {
                        detailTextLabel.text = (NSString*)_businessScope;
                    }
                    else
                    {
                        detailTextLabel.text=@"请选择经营范围";
                    }
                }
                    break;
                case 2:
                {
                    titleLabel.text=@"车辆牌照";
                    [tempCell setAccessoryType:UITableViewCellAccessoryNone];
                    [detailTextLabel makeConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(tempCell).offset(-15);
                    }];
                    //根据数据源判断显示内容
                    if (_vehicleLicense)
                    {
                        detailTextLabel.text = (NSString*)_vehicleLicense;
                        detailTextLabel.font = [UIFont systemFontOfSize:15.f];
                    }
                    else
                    {
                        detailTextLabel.text=@"请填写车牌牌照";
                        detailTextLabel.font = [UIFont systemFontOfSize:15.f];
                    }
                }
                    break;
                case 3:
                {
                    titleLabel.text=@"座位数";
                    //根据数据源判断显示内容
                    if (_seatNumber)
                    {
                        detailTextLabel.text = (NSString*)_seatNumber;
                    }
                    else
                    {
                        detailTextLabel.text=@"请选择座位数";
                    }
                }
                    break;
                case 4:
                {
                    titleLabel.text=@"车辆等级";
                    //根据数据源判断显示内容
                    if (_vehicleLevel)
                    {
                        detailTextLabel.text = (NSString*)_vehicleLevel;
                    }
                    else
                    {
                        detailTextLabel.text=@"请选择车辆等级";
                    }
                }
                    break;
                case 5:
                {
                    titleLabel.text=@"燃油类别";
                    //根据数据源判断显示内容
                    if (_fuelType)
                    {
                        detailTextLabel.text = (NSString*)_fuelType;
                    }
                    else
                    {
                        detailTextLabel.text=@"请选择燃油类别";
                    }
                }
                    break;
                case 6:
                {
                    titleLabel.text=@"上户时间";
                    //根据数据源判断显示内容
                    if (_registTime)
                    {
                        detailTextLabel.text = (NSString*)_registTime;
                    }
                    else
                    {
                        detailTextLabel.text=@"请选择上户时间";
                    }
                }
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 2:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"operatingCellIdent"];
            //获取cell的控件对象
            UIImageView *firstImage = (UIImageView*)[tempCell viewWithTag:1111];
            UILabel *firstLabel = (UILabel*)[tempCell viewWithTag:1121];
            UIImageView *secondImage = (UIImageView*)[tempCell viewWithTag:1112];
            UILabel *secondLabel = (UILabel*)[tempCell viewWithTag:1122];
            UIImageView *thridImage = (UIImageView*)[tempCell viewWithTag:1113];
            UILabel *thridLabel = (UILabel*)[tempCell viewWithTag:1123];
            UIImageView *fourthImage = (UIImageView*)[tempCell viewWithTag:1114];
            UILabel *fourthLabel = (UILabel*)[tempCell viewWithTag:1124];
            //设置图片的点击
            UITapGestureRecognizer *firstImageYunyingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageUploadClick:)];
            [firstImage addGestureRecognizer:firstImageYunyingGesture];
            [firstImage setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *secondImageYunyingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageUploadClick:)];
            [secondImage addGestureRecognizer:secondImageYunyingGesture];
            [secondImage setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *thridImageYunyingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageUploadClick:)];
            [thridImage addGestureRecognizer:thridImageYunyingGesture];
            [thridImage setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *fourthImageYunyingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageUploadClick:)];
            [fourthImage addGestureRecognizer:fourthImageYunyingGesture];
            [fourthImage setUserInteractionEnabled:YES];
            
            //state:0,1,2(0没有数据，1有图片，2用户重新上传图片) url:(服务器上的图片地址) newImage:(用户重新上传图片)
            //对第一张图片进行设置
            if (_operateCertificate.count >=1 &&[_operateCertificate objectAtIndex:0])
            {
                NSDictionary *tempDic = (NSDictionary*)[_operateCertificate objectAtIndex:0];
                //传入的时候必须包含这三个key
                if ([[tempDic objectForKey:@"state"] isEqualToString:@"0"])
                {
                    //没有数据
                    [firstImage setImage:[UIImage imageNamed:@"certificateDefaultIcon"]];
                    firstLabel.backgroundColor = UIColorFromRGB(0x666666);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"1"] && [tempDic objectForKey:@"url"])
                {
                    //有图片服务器上的图片
                    [firstImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,[tempDic objectForKey:@"url"]]]];
                    
                    firstLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"2"] && [tempDic objectForKey:@"newImage"])
                {
                    //有图片重新上传的图片
                    [firstImage setImage:(UIImage*)[tempDic objectForKey:@"newImage"]];
                    firstLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
            }
            //对第二张图片进行设置
            if (_operateCertificate.count >=2 && [_operateCertificate objectAtIndex:1])
            {
                NSDictionary *tempDic = (NSDictionary*)[_operateCertificate objectAtIndex:1];
                //传入的时候必须包含这三个key
                if ([[tempDic objectForKey:@"state"] isEqualToString:@"0"])
                {
                    //没有数据
                    [secondImage setImage:[UIImage imageNamed:@"certificateDefaultIcon"]];
                    secondLabel.backgroundColor = UIColorFromRGB(0x666666);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"1"] && [tempDic objectForKey:@"url"])
                {
                    //有图片服务器上的图片
                    [secondImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,[tempDic objectForKey:@"url"]]]];
                    
                    secondLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"2"]  && [tempDic objectForKey:@"newImage"])
                {
                    //有图片重新上传的图片
                    [secondImage setImage:(UIImage*)[tempDic objectForKey:@"newImage"]];
                    secondLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
            }
            //对第三张图片进行设置
            if (_operateCertificate.count >=3 && [_operateCertificate objectAtIndex:2])
            {
                NSDictionary *tempDic = (NSDictionary*)[_operateCertificate objectAtIndex:2];
                //传入的时候必须包含这三个key
                if ([[tempDic objectForKey:@"state"] isEqualToString:@"0"])
                {
                    //没有数据
                    [thridImage setImage:[UIImage imageNamed:@"certificateDefaultIcon"]];
                    thridLabel.backgroundColor = UIColorFromRGB(0x666666);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"1"] && [tempDic objectForKey:@"url"])
                {
                    //有图片服务器上的图片
                    [thridImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,[tempDic objectForKey:@"url"]]]];
                    
                    thridLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"2"]  && [tempDic objectForKey:@"newImage"])
                {
                    //有图片重新上传的图片
                    [thridImage setImage:(UIImage*)[tempDic objectForKey:@"newImage"]];
                    thridLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
            }
            //对第四张图片进行设置
            if (_operateCertificate.count >=4 && [_operateCertificate objectAtIndex:3])
            {
                NSDictionary *tempDic = (NSDictionary*)[_operateCertificate objectAtIndex:3];
                //传入的时候必须包含这三个key
                if ([[tempDic objectForKey:@"state"] isEqualToString:@"0"])
                {
                    //没有数据
                    [fourthImage setImage:[UIImage imageNamed:@"certificateDefaultIcon"]];
                    fourthLabel.backgroundColor = UIColorFromRGB(0x666666);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"1"] && [tempDic objectForKey:@"url"])
                {
                    //有图片服务器上的图片
                    [fourthImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,[tempDic objectForKey:@"url"]]]];
                    
                    fourthLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"2"]  && [tempDic objectForKey:@"newImage"])
                {
                    //有图片重新上传的图片
                    [fourthImage setImage:(UIImage*)[tempDic objectForKey:@"newImage"]];
                    fourthLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
            }
        }
            break;
        case 3:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"vehicleCellIdent"];
            //数据
            UIImageView *firstImage = (UIImageView*)[tempCell viewWithTag:2111];
            UILabel *firstLabel = (UILabel*)[tempCell viewWithTag:2121];
            UIImageView *secondImage = (UIImageView*)[tempCell viewWithTag:2112];
            UILabel *secondLabel = (UILabel*)[tempCell viewWithTag:2122];
            UIImageView *thridImage = (UIImageView*)[tempCell viewWithTag:2113];
            UILabel *thridLabel = (UILabel*)[tempCell viewWithTag:2123];
            
            //设置图片的点击
            UITapGestureRecognizer *firstImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageUploadClick:)];
            [firstImage addGestureRecognizer:firstImageGesture];
            [firstImage setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *secondImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageUploadClick:)];
            [secondImage addGestureRecognizer:secondImageGesture];
            [secondImage setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *thridImageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageUploadClick:)];
            [thridImage addGestureRecognizer:thridImageGesture];
            [thridImage setUserInteractionEnabled:YES];
            
            //state:0,1,2(0没有数据，1有图片，2用户重新上传图片) url:(服务器上的图片地址) newImage:(用户重新上传图片)
            //对第一张图片进行设置
            if (_carPhotos.count>=1 && [_carPhotos objectAtIndex:0])
            {
                NSDictionary *tempDic = (NSDictionary*)[_carPhotos objectAtIndex:0];
                //传入的时候必须包含这三个key
                if ([[tempDic objectForKey:@"state"] isEqualToString:@"0"])
                {
                    //没有数据
                    [firstImage setImage:[UIImage imageNamed:@"certificateDefaultIcon"]];
                    firstLabel.backgroundColor = UIColorFromRGB(0x666666);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"1"] && [tempDic objectForKey:@"url"])
                {
                    //有图片服务器上的图片
                    [firstImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,[tempDic objectForKey:@"url"]]]];
                    
                    firstLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"2"]  && [tempDic objectForKey:@"newImage"])
                {
                    //有图片重新上传的图片
                    [firstImage setImage:(UIImage*)[tempDic objectForKey:@"newImage"]];
                    firstLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
            }
            //对第二张图片进行设置
            if (_carPhotos.count>=2 && [_carPhotos objectAtIndex:1])
            {
                NSDictionary *tempDic = (NSDictionary*)[_carPhotos objectAtIndex:1];
                //传入的时候必须包含这三个key
                if ([[tempDic objectForKey:@"state"] isEqualToString:@"0"])
                {
                    //没有数据
                    [secondImage setImage:[UIImage imageNamed:@"certificateDefaultIcon"]];
                    secondLabel.backgroundColor = UIColorFromRGB(0x666666);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"1"] && [tempDic objectForKey:@"url"])
                {
                    //有图片服务器上的图片
                    [secondImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,[tempDic objectForKey:@"url"]]]];
                    
                    secondLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"2"]  && [tempDic objectForKey:@"newImage"])
                {
                    //有图片重新上传的图片
                    [secondImage setImage:(UIImage*)[tempDic objectForKey:@"newImage"]];
                    secondLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
            }
            //对第三张图片进行设置
            if (_carPhotos.count>=3 && [_carPhotos objectAtIndex:2])
            {
                NSDictionary *tempDic = (NSDictionary*)[_carPhotos objectAtIndex:2];
                //传入的时候必须包含这三个key
                if ([[tempDic objectForKey:@"state"] isEqualToString:@"0"])
                {
                    //没有数据
                    [thridImage setImage:[UIImage imageNamed:@"certificateDefaultIcon"]];
                    thridLabel.backgroundColor = UIColorFromRGB(0x666666);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"1"] && [tempDic objectForKey:@"url"])
                {
                    //有图片服务器上的图片
                    [thridImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,[tempDic objectForKey:@"url"]]]];
                    
                    thridLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
                else if ([[tempDic objectForKey:@"state"] isEqualToString:@"2"]  && [tempDic objectForKey:@"newImage"])
                {
                    //有图片重新上传的图片
                    [thridImage setImage:(UIImage*)[tempDic objectForKey:@"newImage"]];
                    thridLabel.backgroundColor = UIColorFromRGB(0xFF5A37);
                }
            }
        }
            break;
        default:
            break;
    }
    
    return tempCell;
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
//    NSDictionary *result = notification.object;
//    //返回的数据对象
//    FUCarOwnerResultParse *resultParse = [[FUCarOwnerResultParse alloc] initWithDictionary:result];
    
    ResultDataModel *resultParse = (ResultDataModel*)notification.object;
    
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
