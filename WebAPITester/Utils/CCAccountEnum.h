//
//  CCAccountEnum.h
//  CCFanMi
//
//  Created by cloudtech on 10/28/16.
//  Copyright © 2016 cloundCall. All rights reserved.
//

#ifndef CCAccountEnum_h
#define CCAccountEnum_h

typedef void(^CCModelResultBlock)(NSError *error, id modelInfo);
typedef void(^CCBooleanResultBlock)(NSError *error, BOOL success);
typedef void(^CCArrayResultBlock)(NSError *error, NSArray *results);
typedef void(^CCDictionaryResultBlock)(NSError *error, NSDictionary *result);

typedef NS_ENUM(NSInteger, CCPINWay) {
    CCPINWayByMessage = 0,   //短信类型
    CCPINWayByVoice = 1,  //电话语音
    
};

typedef NS_ENUM(NSInteger, CCReason) {
    CCReasonSignUp = 0,    //用于注册
    CCReasonReset = 1,     //用于重置密码
    CCReasonDoctorLogin = 2,
    CCReasonBindTel = 3,
};


#endif /* CCAccountEnum_h */
