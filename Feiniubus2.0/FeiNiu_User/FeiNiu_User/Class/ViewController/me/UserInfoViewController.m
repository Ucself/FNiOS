//
//  UserInfoViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/13.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "UserInfoViewController.h"

#import <FNNetInterface/UIImageView+AFNetworking.h>
#import <FNUIView/DatePickerView.h>
#import "UserSelectView.h"
#import "AuthorizeCache.h"
#import <FNUIView/SelectPickerView.h>
#import "FeiNiu_User-Swift.h"

#define KImageSize    31
#define kTextNameTag  505
#define kTextEmailTag 506

typedef NS_ENUM(int, ModifyType)
{
    emModify_name = 0,
    emModify_gender,
    emModify_birthday,
    emModify_email,
    emModify_avatar,
};

@interface UserInfoViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate>
{
    
    NSString* uploadImageUrl;   //头像
    NSString* image64Bit;       //头像64位
    NSString* userName;         //用户名
    NSString* userPhone;        //手机号
    NSString* userGender;       //性别
    
    SelectType curSelType;      //当前选择类型
}

@property (nonatomic, strong) NSArray *array;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImageView *headImg;     //用户头像
@property (nonatomic, strong) UITextField *textName;    //用户名

//数据
@property (nonatomic, strong) User *user;

//选择器
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) DatePickerView *datePicker;
@property (nonatomic, strong) UserSelectView *selectView;
@end

@implementation UserInfoViewController

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //监听中文
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:_textName];
    
    [self initProperty];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)initProperty{
    
    self.user = [UserPreferInstance getUserInfo];
    self.array = @[@"头像", @"用户名", @"手机号", @"性别"];
    //初始化数据
    uploadImageUrl = self.user.avatar;
    userName = self.user.name;
    userPhone = self.user.phone;
    userGender = self.user.gender;
    if (!userGender || [userGender isEqualToString:@"Unknown"] || [userGender isEqualToString:@""]) {
        userGender = @"Male";
    }
}


- (void)roundImageView:(UIImageView*)imageView
{
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.layer.borderColor = UIColorFromRGB(0xE6E6E6).CGColor;
    imageView.layer.borderWidth = 0.5f;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    imageView.clipsToBounds = YES;
}

-(void)navigationViewRightClick{
    [super navigationViewRightClick];
    [self.textName resignFirstResponder];
    //验证数据
    if (!userName || [userName isEqualToString:@""]) {
        [self showTip:@"请输入用户名" WithType:FNTipTypeFailure];
        return;
    }
    if (!userGender || [userGender isEqualToString:@"Unknown"] || [userGender isEqualToString:@""]) {
        [self showTip:@"请选择性别" WithType:FNTipTypeFailure];
        return;
    }
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_EditAccount params:^(NetParams *params) {
        params.method = EMRequstMethod_PUT;
        if (image64Bit) {
            params.data = @{@"avatar":@"head.jpg",
                            @"name":userName,
                            @"phone":userPhone,
                            @"gender":userGender,
                            @"base64":image64Bit,
                            };
        }
        else {
            params.data = @{@"avatar":@"head.jpg",
                            @"name":userName,
                            @"phone":userPhone,
                            @"gender":userGender,
                            };
        }
        
    }];
}

#pragma mark-

-(void)showSelectView:(SelectType)type
{
    curSelType = type;
    
    if (!self.selectView) {
        self.selectView = [[UserSelectView alloc] init];
        self.selectView.delegate = self;
    }
    
    self.selectView.type = type;
    
    [self.selectView showInView:self.view];

}

- (UIImagePickerController *)imagePicker {
    if (_imagePicker) {
        return _imagePicker;
    }
    
    _imagePicker = [[UIImagePickerController alloc] init];
    [_imagePicker setDelegate:self];
    [_imagePicker setAllowsEditing:NO];
    
    return _imagePicker;
}

- (void)showWithCamera {
    //isFromCamera_ = YES;
    BOOL isCameraSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if (isCameraSupport) {
        [[self imagePicker] setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self showImagePicker];
    }
}

- (void)showWithPhotoLibrary {

    [[self imagePicker] setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self showImagePicker];
}

- (void)showImagePicker {
    [self presentViewController:_imagePicker animated:YES completion:^{
    }];
}

- (void)saveImageAvatar:(NSData *)data{
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"avatarimage"];
}

- (void)textFiledEditChanged:(NSNotification *)obj{

    UITextField *textField = (UITextField *)obj.object;
    
    if (_textName == textField) {
        
        NSString *toBeString = textField.text;
        NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
        if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
            UITextRange *selectedRange = [textField markedTextRange];
            //获取高亮部分
            UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if (toBeString.length > 16) {
                    textField.text = [toBeString substringToIndex:16];
                }
            }
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
            else{
                
            }
        }
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        else{
            if (toBeString.length > 16) {
                textField.text = [toBeString substringToIndex:16];
            }
        }
        //设置到数据源
        userName = toBeString;
    }
    
}


#pragma mark - UITextField Delegate
- (void)resignTextFieldFirstResponder:(UITextField *)tf{
    [tf resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self resignTextFieldFirstResponder:textField];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (_textName == textField) {
        
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (toBeString.length > 16 && range.length!=1){
            textField.text = [toBeString substringToIndex:16];
            return NO;
            
        }
        return YES;

    } else {
        
        return YES;
    }
    
}


- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;  
    }  
    
    // And now we just create a new UIImage from the drawing context  
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);  
    UIImage *img = [UIImage imageWithCGImage:cgimg];  
    CGContextRelease(ctx);  
    CGImageRelease(cgimg);  
    return img;  
}

