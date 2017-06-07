//
//  CarOwnerAddVehicleViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerAddVehicleViewController.h"
#import "ProtocolCarOwner.h"
#import <FNDataModule/DataVersionCache.h>
#import <FNUIView/SelectView.h>
#import <FNUIView/DatePickerView.h>
#import <FNUIView/CustomPickerView.h>
#import <FNUIView/CustomAlertView.h>
#import <FNNetInterface/UIImageView+AFNetworking.h>
#import "CarOwnerCompanySearchViewController.h"
#import "CarOwnerDriverSearchViewController.h"
#import <FNCommon/BCBaseObject.h>
#import <FNCommon/DateUtils.h>

typedef NS_ENUM(int, FuelType)
{
    FuelTypeGasoline = 1, //汽油
    FuelTypeDiesel,       //柴油
    FuelTypeCNG,          //天然气
    FuelTypeOther,        //其他
};

typedef NS_ENUM(int, UploadType)
{
    UploadTypeOperate = 1,  //运营证
    UploadTypeVehicle,             //车辆照片
};


@interface CarOwnerAddVehicleViewController ()<UITableViewDelegate,UITableViewDataSource,CustomPickerViewDelegate,CustomAlertViewDelegate,CompanySearchViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CarOwnerDriverSearchViewControllerDelegate, NetInterfaceDelegate>
{
    SelectType curSelType;    //当前选择类型
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

//时间选择器
@property (nonatomic, strong) DatePickerView *datePicker;
//上传选择器
@property (nonatomic, strong) SelectView *selectView;
//其他类别选择器
@property (nonatomic, strong) CustomPickerView *pickerView;
//选择上传的图片类型
@property (nonatomic, assign) int uploadTag;
//当前请求的数据类型
@property (nonatomic, assign) int requestType;

//提交按钮
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIImageView *submitImageView;

//错误提示对象
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UITextView *errorText;



@end

@implementation CarOwnerAddVehicleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(_vehicleModel) {
//        _dataModel = [_vehicleModel clone];
        _dataModel = _vehicleModel;
    }   else {
        _dataModel = [[CarOwnerVehicleModel alloc] init];
    }
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //加载数据
    [self willApperLoadData];
}

-(BOOL)isEmptyString: (NSString *)str {
    if((!str) || [str isEqualToString: @""]) {
        return YES;
    }
    return NO;
}

