//
//  AddressBookHelp.m
//  FeiNiu_User
//
//  Created by CYJ on 16/6/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "AddressBookHelp.h"

#import <Contacts/CNContact.h>
#import <ContactsUI/CNContactPickerViewController.h>
#import <ContactsUI/CNContactViewController.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBookUI/ABPersonViewController.h>

@interface AddressBookHelp() <ABPeoplePickerNavigationControllerDelegate, CNContactPickerDelegate>

@end

@implementation AddressBookHelp

- (instancetype)initWithAddressDelegate:(id) addressDelegate
{
    if (self = [super init]) {
        self.addressDelegate = addressDelegate;
    }
    return self;
}

- (void)showAddressBookController
{
    
    if (ISIOS9BEFORE) {
        ABPeoplePickerNavigationController *peopleVc = [[ABPeoplePickerNavigationController alloc] init];
        peopleVc.peoplePickerDelegate = self;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
            peopleVc.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
        }
        
        [self.addressDelegate presentViewController:peopleVc animated:YES completion:nil];
    }
    else {
        CNContactPickerViewController * contactVc = [CNContactPickerViewController new];
        contactVc.delegate = self;
        contactVc.displayedPropertyKeys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey];
        [self.addressDelegate presentViewController:contactVc animated:YES completion:nil];
    }
    
}


#pragma mark- ABPeople Delegate
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
        _clickComplete(phoneNO,nil);
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    }else{
        _clickComplete(nil,@"请选择正确的手机号！");
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
        _clickComplete(phoneNO,nil);
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    }else{
        _clickComplete(phoneNO,@"请选择正确的手机号！");
    }
    
    if(phonecf) CFRelease(phonecf);
    return YES;
}

#pragma mark- CNContact Delegate
/*
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    
    NSLog(@"name:%@%@",contact.familyName,contact.givenName);
    CNLabeledValue * labValue = [contact.phoneNumbers lastObject];
    NSLog(@"phone:%@",[labValue.value stringValue]);
    
//    CNContactViewController * con = [CNContactViewController viewControllerForContact:contact];
//    [self.addressDelegate presentViewController:con animated:YES completion:nil];
    
//    [picker dismissViewControllerAnimated:YES completion:nil];
}
 */

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    NSString *phone = [contactProperty.value stringValue];
    if (phone == nil || phone.length == 0) {
        DBG_MSG(@"The phone number is nil!!!");
        return;
    }
    
    //+86
    if ([phone hasPrefix:@"+"]) {
        if (phone.length > 5) {
            phone = [phone substringFromIndex:3];
        }
    }
    //86
    if ([phone hasPrefix:@"86"]) {
        if (phone.length > 5) {
            phone = [phone substringFromIndex:2];
        }
    }
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];   //去-
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];   //去空格
    if (phone && [BCBaseObject isMobileNumber:phone]) {
        _clickComplete(phone,nil);
    }else{
        _clickComplete(phone,@"请选择正确的手机号！");
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
