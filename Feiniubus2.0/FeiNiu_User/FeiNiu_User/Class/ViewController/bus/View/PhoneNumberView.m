//
//  PhoneNumberView.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/16.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "PhoneNumberView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBookUI/ABPersonViewController.h>

@interface PhoneNumberView()<UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UIView *mainView;
    __weak IBOutlet NSLayoutConstraint *mainViewBottom;
    __weak IBOutlet UITextField *phoneTextField;
}

@property(nonatomic,retain)UIView *parentView;

@end

@implementation PhoneNumberView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self = [[NSBundle mainBundle] loadNibNamed:@"PhoneNumberView" owner:self options:nil][0];
        self.frame = frame;
        self.backgroundColor = UITranslucentBKColor;
        phoneTextField.delegate = self;
        
    }
    return self;
}

- (void)showInView:(UIView *)view
{
//    _parentView = view;
    
    [view addSubview:self];
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = 0;
        [view layoutIfNeeded];
        [phoneTextField becomeFirstResponder];
    }];
}


- (IBAction)cancleAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = - self.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)clickCompleteAction:(UIButton *)sender
{
    if (_clickComplete) {
        _clickComplete(phoneTextField.text);
        [self cancleAction:nil];
    }
}

//通讯录查找
- (IBAction)clickAddressBookAction:(UIButton *)sender
{
    [phoneTextField resignFirstResponder];
    ABPeoplePickerNavigationController *nav = [[ABPeoplePickerNavigationController alloc] init];
    nav.peoplePickerDelegate = self;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        nav.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
    }
    [self.addressDelegate presentViewController:nav animated:YES completion:nil];
}

//取消选择
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

//IOS8以上返回
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
   
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    CFStringRef phonecf = ABMultiValueCopyValueAtIndex(phone, index);;
    NSString *phoneNO = (__bridge NSString*)phonecf;
    if(phoneNO) CFRelease(phone);
    
    //+86
    if ([phoneNO hasPrefix:@"+"]) {
        if (phoneNO.length > 5) {
            phoneNO = [phoneNO substringFromIndex:3];
        }
    }
    //86
    if ([phoneNO hasPrefix:@"86"]) {
        if (phoneNO.length > 5) {
            phoneNO = [phoneNO substringFromIndex:2];
        }
    }
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];   //去-
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];   //去空格
    if (phoneNO && [BCBaseObject isMobileNumber:phoneNO]) {
        phoneTextField.text = phoneNO;
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    }
    
    if(phonecf) CFRelease(phonecf);
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.displayedPerson = person;
    [peoplePicker pushViewController:personViewController animated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

//IOS 7 返回
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    CFStringRef phonecf = ABMultiValueCopyValueAtIndex(phone, index);;
    NSString *phoneNO = (__bridge NSString*)phonecf;
    if(phoneNO) CFRelease(phone);
    
    //+86
    if ([phoneNO hasPrefix:@"+"]) {
        if (phoneNO.length > 5) {
            phoneNO = [phoneNO substringFromIndex:3];
        }
    }
    //86
    if ([phoneNO hasPrefix:@"86"]) {
        if (phoneNO.length > 5) {
            phoneNO = [phoneNO substringFromIndex:2];
        }
    }
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];   //去-
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];   //去空格
    if (phoneNO && [BCBaseObject isMobileNumber:phoneNO]) {
        phoneTextField.text = phoneNO;
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    }
    
    if(phonecf) CFRelease(phonecf);
    return YES;
}

//灰色背景点击
- (IBAction)clickTapGrayView:(UITapGestureRecognizer *)sender
{
    [phoneTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        mainViewBottom.constant = 216;
        [self layoutIfNeeded];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        mainViewBottom.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
