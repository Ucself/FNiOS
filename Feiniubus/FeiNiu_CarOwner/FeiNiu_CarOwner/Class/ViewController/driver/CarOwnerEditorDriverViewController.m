//
//  CarOwnerEditorDriverViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerEditorDriverViewController.h"
#import <FNNetInterface/UIImageView+AFNetworking.h>
#import <FNUIView/SelectView.h>
#import <FNUIView/DatePickerView.h>
#import <FNUIView/CustomPickerView.h>
#import <FNUIView/CustomAlertView.h>
#import "ProtocolCarOwner.h"

typedef NS_ENUM(int, UploadType)
{
    UploadTypeOperate = 1,  //证件照片
    UploadTypeHead,      //头像
};

#define driverName          @"driverName"
#define driverPhone         @"driverPhone"
#define driverCardNum       @"driverCardNum"

@interface CarOwnerEditorDriverViewController ()<UITableViewDelegate,UITableViewDataSource,SelectViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomAlertViewDelegate,DatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
//按钮对象
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIImageView *submitImageView;

//错误视图
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UITextView *errorTextView;



//时间选择器
@property (nonatomic, strong) DatePickerView *datePicker;
//上传选择器
@property (nonatomic, strong) SelectView *selectView;
//其他类别选择器
@property (nonatomic, strong) CustomPickerView *pickerView;
//选择上传的图片类型
@property (nonatomic, assign) int uploadTag;



@end

