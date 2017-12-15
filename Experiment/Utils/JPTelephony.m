//
//  JPTelephony.m
//  Experiment
//
//  Created by King on 2017/12/12.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import "JPTelephony.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

extern NSString *CTSettingCopyMyPhoneNumber(void);

@implementation JPTelephony

- (BOOL)checkIsUnicom
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *carrierName = carrier.carrierName;
    NSString *mobileCountryCode = carrier.mobileCountryCode;
    NSString *mobileNetworkCode = carrier.mobileNetworkCode;
    if (!mobileNetworkCode) {
        return NO;
    }

    if ([mobileCountryCode intValue] == 460) { //国内
        return [carrierName rangeOfString:@"联通"].length>0 || [mobileNetworkCode isEqualToString:@"01"] || [mobileNetworkCode isEqualToString:@"06"];
    }
    return [self statusBarCheckIsUnicom];
}

- (BOOL)statusBarCheckIsUnicom
{
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    UIView *serviceView = nil;
    Class serviceClass = NSClassFromString([NSString stringWithFormat:@"UIStat%@Serv%@%@", @"usBar", @"ice", @"ItemView"]);
    for (UIView *subview in subviews) {
        if([subview isKindOfClass:[serviceClass class]]) {
            serviceView = subview;
            break;
        }
    }
    if (serviceView) {
        NSString *carrierName = [serviceView valueForKey:[@"service" stringByAppendingString:@"String"]];
        return [carrierName rangeOfString:@"联通"].length>0;
    } else {
        return NO;
    }
}

@end
