//
//  UserWebviewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/11/11.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"

@interface UserWebviewController : UserBaseUIViewController<UIWebViewDelegate>{
    UIWebView   *_webView;
}
@property (nonatomic, strong) NSString *url;

- (id)initWithUrl:(NSString *)url;
@end
