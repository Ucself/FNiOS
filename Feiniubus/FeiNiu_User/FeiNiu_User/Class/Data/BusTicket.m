//
//  BusTicket.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/10.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "BusTicket.h"
#import "QRCode.h"

@implementation BusTicket
@synthesize qrImage = _qrImage;

- (id)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        self.ticketId = dictionary[@"id"];
        self.orderId = dictionary[@"orderId"];
        self.serialNumber = dictionary[@"serialNumber"];
        self.state = [dictionary[@"state"] integerValue];
        self.type = [dictionary[@"type"] integerValue];
    }
    return self;
}

- (UIImage *)qrImage{
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