#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage *newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.headImg.image = [self fixOrientation:newImage];
        //64位编码
        NSData *tempData = UIImageJPEGRepresentation(self.headImg.image, 0.1);
        image64Bit = [NSString stringWithFormat:@"data:image/jpg;base64,%@" , [tempData base64EncodedStringWithOptions:0]];
        
    }];
}

#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"userinfocell"];
    //名称
    UILabel *titleLabel = [cell viewWithTag:101];
    //详情
    UITextField *detailText = [cell viewWithTag:102];
    //头像图标
    UIImageView *headImageView = [cell viewWithTag:103];
    //箭头
    UIImageView *rightImageView = [cell viewWithTag:104];
    
    titleLabel.text = self.array[indexPath.row];
    
    UIView * topLineView = [cell viewWithTag:111];
    UIView * longLineView = [cell viewWithTag:113];
    [topLineView setHidden:YES];
    [longLineView setHidden:YES];
    //设置cell
    switch (indexPath.row) {
        case 0:
        {
            detailText.hidden = YES;
            detailText.userInteractionEnabled = NO;
            headImageView.hidden = NO;
            rightImageView.hidden = NO;
            //默认头像
            UIImage *defaultImag = [userGender isEqualToString:@"Female"]  ? [UIImage imageNamed:@"icon_woman_122*122"] : [UIImage imageNamed:@"icon_man_122*122"];
            //头像
            self.headImg = headImageView;
            if (uploadImageUrl) {
                [self.headImg setImageWithURL:[NSURL URLWithString:_user.avatar] placeholderImage:defaultImag];
            }
            
            //圆角
            [self roundImageView:self.headImg];
            [topLineView setHidden:NO];
        }
            break;
        case 1:
        {
            detailText.hidden = NO;
            detailText.userInteractionEnabled = YES;
            headImageView.hidden = YES;
            rightImageView.hidden = YES;
            
            [detailText updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.right).offset(-24);
            }];
            detailText.placeholder = @"请输入用户名";
            detailText.returnKeyType = UIReturnKeyDone;
            //用户名
            self.textName = detailText;
            self.textName.delegate = self;
            if (userName) {
                self.textName.text = userName;
            }
            
        }
            break;
        case 2:
        {
            detailText.hidden = NO;
            detailText.userInteractionEnabled = NO;
            headImageView.hidden = YES;
            rightImageView.hidden = YES;
            
            [detailText updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.right).offset(-24);
            }];
            detailText.placeholder = @"请输入手机号";
            
            //电话号码
            if (userPhone) {
                detailText.text = userPhone;
            }
        }
            break;
        case 3:
        {
            detailText.hidden = NO;
            detailText.userInteractionEnabled = NO;
            headImageView.hidden = YES;
            rightImageView.hidden = NO;
            
            [detailText updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.right).offset(-47);
            }];
            detailText.placeholder = @"请选择性别";
            //性别
            if ([userGender  isEqual: @"Male"]) {
                detailText.text = @"男";
            }
            else if ([userGender  isEqual: @"Female"]){
                detailText.text = @"女";
            }
            [longLineView setHidden:NO];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            [self showSelectView:SelectType_Image];
            
            [self.textName resignFirstResponder];
        }
            break;
        case 1:
        {
            [_textName becomeFirstResponder];
        }
            break;
        case 3:
        {
            UITableViewCell *tempCell = [tableView cellForRowAtIndexPath:indexPath];
            //性别
            UITextField *detailText = [tempCell viewWithTag:102];
            
            [SelectPickerView showInView:self.view items:@[@"男",@"女"] selectIndex: -1 completion:^(NSInteger index) {
                switch (index) {
                    case 0:
                        userGender = @"Male";
                        detailText.text = @"男";
                        break;
                    case 1:
                        userGender = @"Female";
                        detailText.text = @"女";
                        break;
                    default:
                        break;
                }
            }];
            
            [self.textName resignFirstResponder];
        }
            break;
            
        default:
            break;
    }
    
    
}

#pragma mark- datepicker delegate
- (void)pickerViewCancel
{
    [self.datePicker cancelPicker:self.view];
}

- (void)pickerViewOK:(NSString*)date
{
    [self.datePicker cancelPicker:self.view];
    
    
    [self.tableView reloadData];
    
}

#pragma mark- selectview delegate
- (void)selectViewCancel
{
    [self.selectView cancelSelect:self.view];
}

- (void)selectView:(int)index
{
    [self.selectView cancelSelect:self.view];
    
    if (curSelType == SelectType_Sex) {
        
    }else if (curSelType == SelectType_Image) {
        
        if (index == 0) {
            
            [self showWithCamera];
            
        }else if (index == 1) {
            
            [self showWithPhotoLibrary];
        }
        
    }
    
    [self.tableView reloadData];
}

- (void)requestUserInfomation:(NSDictionary *)info{
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_SetUserInfo params:^(NetParams *params) {
        params.method = EMRequstMethod_PUT;
        params.data = info;
    }];
}

#pragma mark- http request handler

-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    [self stopWait];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    if (resultData.type == EmRequestType_EditAccount) {
        [self showTip:@"更改成功" WithType:FNTipTypeSuccess];
        
        User *user = [User mj_objectWithKeyValues:resultData.data];//[[User alloc]initWithDictionary:member];
        self.user = user;
        //更新缓存数据
        [UserPreferInstance setUserInfo:self.user];
    }
    
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}
@end
