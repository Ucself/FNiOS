//
//  Ticket.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/24.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "Ticket.h"
#import "QRCode.h"

@implementation Ticket
@synthesize qrImage = _qrImage;

-(UIImage *)qrImage
{
    if (!_qrImage) {
        _qrImage = [QRCode generateQRImageForString:self.serialNumber];
    }
    return _qrImage;
}

- (void)qrImageStartBlock:(void (^)(void))start complete:(void (^)(UIImage *))completion{
    if (_qrImage) {
        if (completion) {
            completion(_qrImage);
        }
    }else{
        if (start) {
            start();
        }
        dispatch_async(dispatch_queue_create("GenerateQRImage", DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
            _qrImage = [QRCode generateQRImageForString:self.serialNumber];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(_qrImage);
                }
            });
        });
        
    }
}
@end