@implementation CarOwnerEditorDriverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //iOS7重新设置布局
    [_submitButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
//    [_mainTableView makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view);
//    }];
    
    //设置按钮状态
    [self submitAuditState];
    
    //根据具体信息展示标题
    switch (_controllerType) {
        case ControllerTypeAddDriver:
        {
            self.navigationItem.title = @"添加驾驶员";
        }
            break;
        case ControllerTypeEditorDriver:
        {
            self.navigationItem.title = @"修改驾驶员";
        }
            break;
        case ControllerTypeErrorDriver:
        {
            self.navigationItem.title = @"审核失败驾驶员";
            //设置错误信息
            [_errorView makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(70);
            }];
        }
            break;
        default:
            break;
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)submitClick:(id)sender {
    //头像验证
    if (![_headPhoto objectForKey:@"state"] || [[_headPhoto objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传头像"];
        return;
    }
    //姓名验证
    if (!_driverInfor || [[_driverInfor objectForKey:driverName] isEqualToString:@""]) {
        [self showTipsView:@"请输入驾驶员姓名"];
        return;
    }
    //联系电话验证
    if (!_driverInfor || [[_driverInfor objectForKey:driverPhone] isEqualToString:@""] || ![BCBaseObject isMobileNumber:[_driverInfor objectForKey:driverPhone]]) {
        [self showTipsView:@"请输入正确的电话号码"];
        return;
    }
    //身份证号码isPersonCard
    if (!_driverInfor || [[_driverInfor objectForKey:driverCardNum] isEqualToString:@""] || ![BCBaseObject isPersonCard:[_driverInfor objectForKey:driverCardNum]]) {
        [self showTipsView:@"请输入正确的身份证号码"];
        return;
    }
    //身份证正面验证
    if (!_cardPhotos[0] || ![_cardPhotos[0] objectForKey:@"state"] || [[(NSDictionary*)_cardPhotos[0] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传身份证正面图片"];
        return;
    }
    //身份证背面验证
    if (!_cardPhotos[1] || ![_cardPhotos[1] objectForKey:@"state"] || [[(NSDictionary*)_cardPhotos[1] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传身份证背面图片"];
        return;
    }
    //驾驶证验证
    if (!_cardPhotos[2] || ![_cardPhotos[2] objectForKey:@"state"] || [[(NSDictionary*)_cardPhotos[2] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传驾驶证图片"];
        return;
    }
    //资格证验证
    if (!_cardPhotos[3] || ![_cardPhotos[3] objectForKey:@"state"] || [[(NSDictionary*)_cardPhotos[3] objectForKey:@"state"] isEqualToString:@"0"]) {
        [self showTipsView:@"请上传资格证图片"];
        return;
    }
    //等待视图
    [self submitIngState];
    //判断是否是服务器上图片，如果是就直接提交
    if ([[_headPhoto objectForKey:@"state"] isEqualToString:@"1"] &&
        [[(NSDictionary*)_cardPhotos[0] objectForKey:@"state"] isEqualToString:@"1"] &&
        [[(NSDictionary*)_cardPhotos[1] objectForKey:@"state"] isEqualToString:@"1"] &&
        [[(NSDictionary*)_cardPhotos[2] objectForKey:@"state"] isEqualToString:@"1"] &&
        [[(NSDictionary*)_cardPhotos[3] objectForKey:@"state"] isEqualToString:@"1"]
        )
    {
        //上传更改的图片开始
        [self startWait];
        [self updateDriverInfor];
        return;
    }
    [self uploadPhotos:UploadTypeHead index:0];
    return;
    
}
//更新驾驶员信息
-(void)updateDriverInfor
{
    //标示是否可以上传
    BOOL canUpdate = YES;
    //判断头像是否已经上传
    if (!([_headPhoto objectForKey:@"state"] && [[_headPhoto objectForKey:@"state"] isEqualToString:@"1"]))
    {
        canUpdate = NO;
    }
    //判断证件是否已经上传
    for (NSMutableDictionary *tempCardPhotos in _cardPhotos) {
        if (!([tempCardPhotos objectForKey:@"state"] && [[tempCardPhotos objectForKey:@"state"] isEqualToString:@"1"]))
        {
            canUpdate = NO;
        }
    }
    //如果都上传完成即可更新驾驶员信息
    if (canUpdate) {
        NSMutableDictionary *driverInforDic = [[NSMutableDictionary alloc] init];
        [driverInforDic setObject:[_driverInfor objectForKey:driverName] forKey:@"Name"];
        [driverInforDic setObject:[_driverInfor objectForKey:driverPhone] forKey:@"Phone"];
        [driverInforDic setObject:[_driverInfor objectForKey:driverCardNum] forKey:@"IdCardNumber"];
        [driverInforDic setObject:[_headPhoto objectForKey:@"url"] forKey:@"FacePath"];
        //图片dic
        NSMutableDictionary *cardPhotoDic = [[NSMutableDictionary alloc] init];
        [cardPhotoDic setObject:[(NSMutableDictionary *)_cardPhotos[0] objectForKey:@"url"] forKey:@"IdCardAPhoto"];
        [cardPhotoDic setObject:[(NSMutableDictionary *)_cardPhotos[1] objectForKey:@"url"] forKey:@"IdCardBPhoto"];
        [cardPhotoDic setObject:[(NSMutableDictionary *)_cardPhotos[2] objectForKey:@"url"] forKey:@"DriverLicensePhoto"];
        [cardPhotoDic setObject:[(NSMutableDictionary *)_cardPhotos[3] objectForKey:@"url"] forKey:@"VehicleLicensePhoto"];
        
        [driverInforDic setObject:cardPhotoDic forKey:@"Extension"];
        
        [self startWait];
        
        if(_controllerType == ControllerTypeAddDriver)
        {
            [[ProtocolCarOwner sharedInstance] postInforWithNSDictionary:driverInforDic urlSuffix:Kurl_driver requestType:KRequestType_postDriver];
        }
        else
        {
            [driverInforDic setObject:_driverId forKey:@"Id"];
            [[ProtocolCarOwner sharedInstance] putInforWithNSDictionary:driverInforDic urlSuffix:Kurl_driver requestType:KRequestType_postDriver];
        }
    }
}

//上传相关数据图片
-(void)uploadPhotos:(UploadType)type index:(int)index
{
    switch (type) {
        case UploadTypeHead:
        {
            if ([_headPhoto objectForKey:@"state"] && [[_headPhoto objectForKey:@"state"] isEqualToString:@"2"])
            {
                //普通照片
                NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
                [bodyDic setObject:[[NSString alloc] initWithFormat:@"%d",ImageTypeCommon] forKey:@"Type"];
                //提示等待符号
                [[ProtocolCarOwner sharedInstance] uploadImage:(UIImage*)[_headPhoto objectForKey:@"newImage"]  body:bodyDic suceeseBlock:^(NSString *msg) {
                    
                    //上传成功处理数据
                    if( [self imageUploadSucees:msg type:UploadTypeHead index:index])
                    {
                        //传下一张图片，证件照
                        [self uploadPhotos:UploadTypeOperate index:0];
                    }
                    
                    
                } failedBlock:^(NSError *error) {
                    //提示等待符号
                    [self stopWait];
                    [self showTipsView:@"图片上传失败"];
                }];
            }
            else
            {
                //传下一张图片，证件照
                [self uploadPhotos:UploadTypeOperate index:0];
            }
        }
            break;
        case UploadTypeOperate:
        {
            if ([_cardPhotos[index] objectForKey:@"state"] && [[(NSDictionary*)_cardPhotos[index] objectForKey:@"state"] isEqualToString:@"2"])
            {
                //证件照片
                NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
                [bodyDic setObject:[[NSString alloc] initWithFormat:@"%d",ImageTypeCertificate] forKey:@"Type"];
                //提示等待符号
                [[ProtocolCarOwner sharedInstance] uploadImage:(UIImage*)[_cardPhotos[index] objectForKey:@"newImage"] body:bodyDic suceeseBlock:^(NSString *msg) {
                    //上传成功处理数据
                    if (![self imageUploadSucees:msg type:UploadTypeOperate index:index]) {
                        return ;
                    };
                    //传下一张图片，如果已经是第四张，则上传车辆照片
                    if (index < 3)
                    {
                        [self uploadPhotos:type index:index+1];
                    }
                    else if (index == 3)
                    {
                        [self updateDriverInfor];
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
                    [self uploadPhotos:type index:index+1];
                }
                else if (index == 3)
                {
                    [self updateDriverInfor];
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
            [(NSMutableDictionary*)_cardPhotos[index] setObject:[dict objectForKey:@"url"] forKey:@"url"];
            [(NSMutableDictionary*)_cardPhotos[index] setObject:@"1" forKey:@"state"];
        }
        //如果是上传的车辆照片
        if (type == UploadTypeHead && [dict objectForKey:@"url"])
        {
            [_headPhoto setObject:[dict objectForKey:@"url"] forKey:@"url"];
            [_headPhoto setObject:@"1" forKey:@"state"];
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
        [self showTipsView:@"图片上传失败,请重试"];
        return NO;
    }
    return YES;
}


#pragma mark ---
/**
 *  初始化界面
 */
-(void)initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    //初始化头像数据
    if (!_headPhoto) {
        _headPhoto = [[NSMutableDictionary alloc] init];
    }
    //设置用户初始值
    if (!_driverInfor) {
        _driverInfor = [[NSMutableDictionary alloc] init];
        //驾驶员名称
        [_driverInfor setObject:@"" forKey:driverName];
        //联系电话
        [_driverInfor setObject:@"" forKey:driverPhone];
        //身份证号
        [_driverInfor setObject:@"" forKey:driverCardNum];
    }
    //默认证件照片数据
    if (!_cardPhotos)
    {
        _cardPhotos = [[NSMutableArray alloc] initWithCapacity:4];
        [_cardPhotos addObject:[NSMutableDictionary new]];
        [_cardPhotos addObject:[NSMutableDictionary new]];
        [_cardPhotos addObject:[NSMutableDictionary new]];
        [_cardPhotos addObject:[NSMutableDictionary new]];
    }
    //根据页面过来的类型判断是否请求数据
    switch (_controllerType) {
        case ControllerTypeEditorDriver:
        {
            //编辑类型
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
            [tempDic setObject: _driverId ? _driverId : @"" forKey:@"id"];
            //请求数据类型
            [self startWait];
            [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:tempDic urlSuffix:Kurl_driverdetaile requestType:KRequestType_driverdetaile];
        }
            break;
        case ControllerTypeErrorDriver:
        {
            //请求未审核通过原因
            if (_driverId) {
                //编辑类型
                NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject: _driverId ? _driverId : @"" forKey:@"id"];
                //请求数据类型
                [self startWait];
                [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:tempDic urlSuffix:Kurl_driverdetaile requestType:KRequestType_driverdetaile];
                NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
                [requestDic setObject:_driverId forKey:@"driverId"];
                [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_driverAuditReason requestType:KRequestType_driverAuditReason];
            }
        }
            break;
        default:
            break;
    }
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
}
//圆边
- (void) roundImageView:(UIImageView*)imageView
{
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
}

#pragma mark --- 提交审核，提交审核中，提交审核失败  tranBackground  waitLoadingIcon waitSuccessIcon
-(void)submitAuditState
{
    return;
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
    return;
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

#pragma mark --- CustomAlertViewDelegate
- (void)customAlertViewCancel
{
    
}
- (void)customAlertViewOK:(NSString*)result  useType:(int)useType
{
    switch (useType) {
        case 1:
        {
            [_driverInfor setObject:result forKey:driverName];
        }
            break;
        case 2:
        {
            [_driverInfor setObject:result forKey:driverPhone];
        }
            break;
        case 3:
        {
            [_driverInfor setObject:result forKey:driverCardNum];
        }
            break;
        default:
            break;
    }
    
    [self.mainTableView reloadData];
}

#pragma mark --- SelectViewDelegate
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
#pragma mark --DatePickerViewDelegate
- (void)pickerViewCancel
{
    [_datePicker cancelPicker:[[UIApplication sharedApplication] keyWindow]];
}
- (void)pickerViewOK:(NSString*)date
{
//    
//    [_driverInfor setObject:date forKey:driverBirth];
//    [self.mainTableView reloadData];
//    [_datePicker cancelPicker:[[UIApplication sharedApplication] keyWindow]];
}
#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0)
            {
                return 80.f;
            }
            else
            {
                return 48.f;
            }
        }
            break;
        case 1:
        {
            return 127.f;
        }
            break;
        default:
            break;
    }
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //点击了第一个选项
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                //头像点击了，这里不做处理
            }
                break;
            case 1:
            {
                //填写名称
                CustomAlertView *alertView = [[CustomAlertView alloc] initWithFrame:self.view.frame alertName:@"输入驾驶员名称" alertInputContent:[_driverInfor objectForKey:driverName] alertUnit:@"" keyboardType:UIKeyboardTypeDefault useType:(int)indexPath.row];
                alertView.delegate = self;
                [alertView.inputDate becomeFirstResponder];
                [alertView showInView:[[UIApplication sharedApplication] keyWindow]];
            }
                break;
            case 2:
            {
                CustomAlertView *alertView = [[CustomAlertView alloc] initWithFrame:self.view.frame alertName:@"请输入联系电话" alertInputContent:[_driverInfor objectForKey:driverPhone] alertUnit:@"" keyboardType:UIKeyboardTypeNumberPad useType:(int)indexPath.row];
                alertView.delegate = self;
                [alertView.inputDate becomeFirstResponder];
                [alertView showInView:[[UIApplication sharedApplication] keyWindow]];
            }
                break;
            case 3:
            {
                CustomAlertView *alertView = [[CustomAlertView alloc] initWithFrame:self.view.frame alertName:@"请输入身份证号" alertInputContent:[_driverInfor objectForKey:driverCardNum] alertUnit:@"" keyboardType:UIKeyboardTypeASCIICapable useType:(int)indexPath.row];
                alertView.delegate = self;
                [alertView.inputDate becomeFirstResponder];
                alertView.limitCount = 18;
                [alertView showInView:[[UIApplication sharedApplication] keyWindow]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}

#pragma mark ---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    tempCell = [tableView dequeueReusableCellWithIdentifier:@"headCellIdent"];
                    UIImageView *headImage = (UIImageView *)[tempCell viewWithTag:101];
                    [self roundImageView:headImage];
                    //传入的时候必须包含这三个key
                    if ([[_headPhoto objectForKey:@"state"] isEqualToString:@"0"])
                    {
                        //没有数据
                        [headImage setImage:[UIImage imageNamed:@"defaultHead"]];
                    }
                    else if ([[_headPhoto objectForKey:@"state"] isEqualToString:@"1"] && [_headPhoto objectForKey:@"url"])
                    {
                        //有图片服务器上的图片
                        [headImage setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,[_headPhoto objectForKey:@"url"]]]];
                    }
                    else if ([[_headPhoto objectForKey:@"state"] isEqualToString:@"2"] && [_headPhoto objectForKey:@"newImage"])
                    {
                        //有图片重新上传的图片
                        [headImage setImage:(UIImage*)[_headPhoto objectForKey:@"newImage"]];
                    }
                    //设置图片的点击
                    UITapGestureRecognizer *headImageYunyingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageUploadClick:)];
                    [headImage addGestureRecognizer:headImageYunyingGesture];
                    [headImage setUserInteractionEnabled:YES];
                }
                    break;
                case 1:
                {
                    tempCell = [tableView dequeueReusableCellWithIdentifier:@"customCellIdent"];
                    [tempCell setAccessoryType:UITableViewCellAccessoryNone];
                    tempCell.textLabel.text = @"真实姓名";
                    
                    if( ![[_driverInfor objectForKey:driverName] isEqualToString:@""])
                    {
                        tempCell.detailTextLabel.text = [_driverInfor objectForKey:driverName];
                    }
                    else
                    {
                        tempCell.detailTextLabel.text = @"请输入驾驶员真实姓名";
                    }
                    
                    
                }
                    break;
                case 2:
                {
                    tempCell = [tableView dequeueReusableCellWithIdentifier:@"customCellIdent"];
                    [tempCell setAccessoryType:UITableViewCellAccessoryNone];
                    tempCell.textLabel.text = @"联系电话";
                    if( ![[_driverInfor objectForKey:driverPhone] isEqualToString:@""])
                    {
                        tempCell.detailTextLabel.text = [_driverInfor objectForKey:driverPhone];
                    }
                    else
                    {
                        tempCell.detailTextLabel.text = @"请输入联系电话";
                    }
                }
                    break;
                case 3:
                {
                    tempCell = [tableView dequeueReusableCellWithIdentifier:@"customCellIdent"];
                    [tempCell setAccessoryType:UITableViewCellAccessoryNone];
                    tempCell.textLabel.text = @"身份证号";
                    if( ![[_driverInfor objectForKey:driverCardNum] isEqualToString:@""])
                    {
                        tempCell.detailTextLabel.text = [_driverInfor objectForKey:driverCardNum];
                    }
                    else
                    {
                        tempCell.detailTextLabel.text = @"请输入身份证号";
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"certificateCellIdent"];
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
            if (_cardPhotos.count >=1 &&[_cardPhotos objectAtIndex:0])
            {
                NSDictionary *tempDic = (NSDictionary*)[_cardPhotos objectAtIndex:0];
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
            if (_cardPhotos.count >=2 && [_cardPhotos objectAtIndex:1])
            {
                NSDictionary *tempDic = (NSDictionary*)[_cardPhotos objectAtIndex:1];
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
            if (_cardPhotos.count >=3 && [_cardPhotos objectAtIndex:2])
            {
                NSDictionary *tempDic = (NSDictionary*)[_cardPhotos objectAtIndex:2];
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
            if (_cardPhotos.count >=4 && [_cardPhotos objectAtIndex:3])
            {
                NSDictionary *tempDic = (NSDictionary*)[_cardPhotos objectAtIndex:3];
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
        default:
            break;
    }
    
    
    return tempCell;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
#pragma mark --- <UIActionSheetDelegate>
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        controller.allowsEditing = YES;
        controller.delegate = self;
        [self presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
        
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        [self presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
        
    }
}
#pragma mark --- <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //返回的图片对象
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    //拼装数据结构
    NSMutableDictionary *tempDic;
    
    switch (_uploadTag) {
        case 101:
        {
            //头像
            [_headPhoto setObject:@"2" forKey:@"state"];
            [_headPhoto setObject:image forKey:@"newImage"];
        }
            break;
        case 1111:
        {
            //身份证正
            if (_cardPhotos.count >=1 && [_cardPhotos objectAtIndex:0]) {
                tempDic = [_cardPhotos objectAtIndex:0];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_cardPhotos insertObject:tempDic atIndex:0];
            }
        }
            break;
        case 1112:
        {
            //身份证背
            if (_cardPhotos.count >=2 && [_cardPhotos objectAtIndex:1]) {
                tempDic = [_cardPhotos objectAtIndex:1];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_cardPhotos insertObject:tempDic atIndex:1];
            }
        }
            break;
        case 1113:
        {
            //驾驶证
            if (_cardPhotos.count >=3 && [_cardPhotos objectAtIndex:2]) {
                tempDic = [_cardPhotos objectAtIndex:2];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_cardPhotos insertObject:tempDic atIndex:2];
            }
        }
            break;
        case 1114:
        {
            //资格证
            if (_cardPhotos.count >=4 && [_cardPhotos objectAtIndex:3]) {
                tempDic = [_cardPhotos objectAtIndex:3];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
            }
            else
            {
                tempDic = [[NSMutableDictionary alloc] init];
                [tempDic setObject:@"2" forKey:@"state"];
                [tempDic setObject:image forKey:@"newImage"];
                [_cardPhotos insertObject:tempDic atIndex:2];
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
        case KRequestType_postDriver:
        {
            //更新驾驶员数据
            if (resultParse.resultCode == 0)
            {
                //设置提交成功
                [self submitSuccessState];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if (resultParse.resultCode == 100009)
            {
                //还原状态
                [self submitAuditState];
                //驾驶员已经存在
                [self showTipsView:@"此电话号码驾驶员存在"];
            }
            else if (resultParse.resultCode == 100006)
            {
                //驾驶员已经存在
                [self showTipsView:@"此电话号码驾驶员存在"];
            }
            else
            {
                //还原状态
                [self submitAuditState];
                [self showTipsView:@"与服务器数据交互失败"];
            }
            //还原状态
            [self submitAuditState];
        }
            break;
        case KRequestType_driverdetaile:
        {
            if (resultParse.resultCode == 0)
            {
                NSDictionary *returnDic = (NSDictionary*)[(NSDictionary*)resultParse.data objectForKey:@"data"];
                //对数据进行处理
                //头像数据
                if ([returnDic objectForKey:@"avatar"] && ![[returnDic objectForKey:@"avatar"] isEqualToString:@""])
                {
                    [_headPhoto setObject:@"1" forKey:@"state"];
                    [_headPhoto setObject:[returnDic objectForKey:@"avatar"] forKey:@"url"];
                }
                else
                {
                    [_headPhoto setObject:@"0" forKey:@"state"];
                }
                //驾驶员基本信息 name
                if ([returnDic objectForKey:@"name"])
                {
                    [_driverInfor setObject:[returnDic objectForKey:@"name"] forKey:driverName];
                }
                //驾驶员基本信息 phone
                if ([returnDic objectForKey:@"phone"])
                {
                    [_driverInfor setObject:[returnDic objectForKey:@"phone"] forKey:driverPhone];
                }
                //驾驶员基本信息 idCardNumber
                if ([returnDic objectForKey:@"idCardNumber"])
                {
                    [_driverInfor setObject:[returnDic objectForKey:@"idCardNumber"] forKey:driverCardNum];
                }
                
                //图片信息解析
                if ([returnDic objectForKey:@"extension"]) {
                    NSString *extensionStr = [returnDic objectForKey:@"extension"];
                    extensionStr = [extensionStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSDictionary *tempDic = (NSDictionary*)[JsonUtils jsonToDcit:extensionStr];
                    //数据源错误数据
                    if (![tempDic isKindOfClass:[NSDictionary class]]) {
                        //刷新上面的数据
                        [self.mainTableView reloadData];
                        return;
                    }
                    //身份证正面
                    NSMutableDictionary *idCardAPhotoDic = [[NSMutableDictionary alloc] init];
                    if ([tempDic objectForKey:@"IdCardAPhoto"]) {
                        [idCardAPhotoDic setObject:@"1" forKey:@"state"];
                        [idCardAPhotoDic setObject:[tempDic objectForKey:@"IdCardAPhoto"] forKey:@"url"];
                    }
                    [_cardPhotos replaceObjectAtIndex:0 withObject:idCardAPhotoDic];
                    //身份证背面
                    NSMutableDictionary *idCardBPhotoDic = [[NSMutableDictionary alloc] init];
                    if ([tempDic objectForKey:@"IdCardBPhoto"]) {
                        [idCardBPhotoDic setObject:@"1" forKey:@"state"];
                        [idCardBPhotoDic setObject:[tempDic objectForKey:@"IdCardBPhoto"] forKey:@"url"];
                    }
                    [_cardPhotos replaceObjectAtIndex:1 withObject:idCardBPhotoDic];
                    //驾驶证
                    NSMutableDictionary *driverLicensePhotoDic = [[NSMutableDictionary alloc] init];
                    if ([tempDic objectForKey:@"DriverLicensePhoto"]) {
                        [driverLicensePhotoDic setObject:@"1" forKey:@"state"];
                        [driverLicensePhotoDic setObject:[tempDic objectForKey:@"DriverLicensePhoto"] forKey:@"url"];
                    }
                    [_cardPhotos replaceObjectAtIndex:2 withObject:driverLicensePhotoDic];
                    //资格证
                    NSMutableDictionary *vehicleLicensePhotoDic = [[NSMutableDictionary alloc] init];
                    if ([tempDic objectForKey:@"VehicleLicensePhoto"]) {
                        [vehicleLicensePhotoDic setObject:@"1" forKey:@"state"];
                        [vehicleLicensePhotoDic setObject:[tempDic objectForKey:@"VehicleLicensePhoto"] forKey:@"url"];
                    }
                    [_cardPhotos replaceObjectAtIndex:3 withObject:vehicleLicensePhotoDic];
                }
                
                [self.mainTableView reloadData];
                
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
        case KRequestType_driverAuditReason:
        {
            if (resultParse.resultCode == 0)
            {
                _errorTextView.text = [resultParse.data objectForKey:@"content"] ? [resultParse.data objectForKey:@"content"] : @"未填写审核信息......";
                _errorTextView.textColor = [UIColor whiteColor];
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
    //还原状态
//    [self submitAuditState];
}

@end
