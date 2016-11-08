//
//  CCServerDefine.h
//  CCWeLove
//
//  Created by cloudtech on 15/8/19.
//  Copyright (c) 2015年 CloudTel. All rights reserved.
//

#ifndef CCWeLove_CCServerDefine_h
#define CCWeLove_CCServerDefine_h

#define kNotificationSetToken       @"kNotificationSetToken"

#define kResponseResult             @"result"
#define kResponseText               @"text"
#define kResponseDeleteList         @"deletelist"
#define kResponseMoments            @"messages"
#define kResponseResultSuccess      @"success"
#define kResponseResultFailed       @"failed"
#define kResponseErrorCode          @"errno"
#define kResponseobj                @"obj"
#define kResponseTimeObj            @"timeobj"

#define kHttpHeader_OS_VERSION      @"osversion"
#define kHttpHeader_PROTOCOL        @"protocol"
#define kHttpHeader_MARKET_ID       @"marketid"
#define kHttpHeader_DEVICE_ID       @"deviceid"
#define kHttpHeader_DEVICE_TYPE     @"devicetype"
#define kHttpHeader_DEVICE_NAME     @"devicename"
#define kHttpHeader_DEVICE_MAC      @"mac"
#define kHttpHeader_APP_KEY         @"appkey"
#define kHttpHeader_APP_TOKEN       @"token"
#define kHttpHeader_APP_VERSION     @"appversion"
#define kHttpHeader_LANGUAGE        @"language"

#define k_OS_VERSION                [[UIDevice currentDevice] systemVersion]
#define k_PROTOCOL                  @"1"
#define k_MARKET_ID                 @"101" //appStore:100, officeSite:101, 91:102
#define k_DEVICE_TYPE               @"IOS"
#define k_DEVICE_MODEL              [[UIDevice currentDevice] model]
#define k_DEVICE_MAC                @"02:00:00:00:00:00"
#define k_APP_KEY                   @"PinkmeBill"
#define k_APP_TOKEN                 @"token"
#define k_APP_VERSION               [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#endif