-(BOOL)isNotEmptyString: (NSString *)str {
    if((!str) || [str isEqualToString: @""]) {
        return NO;
    }
    return YES;
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
    //公司名称验证
    if ([self isEmptyString: _dataModel.companyName]) {
        [self showTipsView:@"请选择公司名称"];
        return;
    }
    //经营范围验证
    if ([self isEmptyString: _dataModel.businessScopeName]) {
        [self showTipsView:@"请选择经营范围"];
        return;
    }
    //车牌照验证
    if (![BCBaseObject isLicensePlate:_dataModel.licensePlate]) {
        [self showTipsView:@"请填写正确的车辆牌照"];
        return;
    }
    //座位数验证
    if (_dataModel.seats == 0) {
        [self showTipsView:@"请选择座位数"];
        return;
    }
    //等级类型验证 || !_vehicleType
    if ([self isEmptyString: _dataModel.levelName]) {
        [self showTipsView:@"请选择等级类型"];
        return;
    }
    //燃油类别验证
    if ([self isEmptyString: _dataModel.fuelTypeName]) {
        [self showTipsView:@"请选择燃油类别"];
        return;
    }
    //上户时间验证
    if ([self isEmptyString: _dataModel.registerTime]) {
        [self showTipsView:@"请选择上户时间"];
        return;
    }
    //车辆长度验证
    if (_dataModel.length == 0) {
        [self showTipsView:@"请填写车辆长度"];
        return;
    }
    
    //运营证1验证
    if (_operateCertificate.count < 1 || ![_operateCertificate[0] objectForKey:@"state"] || [[(NSDictionary*)_operateCertificate[0] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传照片1图片"];
        return;
    }
    //运营证2验证
    if (_operateCertificate.count < 2 || ![_operateCertificate[1] objectForKey:@"state"] || [[(NSDictionary*)_operateCertificate[1] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传照片2图片"];
        return;
    }
    //运营证3验证
    if (_operateCertificate.count < 3 || ![_operateCertificate[2] objectForKey:@"state"] || [[(NSDictionary*)_operateCertificate[2] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传照片3图片"];
        return;
    }
    //运营证4验证
    if (_operateCertificate.count < 4 || ![_operateCertificate[3] objectForKey:@"state"] || [[(NSDictionary*)_operateCertificate[3] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传照片4图片"];
        return;
    }
    
    //车辆正面验证
    if (_carPhotos.count < 1 || ![_carPhotos[0] objectForKey:@"state"] || [[(NSDictionary*)_carPhotos[0] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传车辆正面图片"];
        return;
    }
    //运营证2验证
    if (_carPhotos.count < 2 || ![_carPhotos[1] objectForKey:@"state"] || [[(NSDictionary*)_carPhotos[1] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传车辆侧面图片"];
        return;
    }
    //运营证3验证
    if (_carPhotos.count < 3 || ![_carPhotos[2] objectForKey:@"state"] || [[(NSDictionary*)_carPhotos[2] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传车辆背面图片"];
        return;
    }
    
    //上传更改的图片开始
    [self startWait];
    [self uploadVehiclePhotos:UploadTypeOperate index:0];
    
}
//上传车辆相关图片
-(void)uploadVehiclePhotos:(UploadType)type index:(int)index
{
    switch (type) {
        case UploadTypeOperate:
        {
            if ([_operateCertificate[index] objectForKey:@"state"] && [[(NSDictionary*)_operateCertificate[index] objectForKey:@"state"] isEqualToString:@"2"])
            {
                //证件照片
                NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
                [bodyDic setObject:[[NSString alloc] initWithFormat:@"%d",ImageTypeCertificate] forKey:@"Type"];
                //提示等待符号
                [[ProtocolCarOwner sharedInstance] uploadImage:(UIImage*)[_operateCertificate[index] objectForKey:@"newImage"]  body:bodyDic suceeseBlock:^(NSString *msg) {
                    //上传成功处理数据
                    [self imageUploadSucees:msg type:UploadTypeOperate index:index];
                    //传下一张图片，如果已经是第四张，则上传车辆照片
                    if (index < 3)
                    {
                        [self uploadVehiclePhotos:type index:index+1];
                    }
                    else if (index == 3)
                    {
                        [self uploadVehiclePhotos:UploadTypeVehicle index:0];
                    }
                    
                } failedBlock:^(NSError *error) {
                    //提示等待符号
                    [self stopWait];
                    [self showTipsView:@"图片上传失败"];
                }];
            }
            else
            {
                //不符合条件的直接上传下一张
                if (index < 3)
                {
                    [self uploadVehiclePhotos:type index:index+1];
                }
                else if (index == 3)
                {
                    [self uploadVehiclePhotos:UploadTypeVehicle index:0];
                }
            }
        }
            break;
        case UploadTypeVehicle:
        {
            if ([_carPhotos[index] objectForKey:@"state"] && [[(NSDictionary*)_carPhotos[index] objectForKey:@"state"] isEqualToString:@"2"])
            {
                //车辆照片
                NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
                [bodyDic setObject:[[NSString alloc] initWithFormat:@"%d",ImageTypeCommon] forKey:@"Type"];
                //提示等待符号
                [[ProtocolCarOwner sharedInstance] uploadImage:(UIImage*)[_carPhotos[index] objectForKey:@"newImage"]  body:bodyDic suceeseBlock:^(NSString *msg) {
                    //上传成功处理数据
                    [self imageUploadSucees:msg type:UploadTypeVehicle index:index];
                    //传下一张图片，如果已经是第四张，则上传车辆照片
                    if (index < 2)
                    {
                        [self uploadVehiclePhotos:type index:index+1];
                    }
                    else if (index == 2)
                    {
                        [self updateVehicleInfor];
                    }
                    
                } failedBlock:^(NSError *error) {
                    //提示等待符号
                    [self stopWait];
                    [self showTipsView:@"图片上传失败"];
                }];
            }
            else
            {
                //不符合条件的直接上传下一张
                if (index < 2)
                {
                    [self uploadVehiclePhotos:type index:index+1];
                }
                else if (index == 2)
                {
                    [self updateVehicleInfor];
                }
            }
        }
            break;
        default:
            break;
    }
}

//图片上传成功,更新数据源
-(BOOL)imageUploadSucees:(NSString*)msg type:(UploadType)type index:(int)index
{
    //返回的数据信息
    NSDictionary *dict = [JsonBaseBuilder dictionaryWithJson:msg decode:NO key:nil];
    //上传头像返回成功
    if ([[dict objectForKey:@"code"] intValue] == 0)
    {
        //如果是上传的证件图片
        if (type == UploadTypeOperate && [dict objectForKey:@"url"])
        {
            [(NSMutableDictionary*)_operateCertificate[index] setObject:[dict objectForKey:@"url"] forKey:@"url"];
            [(NSMutableDictionary*)_operateCertificate[index] setObject:@"1" forKey:@"state"];
        }
        //如果是上传的车辆照片
        if (type == UploadTypeVehicle && [dict objectForKey:@"url"])
        {
            [(NSMutableDictionary*)_carPhotos[index] setObject:[dict objectForKey:@"url"] forKey:@"url"];
            [(NSMutableDictionary*)_carPhotos[index] setObject:@"1" forKey:@"state"];
        }
    }
    else if ([[dict objectForKey:@"code"] intValue] == 100002 || [[dict objectForKey:@"code"] intValue] == 100001)
    {
        //鉴权失败跳转登录页面
        //故事版
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //登录相关控制器
        UINavigationController *loginNav = [storyboard instantiateViewControllerWithIdentifier:@"loginNavControllerId"];
        //先进入登录进行测试
        [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    }
    else
    {
        [self showTipsView:@"图片上传失败"];
        return NO;
    }
    return YES;
}

//更新车辆信息
-(void)updateVehicleInfor
{
    //标示是否可以上传
    BOOL canUpdate = YES;
    //判断头像是否已经上传
    for (NSMutableDictionary *tempOperatePhotos in _operateCertificate) {
        if (!([tempOperatePhotos objectForKey:@"state"] && [[tempOperatePhotos objectForKey:@"state"] isEqualToString:@"1"]))
        {
            canUpdate = NO;
        }
    }
    //判断车辆照片是否上传
    for (NSMutableDictionary *tempCardPhotos in _carPhotos) {
        if (!([tempCardPhotos objectForKey:@"state"] && [[tempCardPhotos objectForKey:@"state"] isEqualToString:@"1"]))
        {
            canUpdate = NO;
        }
    }
    //如果都上传完成即可更新驾驶员信息
    if (canUpdate) {
        //图片信息数据结构
        NSMutableDictionary *parentNode = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *operatePhotosNode = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *carPhotosNode = [[NSMutableDictionary alloc] init];
        
        [operatePhotosNode setObject:[(NSMutableDictionary*)_operateCertificate[0] objectForKey:@"url"] forKey:@"firstUrl"];
        [operatePhotosNode setObject:[(NSMutableDictionary*)_operateCertificate[1] objectForKey:@"url"] forKey:@"secondUrl"];
        [operatePhotosNode setObject:[(NSMutableDictionary*)_operateCertificate[2] objectForKey:@"url"] forKey:@"thirdUrl"];
        [operatePhotosNode setObject:[(NSMutableDictionary*)_operateCertificate[3] objectForKey:@"url"] forKey:@"fourthUrl"];
        
        [carPhotosNode setObject:[(NSMutableDictionary*)_carPhotos[0] objectForKey:@"url"] forKey:@"frontUrl"];
        [carPhotosNode setObject:[(NSMutableDictionary*)_carPhotos[1] objectForKey:@"url"] forKey:@"sideUrl"];
        [carPhotosNode setObject:[(NSMutableDictionary*)_carPhotos[2] objectForKey:@"url"] forKey:@"backUrl"];
        
        [parentNode setObject:operatePhotosNode forKey:@"operatePhoto"];
        [parentNode setObject:carPhotosNode forKey:@"vehiclePhoto"];
        //组装请求的数据结构
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithCapacity:1];
        if(_vehicleModel.vehicleId) {
            [tempDic setObject:_vehicleModel.vehicleId forKey:@"Id"];
        }
        [tempDic setObject: _dataModel.companyId forKey:@"companyId"];
        [tempDic setObject: [[NSString alloc] initWithFormat: @"%d", _dataModel.businessScopeId] forKey:@"businessScopeId"];
        [tempDic setObject: _dataModel.licensePlate forKey:@"licensePlate"];
        [tempDic setObject: [[NSString alloc] initWithFormat: @"%d", _dataModel.seats] forKey:@"seatAmount"];
        [tempDic setObject: [[NSString alloc] initWithFormat: @"%d", _dataModel.levelId] forKey:@"vehicleLevel"];
        [tempDic setObject: [[NSString alloc] initWithFormat: @"%d", _dataModel.typeId] forKey:@"vehicleType"];
        [tempDic setObject: [[NSString alloc] initWithFormat: @"%d", _dataModel.length] forKey:@"length"];
        [tempDic setObject: @"0" forKey:@"driverId"];
        [tempDic setObject: _dataModel.registerTime forKey:@"authTime"];
        [tempDic setObject: [[NSString alloc] initWithFormat: @"%d", _dataModel.fuelTypeId] forKey:@"fuelType"];
        [tempDic setObject: parentNode forKey:@"extension"];
        
        DBG_MSG(@"type: %d", _vehicleModel.audit);
        //点击添加车辆
        if(_vehicleModel.audit != 0) {
            [[ProtocolCarOwner sharedInstance] putInforWithNSDictionary:tempDic urlSuffix:Kurl_vehicle requestType:KRequestType_postvehicle];
        }   else {
            [[ProtocolCarOwner sharedInstance] postInforWithNSDictionary:tempDic urlSuffix:Kurl_vehicle requestType:KRequestType_postvehicle];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CarOwnerBaseViewController *controller = segue.destinationViewController;
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
    //获取所有需要的数据
    [self startWait];
    NSThread *thread = [[NSThread alloc] initWithTarget: self selector:@selector(reqeustInitData) object: nil];
    [thread start];
    //初始化车辆类型等级
    if([self isNotEmptyString: _dataModel.levelName]) {
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject: [[NSString alloc] initWithFormat:@"%@%@",_dataModel.levelName, _dataModel.typeName] forKey:@"name"];
        [tempDic setObject: [[NSString alloc] initWithFormat:@"%d", _dataModel.levelId] forKey:@"levelId"];
        [tempDic setObject: _dataModel.levelName forKey:@"levelName"];
        [tempDic setObject: [[NSString alloc] initWithFormat:@"%d", _dataModel.typeId] forKey:@"typeId"];
        [tempDic setObject: _dataModel.typeName forKey:@"typeName"];
        _levelType = tempDic;
    }
    //请求成功后下面获取数据
    if (!_seatNumberArray) {
        _seatNumberArray = [[NSMutableArray alloc] initWithObjects:@"19",@"29",@"39",@"49", nil];
    }
}

-(void)initializeLevelAndType {
    int k;
    if([self isNotEmptyString: _dataModel.levelName]) {
        for(k = 0;k < _vehicleLevelArray.count;k ++) {
            NSDictionary *dict = _vehicleLevelArray[k];
            if([_dataModel.levelName isEqualToString: [dict valueForKey: @"name"]]) {
                _dataModel.levelId = [[dict valueForKey: @"id"] intValue];
            }
        }
    }
    if([self isNotEmptyString: _dataModel.typeName]) {
        for(k = 0;k < _vehicleTypeArray.count;k ++) {
            NSDictionary *dict = _vehicleTypeArray[k];
            if([_dataModel.typeName isEqualToString: [dict valueForKey: @"name"]]) {
                _dataModel.typeId = [[dict valueForKey: @"id"] intValue];
            }
        }
    }
}

// 画面显示前，加载编辑数据、显示列表时，需要用到的数据
-(void) reqeustInitData {
    BOOL requestResult = NO;
    
    _requestType = KRequestType_GetBusinessScope;
    requestResult = [[ProtocolCarOwner sharedInstance] getInforWithNSDictionarySynchronized:[NSDictionary new] urlSuffix:KUrl_BusinessScope delegate:self];
    if(!requestResult) {
        [self stopWait];
        return;
    }
    
    _requestType = KRequestType_GetVehicleType;
    requestResult = [[ProtocolCarOwner sharedInstance] getInforWithNSDictionarySynchronized:[NSDictionary new] urlSuffix:KUrl_VehicleType delegate:self];
    if(!requestResult) {
        [self stopWait];
        return;
    }
    
    _requestType = KRequestType_GetVehicleLevel;
    requestResult = [[ProtocolCarOwner sharedInstance] getInforWithNSDictionarySynchronized:[NSDictionary new] urlSuffix:KUrl_VehicleLevel delegate:self];
    if(!requestResult) {
        [self stopWait];
        return;
    }
    
    _requestType = KRequestType_GetFuelType;
    requestResult = [[ProtocolCarOwner sharedInstance] getInforWithNSDictionarySynchronized:[NSDictionary new] urlSuffix:KUrl_FuelType delegate:self];
    if(!requestResult) {
        [self stopWait];
        return;
    }
    
    [self initializeLevelAndType];
    
    [self stopWait];
    
#ifdef DEBUG  // 调试阶段
//    [self performSelectorOnMainThread: @selector(showTipsView:) withObject: @"数据获取完成!!" waitUntilDone:YES];
#endif
}

//加载数据
-(void) willApperLoadData
{
    //iOS 7
    //按钮重新进行布局
    [_submitButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    //dataTable
    [_mainTableView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_submitButton.top);
    }];
    //初始化编辑古来的数据
    [self initializeData];
}
//初始化编辑的数据
-(void)initializeData
{
    if (self.editorType == EditorTypeAdd || !_vehicleModel) {
        //如果是添加，不需要初始化任何数据
        self.navigationItem.title = @"添加车辆";
        return;
    }
    else if (self.editorType == EditorTypeEditor)
    {
        self.navigationItem.title = @"编辑车辆";
    }
    else if (self.editorType == EditorTypeError)
    {
        self.navigationItem.title = @"审核失败车辆";
        //需要展示错误提示
        [_errorView remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(70);
        }];
        //请求未审核通过原因
        if (_dataModel.vehicleId) {
            NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
            [requestDic setObject:_dataModel.vehicleId forKey:@"vehicleId"];
            [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_auditreason requestType:KRequestType_auditreason];
        }
    }
    //运营证
    if (!_operateCertificate) {
        _operateCertificate = [[NSMutableArray alloc] initWithCapacity:4];
    }
    if ([_dataModel.extension objectForKey:OperatePhoto]) {
        CarOwnerOperatePhotoModel *tempOperatePhotoModel = (CarOwnerOperatePhotoModel*)[_dataModel.extension objectForKey:OperatePhoto];
        //第一张图片
        NSMutableDictionary *firstDic = [[NSMutableDictionary alloc] init];
        [firstDic setObject:@"1" forKey:@"state"];
        [firstDic setObject:tempOperatePhotoModel.firstUrl forKey:@"url"];
        [_operateCertificate addObject:firstDic];
        //第二张图片
        NSMutableDictionary *secondDic = [[NSMutableDictionary alloc] init];
        [secondDic setObject:@"1" forKey:@"state"];
        [secondDic setObject:tempOperatePhotoModel.secondUrl forKey:@"url"];
        [_operateCertificate addObject:secondDic];
        //第三张图片
        NSMutableDictionary *thirdDic = [[NSMutableDictionary alloc] init];
        [thirdDic setObject:@"1" forKey:@"state"];
        [thirdDic setObject:tempOperatePhotoModel.thirdUrl forKey:@"url"];
        [_operateCertificate addObject:thirdDic];
        //第四张图片
        NSMutableDictionary *fourthDic = [[NSMutableDictionary alloc] init];
        [fourthDic setObject:@"1" forKey:@"state"];
        [fourthDic setObject:tempOperatePhotoModel.fourthUrl forKey:@"url"];
        [_operateCertificate addObject:fourthDic];
    }
    //车辆照片
    if (!_carPhotos) {
        _carPhotos = [[NSMutableArray alloc] initWithCapacity:3];
    }
    if ([_dataModel.extension objectForKey:VehiclePhoto])
    {
        CarOwnerVehiclePhotoModel *tempVehiclePhotoModel = (CarOwnerVehiclePhotoModel*)[_dataModel.extension objectForKey:VehiclePhoto];
        //第一张图片
        NSMutableDictionary *firstDic = [[NSMutableDictionary alloc] init];
        [firstDic setObject:@"1" forKey:@"state"];
        [firstDic setObject:tempVehiclePhotoModel.frontUrl forKey:@"url"];
        [_carPhotos addObject:firstDic];
        //第二张图片
        NSMutableDictionary *secondDic = [[NSMutableDictionary alloc] init];
        [secondDic setObject:@"1" forKey:@"state"];
        [secondDic setObject:tempVehiclePhotoModel.sideUrl forKey:@"url"];
        [_carPhotos addObject:secondDic];
        //第三张图片
        NSMutableDictionary *thirdDic = [[NSMutableDictionary alloc] init];
        [thirdDic setObject:@"1" forKey:@"state"];
        [thirdDic setObject:tempVehiclePhotoModel.backUrl forKey:@"url"];
        [_carPhotos addObject:thirdDic];
    }
    //重新刷新数据源
    [self.mainTableView reloadData];
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

#pragma mark --- 提交审核，提交审核中，提交审核失败  tranBackground  waitLoadingIcon waitSuccessIcon
-(void)submitAuditState
{
    //消除遮罩层
    UIView *parentView = [[UIApplication sharedApplication] keyWindow];
    UIView *maskView  = [parentView viewWithTag:112];
    if (maskView) {
        [maskView removeFromSuperview];
    }
    
    [_submitButton setTitle:@"提交审核" forState:UIControlStateNormal];
    [_submitImageView setImage:[UIImage imageNamed:@"tranBackground"]];
    //停止旋转
    [_submitImageView.layer removeAnimationForKey:@"rotationAnimation"];
}

-(void)submitIngState
{
    //添加遮罩层
    UIView *maskView = [[UIView alloc] init];
    UIView *parentView = [[UIApplication sharedApplication] keyWindow];
    [parentView addSubview:maskView];
    [maskView setTag:112];
    [maskView setBackgroundColor:[UIColor clearColor]];
    [maskView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    //提交中
    [_submitButton setTitle:@"提交中......" forState:UIControlStateNormal];
    [_submitImageView setImage:[UIImage imageNamed:@"waitLoadingIcon"]];
    //设置360旋转
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.cumulative = YES;
    [_submitImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)submitSuccessState
{
    //消除遮罩层
    UIView *parentView = [[UIApplication sharedApplication] keyWindow];
    UIView *maskView  = [parentView viewWithTag:112];
    if (maskView) {
        [maskView removeFromSuperview];
    }
    
    [_submitButton setTitle:@"提交成功" forState:UIControlStateNormal];
    [_submitImageView setImage:[UIImage imageNamed:@"tranBackground"]];
    //停止旋转
    [_submitImageView.layer removeAnimationForKey:@"rotationAnimation"];
}

#pragma mark --DatePickerViewDelegate
- (void)pickerViewCancel
{
    [_datePicker cancelPicker:[[UIApplication sharedApplication] keyWindow]];
}
- (void)pickerViewOK:(NSString*)date
{
    _dataModel.registerTime = [[NSString alloc] initWithFormat:@"%@ 00:00:00",date];
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
    NSMutableDictionary *companyDict = (NSMutableDictionary*)companyInfor;
    _dataModel.companyName = [(NSMutableDictionary*)companyDict valueForKey: @"name"];
    _dataModel.companyId = [(NSMutableDictionary*)companyDict valueForKey: @"id"];
    [self.mainTableView reloadData];
}
#pragma mark -- CarOwnerDriverSearchViewControllerDelegate
//搜索驾驶员
-(void)seachSelected:(NSObject*)Infor
{
    
}
#pragma mark -- CustomAlertViewDelegate
- (void)customAlertViewCancel
{
    
}
- (void)customAlertViewOK:(NSString*)result  useType:(int)useType
{
    switch (useType) {
        case 2:
        {
            _dataModel.licensePlate = result;
        }
            break;
        case 7:
        {
            @try {
                _dataModel.length = [result intValue];
            }   @catch(NSException *ex) {
                [self showTipsView: @"输入的车辆长度不是数字，请重新选择！"];
            }
        }
            break;
        default:
            break;
    }
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
            NSDictionary *businessScopeDict = [_businessScopeArray objectAtIndex:index];
            _dataModel.businessScopeId = [(NSString *)[businessScopeDict valueForKey: @"id"] intValue];
            _dataModel.businessScopeName = [businessScopeDict valueForKey: @"name"];
        }
            break;
        case 3:
        {
            //座位数
            _dataModel.seats = [[_seatNumberArray objectAtIndex:index] intValue];
        }
            break;
        case 4:
        {
            //车辆等级类型
            //            _vehicleLevel = [_vehicleLevelArray objectAtIndex:index];
            //            _vehicleType = [_vehicleLevelArray objectAtIndex:index];
            
            _levelType = [_levelTypeArray objectAtIndex:index];
            _dataModel.levelId = [[_levelType valueForKey: @"levelId"] intValue];
            _dataModel.levelName = [_levelType valueForKey: @"levelName"];
            _dataModel.typeId = [[_levelType valueForKey: @"typeId"] intValue];
            _dataModel.typeName = [_levelType valueForKey: @"typeName"];
            break;
        }
        case 5:
        {
            //燃油类别
            NSDictionary *fuelDict = [_fuelTypeArray objectAtIndex:index];
            _dataModel.fuelTypeId = [[fuelDict valueForKey: @"id"] intValue];
            _dataModel.fuelTypeName = [fuelDict valueForKey: @"name"];
        }
            break;
        case 7:
        {
            //车辆类型
            //_vehicleType = [_vehicleTypeArray objectAtIndex:index];
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
    switch (indexPath.section) {
        case 0:
            return 46.f;
            break;
        case 1:
            return 127.f;
            break;
        case 2:
            return 127.f;
            break;
        default:
            break;
    }
    return 1.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    
                    //                    CarOwnerCompanySearchViewController *tempCarOwnerCompanySearchViewController = [[CarOwnerCompanySearchViewController alloc] init];
                    //                    [self.navigationController pushViewController:tempCarOwnerCompanySearchViewController animated:YES];
                    [self performSegueWithIdentifier:@"toSeachCompany" sender:self];
                }
                    break;
                case 1:
                {
                    
                    if (!self.businessScopeArray) {
                        self.businessScopeArray = [[NSMutableArray alloc] init];
                    }
                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:self.businessScopeArray useType:(int)indexPath.row];
                    _pickerView.delegate = self;
                    NSMutableDictionary *businessScopeDict = [[NSMutableDictionary alloc] init];
                    [businessScopeDict setValue: [[NSString alloc] initWithFormat: @"%d", _dataModel.businessScopeId] forKey:@"id"];
                    [businessScopeDict setValue: _dataModel.businessScopeName forKey: @"name"];
                    [_pickerView setDefaultValue: businessScopeDict];
                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 2:
                {
                    //填写车辆牌照
                    CustomAlertView *alertView = [[CustomAlertView alloc] initWithFrame:self.view.frame alertName:@"车牌牌照" alertInputContent: _dataModel.licensePlate?_dataModel.licensePlate:@"川" alertUnit:@"" keyboardType:UIKeyboardTypeDefault useType:(int)indexPath.row];
                    [alertView.inputDate becomeFirstResponder];
                    alertView.delegate = self;
                    [alertView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 3:
                {
                    if (!_seatNumberArray) {
                        _seatNumberArray = [[NSMutableArray alloc] init];
                    }
                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:_seatNumberArray useType:(int)indexPath.row];
                    _pickerView.delegate = self;
                    [_pickerView setDefaultValue: [[NSString alloc] initWithFormat: @"%d", _dataModel.seats]];
                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 4:
                {
                    if (!_levelTypeArray) {
                        _levelTypeArray = [[NSMutableArray alloc] init];
                        //对数据进行拼装
                        if (_vehicleLevelArray && _vehicleTypeArray) {
                            //对等级进行拼装
                            for (int i=0; i<_vehicleLevelArray.count; i++) {
                                //对类型进行拼装
                                for (int j=0; j<_vehicleTypeArray.count; j++) {
                                    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                                    [tempDic setObject:[[NSString alloc] initWithFormat:@"%d",i+j] forKey:@"id"];
                                    [tempDic setObject:[[NSString alloc] initWithFormat:@"%@%@",[_vehicleTypeArray[j] objectForKey:@"name"],[_vehicleLevelArray[i] objectForKey:@"name"]] forKey:@"name"];
                                    [tempDic setObject:[[NSString alloc] initWithFormat:@"%@",[_vehicleLevelArray[i] objectForKey:@"id"]] forKey:@"levelId"];
                                    [tempDic setObject:[[NSString alloc] initWithFormat:@"%@",[_vehicleLevelArray[i] objectForKey:@"name"]] forKey:@"levelName"];
                                    [tempDic setObject:[[NSString alloc] initWithFormat:@"%@",[_vehicleTypeArray[j] objectForKey:@"id"]] forKey:@"typeId"];
                                    [tempDic setObject:[[NSString alloc] initWithFormat:@"%@",[_vehicleTypeArray[j] objectForKey:@"name"]] forKey:@"typeName"];
                                    //添加到数组
                                    [_levelTypeArray addObject:tempDic];
                                }
                            }
                        }
                    }
                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:_levelTypeArray useType:(int)indexPath.row];
                    _pickerView.delegate = self;
                    [_pickerView setDefaultValue: self.levelType];
                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 5:
                {
                    //燃油类型
                    if (!_fuelTypeArray) {
                        _fuelTypeArray = [[NSMutableArray alloc] init];
                    }
                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:_fuelTypeArray useType:(int)indexPath.row];
                    _pickerView.delegate = self;
                    NSMutableDictionary *fuelDict = [[NSMutableDictionary alloc] init];
                    NSString *value = [[NSString alloc] initWithFormat: @"%d", _dataModel.fuelTypeId];
                    [fuelDict setValue: value forKey:@"id"];
                    [fuelDict setValue: _dataModel.fuelTypeName forKey: @"name"];
                    [_pickerView setDefaultValue: fuelDict];
                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                case 6:
                {
                    //0xB5B8BB  0xFD5936
                    if(!_datePicker)
                    {
                        _datePicker = [[DatePickerView alloc] initWithFrame:self.view.frame];
                    }
                    _datePicker.delegate = self;
                    [_datePicker.btnCancel setTitleColor:UIColorFromRGB(0xB5B8BB) forState:UIControlStateNormal];
                    [_datePicker.btnOk setTitleColor:UIColorFromRGB(0xFD5936) forState:UIControlStateNormal];
                    [_datePicker.lineImageView setBackgroundColor:UIColorFromRGB(0xFD5936)];
                    //设置最大值
                    _datePicker.datePicker.maximumDate = [NSDate date];
                    if ([self isNotEmptyString: _dataModel.registerTime])
                    {
                        //服务器时间转换
                        NSDate *tempDate  = [DateUtils stringToDate:_dataModel.registerTime];
                        //设置已经设置过的值
                        _datePicker.datePicker.date = tempDate ? tempDate :[NSDate date];
                    }
                    
                    
                    [_datePicker showInView:[[UIApplication sharedApplication] keyWindow]];
                    
                }
                    break;
                    //                case 7:
                    //                {
                    //                    if (!_vehicleTypeArray) {
                    //                        _vehicleTypeArray = [[NSMutableArray alloc] init];
                    //                    }
                    //                    _pickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:_vehicleTypeArray useType:(int)indexPath.row];
                    //                    _pickerView.delegate = self;
                    //                    [_pickerView showInView:[[UIApplication sharedApplication] keyWindow]];
                    //                }
                    //                    break;
                case 7:
                {
                    //填写车辆长度
                    CustomAlertView *alertView = [[CustomAlertView alloc] initWithFrame:self.view.frame alertName:@"车俩长度" alertInputContent:[[NSString alloc] initWithFormat: @"%d", _dataModel.length] alertUnit:@"MM" keyboardType:UIKeyboardTypeNumberPad useType:(int)indexPath.row];
                    alertView.delegate = self;
                    [alertView.inputDate becomeFirstResponder];
                    [alertView showInView:[[UIApplication sharedApplication] keyWindow]];
                }
                    break;
                    //                case 9:
                    //                {
                    //                    [self performSegueWithIdentifier:@"toSeachDriver" sender:self];
                    //                }
                    //                    break;
                default:
                    break;
            }
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark --- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 8;
            break;
        case 1:
            return 1;
            break;
        case 2:
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
    switch (indexPath.section) {
        case 0:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"basicInforCellIdent"];
            //设置颜色
            tempCell.textLabel.textColor = UIColorFromRGB(0x030303);
            tempCell.detailTextLabel.textColor = UIColorFromRGB(0x333333);
            switch (indexPath.row) {
                case 0:
                {
                    tempCell.textLabel.text=@"公司名称";
                    //根据数据源判断显示内容
                    if ([self isNotEmptyString: _dataModel.companyName])
                    {
                        //设置公司名称
                        tempCell.detailTextLabel.text = _dataModel.companyName;
                    }
                    else
                    {
                        tempCell.detailTextLabel.text=@"请选择公司名称";
                    }
                    
                }
                    
                    break;
                case 1:
                {
                    tempCell.textLabel.text=@"经营范围";
                    //根据数据源判断显示内容
                    if ([self isNotEmptyString: _dataModel.businessScopeName])
                    {
                        tempCell.detailTextLabel.text = _dataModel.businessScopeName;
                    }
                    else
                    {
                        tempCell.detailTextLabel.text=@"请选择经营范围";
                    }
                }
                    break;
                case 2:
                {
                    tempCell.textLabel.text=@"车辆牌照";
                    [tempCell setAccessoryType:UITableViewCellAccessoryNone];
                    //根据数据源判断显示内容
                    if ([self isNotEmptyString: _dataModel.licensePlate])
                    {
                        tempCell.detailTextLabel.text = _dataModel.licensePlate;
                        tempCell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
                    }
                    else
                    {
                        tempCell.detailTextLabel.text=@"请填写车牌牌照";
                        tempCell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
                    }
                }
                    break;
                case 3:
                {
                    tempCell.textLabel.text=@"座位数";
                    //根据数据源判断显示内容
                    if (_dataModel.seats != 0)
                    {
                        tempCell.detailTextLabel.text = [[NSString alloc] initWithFormat: @"%d", _dataModel.seats];
                    }
                    else
                    {
                        tempCell.detailTextLabel.text=@"请选择座位数";
                    }
                }
                    break;
                case 4:
                {
                    tempCell.textLabel.text=@"等级类型";
                    //根据数据源判断显示内容
                    if (_levelType && [(NSDictionary*)_levelType objectForKey:@"name"])
                    {
                        tempCell.detailTextLabel.text = [(NSDictionary*)_levelType objectForKey:@"name"];
                    }
                    else
                    {
                        tempCell.detailTextLabel.text=@"请选择等级类型";
                    }
                    
                }
                    break;
                case 5:
                {
                    tempCell.textLabel.text=@"燃油类别";
                    //根据数据源判断显示内容
                    if ([self isNotEmptyString: _dataModel.fuelTypeName])
                    {
                        tempCell.detailTextLabel.text = _dataModel.fuelTypeName;
                    }
                    else
                    {
                        tempCell.detailTextLabel.text=@"请选择燃油类别";
                    }
                }
                    break;
                case 6:
                {
                    tempCell.textLabel.text=@"上户时间";
                    //根据数据源判断显示内容
                    if ([self isNotEmptyString: _dataModel.registerTime])
                    {
                        //服务器时间转换
                        NSDate *tempDate  = [DateUtils stringToDate:_dataModel.registerTime];
                        tempCell.detailTextLabel.text = [DateUtils formatDate:tempDate format:@"yyyy-MM-dd"];
                    }
                    else
                    {
                        tempCell.detailTextLabel.text=@"请选择上户时间";
                    }
                }
                    break;
                    //                case 7:
                    //                {
                    //                    tempCell.textLabel.text=@"车辆类型";
                    //                    //根据数据源判断显示内容
                    //                    if (_vehicleType && [(NSDictionary*)_vehicleType objectForKey:@"name"])
                    //                    {
                    //                        tempCell.detailTextLabel.text = [(NSDictionary*)_vehicleType objectForKey:@"name"];
                    //                    }
                    //                    else
                    //                    {
                    //                        tempCell.detailTextLabel.text=@"请选择车辆类型";
                    //                    }
                    //                }
                    //                    break;
                case 7:
                {
                    tempCell.textLabel.text=@"车辆长度";
                    [tempCell setAccessoryType:UITableViewCellAccessoryNone];
                    //根据数据源判断显示内容
                    if (_dataModel.length != 0)
                    {
                        tempCell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@%@", [[NSString alloc] initWithFormat: @"%d", _dataModel.length], @"MM"];
                        tempCell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
                    }
                    else
                    {
                        tempCell.detailTextLabel.text=@"请填写车牌长度";
                        tempCell.detailTextLabel.font = [UIFont systemFontOfSize:15.f];
                    }
                }
                    break;
                    //                case 9:
                    //                {
                    //                    tempCell.textLabel.text=@"驾驶员";
                    //                    //根据数据源判断显示内容
                    //                    if (_vehicleDriver)
                    //                    {
                    //                        tempCell.detailTextLabel.text = (NSString*)_vehicleDriver;
                    //                    }
                    //                    else
                    //                    {
                    //                        tempCell.detailTextLabel.text=@"请选择驾驶员";
                    //                    }
                    //                }
                    //                    break;
                default:
                    break;
            }
            
        }
            break;
        case 1:
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
        case 2:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"vehicleCellIdent"];
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
    
    ResultDataModel *resultData = (ResultDataModel*)notification.object;
    NSDictionary *result = resultData.data;
    
    switch (resultData.requestType) {
        case KRequestType_postvehicle:
        {
            if (resultData.resultCode == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if (resultData.resultCode == 100002)
            {
                [self showTipsView:@"已存在该车牌号车"];
            }
            else if (resultData.resultCode == 100006)
            {
                [self showTipsView:@"已存在该车牌号车"];
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
        case KRequestType_auditreason:
        {
            if (resultData.resultCode == 0)
            {
                _errorText.text = [resultData.data objectForKey:@"content"] ? [resultData.data objectForKey:@"content"] : @"未填写审核信息......";
                _errorText.textColor = [UIColor whiteColor];
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

#pragma mark --- NetInterfaceDelegate

/**
 *  HTTP同步请求成功时的回调方法
 *
 *  @param dict 通知回调
 */
-(BOOL) httpRequestSeccess: (NSDictionary *)dict {
    //返回的数据对象
    ResultDataModel *resultParse = [[ResultDataModel alloc] initWithDictionary:dict reqType:_requestType];
    
    switch(_requestType) {
        case KRequestType_GetBusinessScope:
            //获取经营范围
            if (resultParse.resultCode == 0 && [resultParse.data objectForKey:@"list"])
            {
                //如果返回存在此对象
                _businessScopeArray = [resultParse.data objectForKey:@"list"];
            }
            break;
        case KRequestType_GetVehicleType:
            //获取车辆等级
            if (resultParse.resultCode == 0 && [resultParse.data objectForKey:@"list"])
            {
                //如果返回存在此对象
                _vehicleTypeArray = [resultParse.data objectForKey:@"list"];
            }
            break;
        case KRequestType_GetVehicleLevel:
            //获取车辆等级
            if (resultParse.resultCode == 0 && [resultParse.data objectForKey:@"list"])
            {
                //如果返回存在此对象
                _vehicleLevelArray = [resultParse.data objectForKey:@"list"];
            }
            break;
        case KRequestType_GetFuelType:
            //获取燃油类型
            if (resultParse.resultCode == 0 && [resultParse.data objectForKey:@"list"])
            {
                //如果返回存在此对象
                _fuelTypeArray = [resultParse.data objectForKey:@"list"];
            }
            break;
        default:
            break;
    }
    return YES;
}

/**
 *  HTTP同步请求失败时的回调方法
 *
 *  @param message 通知回调
 */
-(BOOL) httpRequestFailure:(NSString *)message {
    [self stopWait];
    [self performSelectorOnMainThread: @selector(showTipsView:) withObject: message waitUntilDone:YES];
    [_submitButton setEnabled: NO];
    return NO;
}

@end
