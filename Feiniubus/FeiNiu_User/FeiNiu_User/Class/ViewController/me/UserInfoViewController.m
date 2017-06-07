//
//  UserInfoViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/13.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "UserInfoViewController.h"
#import <FNUIView/DatePickerView.h>
#import "UserSelectView.h"
#import "UserBaseUIViewController.h"
#import <FNNetInterface/UIImageView+AFNetworking.h>

#define KImageSize    55
#define kTextNameTag  505
#define kTextEmailTag 506

@interface UserInfoViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate>
{
    NSString *birthday;       //生日
    int sexIndex;             //性别      0:男  1:女   -1:无
    int inputType;            //输入类型   0:姓名   1:邮箱   -1:无
    
    SelectType curSelType;    //当前选择类型
    BOOL _userInfoSwitch;
    
    NSString* uploadImageUrl;

}
@property (nonatomic, strong) NSArray *array;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImageView *img;     //用户头像
@property (nonatomic, strong) UITextField *textName;
@property (nonatomic, strong) UITextField *textEmail;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) User *user;


//选择器
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
        
}

- (void)initProperty{
    
    
    self.user = [[UserPreferences sharedInstance] getUserInfo];
    
    self.array = @[@"头像", @"性别", @"姓名", @"生日", @"电子邮箱"];
    
    uploadImageUrl = self.user.avatar;

    birthday = [self.user.birthday substringToIndex:MIN(11, self.user.birthday.length)];
    
    sexIndex = [self.user.gender intValue];
    
    self.img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_center_head_2"]];
    self.img.frame = CGRectMake(0, 0, KImageSize, KImageSize);
    
    self.img.image = [self fixOrientation:self.img.image];
    
    [self roundImageView:self.img];
    
    _userInfoSwitch = NO;
    
    [self initTextName];
    [self initTextEmail];
}

- (void)initTextName{
    
    _textName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    _textName.tag = kTextNameTag;
    _textName.delegate = self;
    _textName.returnKeyType = UIReturnKeyDone;
    _textName.textAlignment = NSTextAlignmentRight;
    _textName.font = [UIFont systemFontOfSize:15];
    _textName.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:@"请输入姓名" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    
    if ([self.user.name length] != 0 && ![[self.user.name substringToIndex:2]isEqualToString:@"13"]) {
        _textName.text = self.user.name;
    }
    
}

- (void)initTextEmail{
    
    _textEmail = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    _textEmail.tag = kTextEmailTag;
    _textEmail.delegate = self;
    _textEmail.returnKeyType = UIReturnKeyDone;
    _textEmail.keyboardType = UIKeyboardTypeEmailAddress;
    _textEmail.textAlignment = NSTextAlignmentRight;
    _textEmail.font = [UIFont systemFontOfSize:15];
    _textEmail.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:@"请输入邮箱" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    if ([self.user.email length] != 0) {
        _textEmail.text = self.user.email;
    }
}

- (void)modifyUserInfo{
    
    _userInfoSwitch = YES;
    
    NSDictionary *params = @{@"name":self.textName.text,
                             @"facePath":uploadImageUrl,
                             @"sex":@(sexIndex),
                             @"birthday":birthday,
                             @"email":self.textEmail.text};
    
    [self requestUserInfomation:params];
}

//-(UITextField*)textName
//{
//    if (!_textName) {
//        _textName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
//        _textName.delegate = self;
//        _textName.returnKeyType = UIReturnKeyDone;
//        _textName.textAlignment = NSTextAlignmentRight;
//        _textName.font = [UIFont systemFontOfSize:15];
//        _textName.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:@"请输入姓名" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
//    }
//    
//    return _textName;
//}

//-(UITextField*)textEmail
//{
//    if (!_textEmail) {
//        _textEmail = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
//        _textEmail.delegate = self;
//        _textEmail.returnKeyType = UIReturnKeyDone;
//        _textEmail.keyboardType = UIKeyboardTypeEmailAddress;
//        _textEmail.textAlignment = NSTextAlignmentRight;
//        _textEmail.font = [UIFont systemFontOfSize:15];
//        _textEmail.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:@"请输入邮箱" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
//        if (self.user.email) {
//            _textEmail.text = self.user.email;
//        }
//    }
//    return _textEmail;
//}

- (void)roundImageView:(UIImageView*)imageView
{
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 3.0f;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;

//    imageView.layer.shouldRasterize = YES;
    imageView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
-(void)showDatePickerView
{
    if (!self.datePicker) {
        self.datePicker = [[DatePickerView alloc] init];
        self.datePicker.delegate = self;
    }
    
    [self.datePicker showInView:self.view];
}

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
                if (toBeString.length > 8) {
                    textField.text = [toBeString substringToIndex:8];
                }
            }
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
            else{
                
            }
        }
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        else{
            if (toBeString.length > 8) {
                textField.text = [toBeString substringToIndex:8];
            }
        }

    }
}

//email formatter
-(BOOL)isValidateEmail:(NSString *)email{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    
    return [emailTest evaluateWithObject:email];
    
}

#pragma mark - UITextField Delegate
- (void)resignTextFieldFirstResponder:(UITextField *)tf{
    [tf resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectOffset(self.view.bounds, 0, 64) ;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self resignTextFieldFirstResponder:textField];
    return YES;
}



- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    CGRect rect = [textField.superview convertRect:textField.frame toView:self.view];
    CGFloat bottom = CGRectGetMaxY(rect);
    CGFloat delta = self.view.frame.size.height - bottom - 290;
    if (delta < 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectOffset(self.view.bounds, 0, delta + 64);
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (_textName == textField) {
        
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (toBeString.length > 8 && range.length!=1){
            textField.text = [toBeString substringToIndex:8];
            return NO;
            
        }
        return YES;

    }else{
        
        return YES;
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self resignTextFieldFirstResponder:textField];
    if (textField.tag == kTextEmailTag) {
        
        if ([self isValidateEmail:textField.text] == YES) {
            
            [self modifyUserInfo];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱格式输入错误，请重新输入" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        
    }else{
        
        [self modifyUserInfo];
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
        
        self.img.image = [self fixOrientation:newImage];
        
        [self startWait];
        
        NSString *url = [NSString stringWithFormat:@"%@Resources",KServerAddr];

        [NetManagerInstance uploadImage:url img:[self fixOrientation:newImage] body:@{@"Type":[NSString stringWithFormat:@"%d",ImageTypeCommon]} suceeseBlock:^(NSString *msg) {
            [self stopWait];

            NSDictionary* dic = [JsonUtils jsonToDcit:msg];
            if ([[dic objectForKey:@"code"] intValue] == 0) {
                uploadImageUrl = [dic objectForKey:@"url"];
                [self modifyUserInfo];
            }else{
                [self showTipsView:[dic objectForKey:@"message"]];
            }
        } failedBlock:^(NSError *error) {
            [self showTipsView:@"上传图片失败"];
            [self stopWait];
        }];
        
        
//        NSData *date = UIImagePNGRepresentation(newImage);
//        
//        [self saveImageAvatar:date];//保存头像image
    }];
}

#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 70;
    }
    
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"userinfocell"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.text = @"";
    cell.textLabel.text = self.array[indexPath.row];
    
    if (indexPath.row == 0) {
        
//        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"avatarimage"]) {
//            self.img.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] valueForKey:@"avatarimage"]];
//        }
        
        if (_user.avatar) {
            [self.img setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,_user.avatar]] placeholderImage:[UIImage imageNamed:@"my_center_head_2"]];
        }        
        [cell.contentView addSubview:self.img];
        
        [self.img makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(KImageSize);
            make.height.equalTo(KImageSize);
            make.centerY.equalTo(cell.contentView);
            make.right.equalTo(cell.contentView).offset(-10);
        }];
        
    }else if (indexPath.row == 1) {
        
        if (sexIndex == 1) {
            
            cell.detailTextLabel.text = @"男";
            
        }else if (sexIndex == 2) {
            
            cell.detailTextLabel.text = @"女";
            
        }else {
            
            cell.detailTextLabel.text = @"请选择性别";
        }
        cell.detailTextLabel.textColor = [UIColor blackColor];

    }else if (indexPath.row == 2) {
        
            [cell.contentView addSubview:self.textName];
        
            [_textName makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(cell.contentView.right).offset(-15);
                make.centerY.equalTo(cell.contentView);
                make.width.equalTo(200);
                make.height.equalTo(30);
            }];

    }else if (indexPath.row == 3) {
        
        cell.detailTextLabel.text = birthday;
        cell.detailTextLabel.textColor = [UIColor blackColor];
        
    }else if (indexPath.row == 4) {
        
        [cell.contentView addSubview:self.textEmail];
        [_textEmail makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell.contentView.right).offset(-15);
            make.centerY.equalTo(cell.contentView);
            make.width.equalTo(200);
            make.height.equalTo(30);
        }];
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
        }
            break;
        case 1:
        {
            [self showSelectView:SelectType_Sex];
        }
            break;
        case 2:
        {
            

//            inputType = 0;
//            [self.tableView reloadData];
        }
            break;
        case 3:
        {
            [self showDatePickerView];
        }
            break;
        case 4:
        {
//            inputType = 1;
//            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
    
    [self.textEmail resignFirstResponder];
    [self.textName resignFirstResponder];
}

#pragma mark- datepicker delegate
- (void)pickerViewCancel
{
    [self.datePicker cancelPicker:self.view];
}

- (void)pickerViewOK:(NSString*)date
{
    [self.datePicker cancelPicker:self.view];
    
    birthday = date;
    [self.tableView reloadData];
    
    [self modifyUserInfo];
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
        
        sexIndex = index + 1;
        
        [self modifyUserInfo];

//        [self requestUserInfomation:@{@"sex":@(sexIndex)}];//提交用户信息
        
    }else if (curSelType == SelectType_Image) {
        
        if (index == 0) {
            
            [self showWithCamera];
            
        }else if (index == 1) {
            
            [self showWithPhotoLibrary];
        }
        
//        [self modifyUserInfo];
    }
    
    [self.tableView reloadData];
    
    
}

- (void)requestUserInfomation:(NSDictionary *)params{
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_SetUserInfo params:^(NetParams *params) {
        params.method = EMRequstMethod_PUT;
        params.data = params;
    }];
}

#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification
{
    [self stopWait];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    if (type == FNUserRequestType_SetUserInfo) {
        if (_userInfoSwitch == YES) {
            _userInfoSwitch = NO;
            
            NSInteger type = resultData.requestType;
            //修改用户信息是否成功
            if (type == FNUserRequestType_SetUserInfo) {
                [self showTipsView:@"修改信息成功"];

                User* user = [[UserPreferences sharedInstance] getUserInfo];
                user.avatar = uploadImageUrl;
                user.gender = @(sexIndex);
                user.birthday = birthday;
                user.email = self.textEmail.text;
                user.name = self.textName.text;

                [[UserPreferences sharedInstance] setUserInfo:user];
            }
        }
    }
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
    
}
@end
