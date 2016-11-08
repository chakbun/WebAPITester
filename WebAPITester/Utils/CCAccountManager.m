//
//  CCAccountManager.m
//  CCWeLove
//
//  Created by cloudtech on 15/8/18.
//  Copyright (c) 2015年 CloudTel. All rights reserved.
//

#import "CCAccountManager.h"
#import "encryption.h"
#import "CCServerDefine.h"
#import "OpenUDID.h"
#import "CCAccountAPI.h"

#define NO_ENCRYPITON

@interface CCAccountManager ()


@end

@implementation CCAccountManager

+ (instancetype)shareManager {
    static CCAccountManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager =[[CCAccountManager alloc] init];
    });
    return shareManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = kTimeoutInterval;
        
        NSString *openUdid = [OpenUDID value];
        
        [self.requestSerializer setValue:openUdid forHTTPHeaderField:kHttpHeader_DEVICE_ID];
        [self.requestSerializer setValue:k_APP_KEY forHTTPHeaderField:kHttpHeader_APP_KEY];
        [self.requestSerializer setValue:k_DEVICE_TYPE forHTTPHeaderField:kHttpHeader_DEVICE_TYPE];
        [self.requestSerializer setValue:k_DEVICE_MODEL forHTTPHeaderField:kHttpHeader_DEVICE_NAME];
        [self.requestSerializer setValue:k_DEVICE_MAC forHTTPHeaderField:kHttpHeader_DEVICE_MAC];
        [self.requestSerializer setValue:k_MARKET_ID forHTTPHeaderField:kHttpHeader_MARKET_ID];
        [self.requestSerializer setValue:k_OS_VERSION forHTTPHeaderField:kHttpHeader_OS_VERSION];
        [self.requestSerializer setValue:k_APP_VERSION forHTTPHeaderField:kHttpHeader_APP_VERSION];
        [self.requestSerializer setValue:k_PROTOCOL forHTTPHeaderField:kHttpHeader_PROTOCOL];
        [self.requestSerializer setValue:k_APP_TOKEN forHTTPHeaderField:kHttpHeader_APP_TOKEN];
        
        NSString *currentLanguage = [NSLocale preferredLanguages][0];
        if ([currentLanguage rangeOfString:@"zh-Hans"].length > 0) {
            [self.requestSerializer setValue:@"CN" forHTTPHeaderField:kHttpHeader_LANGUAGE];
        }else{
            [self.requestSerializer setValue:@"EN" forHTTPHeaderField:kHttpHeader_LANGUAGE];
        }
        
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        responseSerializer.removesKeysWithNullValues = YES;
        self.responseSerializer = responseSerializer;
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html",@"application/json",@"text/json",@"text/javascript",nil];
        
        self.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        self.securityPolicy.allowInvalidCertificates = YES;
        self.securityPolicy.validatesDomainName = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAppTokenWithNotificaiton:) name:kNotificationSetToken object:nil];
    }
    
    return self;
}

#pragma mark - Notification Method

- (void)setAppTokenWithNotificaiton:(NSNotification *)notify {
    NSString *deviceToken = notify.object;
    [self.requestSerializer setValue:deviceToken forHTTPHeaderField:@"token"]; // token
}


#pragma mark - 用户接口

- (void)requestPIN4Phone:(NSString *)phone way:(CCPINWay)way reason:(CCReason)reason completed:(CCBooleanResultBlock)completed {

    __weak __typeof(self) weakSelf = self;
    
    NSString *verifyType = (way == CCPINWayByMessage)?@"sms":@"voice";
    
    NSDictionary *params = @{@"telnumber":phone?:@"",
                             @"reason":[weakSelf stringWithCCReason:reason],
                             @"type":verifyType,
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlRequestPIN4Phone]] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"doctorsPwd"] boolValue]) {
            NSString *message = @"请在登录界面输入手机号、密码完成登录。";
            completed([NSError errorWithDomain:message code:-1 userInfo:responseObject], NO);
        }else {
            if ([weakSelf requireSuccess:responseObject]) {
                completed(nil, YES);
            } else {
                completed([weakSelf parseResponseError:responseObject], NO);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, NO);
    }];
}

- (void)verifyPIN4Phone:(NSString *)phone pin:(NSString *)pin reason:(CCReason)reason completed:(CCBooleanResultBlock)completed {
    
    //NSLog(@"============ verifySecurityCode4User ============");
    
    __weak __typeof(self) weakSelf = self;
    
    NSDictionary *params = @{@"telnumber":phone?:@"",
                             @"reason":(reason == CCReasonSignUp)?@"register":@"renew",
                             @"authcode":pin?:@"",
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlVerifyPIN4Phone]] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, YES);
        }else {
            completed([weakSelf parseResponseError:responseObject], NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, NO);
    }];
}

- (void)signUpWithPhone:(NSString *)phone password:(NSString *)password PIN:(NSString *)PIN completed:(CCDictionaryResultBlock)completed {

    //NSLog(@"============ signUpWithPhone ============");
    
    __weak __typeof(self) weakSelf = self;
    
    NSDictionary *params = @{@"telnumber":phone?:@"",
                             @"pwd":password?:@"",
                             @"code":PIN?:@"",
                             @"appkey":k_APP_KEY,
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlSignUp]] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

- (void)signInWithPhone:(NSString *)phone password:(NSString *)password completed:(CCModelResultBlock)completed {
    
    //NSLog(@"============ loginWithPhone ============");
    
    __weak __typeof(self) weakSelf = self;
    
    NSString *encryptMsg = encryptTo32BitMd5String(encryptTo32BitMd5String(password?:@""));
    NSDictionary *params = @{@"telnumber":phone?:@"",
                             @"pwd":encryptMsg
                             };
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlSignIn]] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

- (void)signInWithWeChatID:(NSString *)unionID completed:(void(^)(NSError *loginErr, NSDictionary *loginInfo))completed {

    __weak __typeof(self) weakSelf = self;

    [self postCCParams:@{@"unionid":unionID?:@""} toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlLoginByWeChat]] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, nil);
    }];
}

- (void)loadUserInfoWithValue:(id)value valueType:(NSInteger)type completed:(CCModelResultBlock)completed {

    //NSLog(@"============ loadUserInfoWithPhone ============");
    
    __weak __typeof(self) weakSelf = self;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (type == 0) {
        params[@"telnumber"] = value;
    }else {
        params[@"user_id"] = value;
    }
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingSocial:kUrlLoadUserInfo]] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([weakSelf requireSuccess:responseObject]) {
            //NSLog(@"============ loadUserInfo : %@ ============",responseObject);

            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, nil);
    }];
}

- (void)updatePassword:(NSString *)newPSW fromOld:(NSString *)oldPSW forPhone:(NSString *)phone completed:(CCBooleanResultBlock)completed {

    //NSLog(@"============ reset password ============");
    
    __weak __typeof(self) weakSelf = self;
    NSDictionary *params = @{@"telnumber":phone?:@"",
                             @"curpwd":oldPSW?:@"",
                             @"newpwd":newPSW?:@"",
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlChangePassword]] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, YES);
        }else {
            completed([weakSelf parseResponseError:responseObject], NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, NO);
    }];
}

- (void)resetPassword:(NSString *)password forPhone:(NSString *)phone completed:(CCBooleanResultBlock)completed {
    
    //NSLog(@"============ resetPassword ============");
    
    __weak __typeof(self) weakSelf = self;
    
    NSDictionary *params = @{@"telnumber":phone?:@"",
                             @"pwd":password?:@"",
                             @"reason":@"renew",
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlResetPassword]] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, YES);
        }else {
            completed([weakSelf parseResponseError:responseObject], NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, NO);
    }];
}

#warning social
- (void)uploadUserIcon:(UIImage *)image phone:(NSString *)phone completed:(void(^)(NSError *error, NSString *iconURL, NSString *thumbIconURL))completed {
    
    //NSLog(@"============ uploadUserIcon ============");
    
    __weak __typeof(self) weakSelf = self;
    
    [self POST:[self urlWithHttp4Auth:[self methodAppendingSocial:kUrlUploadUserImage]] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDictionary *params = @{@"telnumber":phone?:@"",
                                 @"filename	":phone?:@"",
                                 @"http_headers":weakSelf.requestSerializer.HTTPRequestHeaders
                                 };
        
        NSData *data = transferDictionaryToData(params);
        
        if (data) {
            data = encryptData(data);
            [formData appendPartWithFileData:data name:@"param" fileName:@"param.file" mimeType:@"application/octet-stream"];
        }
        
        NSData *imageData;
        if (image) {
            imageData = UIImageJPEGRepresentation(image, 0.1);
        }
        
        [formData appendPartWithFileData:imageData name:@"icon" fileName:@"phone.png" mimeType:@"application/octet-stream"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([weakSelf requireSuccess:responseObject]) {
            NSString *iconURL = responseObject[@"iconurl"]; //  不需要加入ip端口
            NSString *thumbIconURL = responseObject[@"smalliconurl"];
            completed(nil, iconURL,thumbIconURL);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil, nil);
    }];
}

- (void)loadUserIconURLWithPhone:(NSString *)phone completed:(void(^)(NSError *error, NSString *iconURL, NSString *thumbIconURL))completed {
    
    //NSLog(@"============ loadUserIconURL ============");
    
    __weak __typeof(self) weakSelf = self;
    
    NSDictionary *params = @{@"user_num":phone?:@"",
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingSocial:kUrlLoadUserImageUrl]] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        if ([weakSelf requireSuccess:responseObject]) {
            NSDictionary *model = responseObject[@"iconList"][0];
            NSString *iconURL = [CC_BASE_HTTP_IP stringByAppendingString:model[@"iconurl"]]; //  需要加入ip端口
            NSString *thumbIconURL = [CC_BASE_HTTP_IP stringByAppendingString:model[@"smalliconurl"]];
            completed(nil, iconURL,thumbIconURL);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil,nil);
    }];
}

- (void)updateUser:(id)userInfo completed:(CCBooleanResultBlock)completed {
    
    //NSLog(@"============ updateUserInfo ============");
    
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:userInfo toURL:[self urlWithHttp4Auth:[self methodAppendingSocial:kUrlUploadUserInfo]] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, YES);
        }else {
            completed([weakSelf parseResponseError:responseObject], NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, NO);
    }];
}

- (void)bindWeChatID:(NSString *)unionID withUserID:(long)userID completed:(CCDictionaryResultBlock)completed {
    __weak __typeof(self) weakSelf = self;
    NSDictionary *params = @{
                             @"unionid":unionID,
                             @"user_id":@(userID),
                             @"appkey":k_APP_KEY,
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlBindWeChatUser]] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, nil);
    }];
}

- (void)bindPhone:(NSString *)phone withWeChatID:(NSString *)unionID PIN:(NSString *)PIN completed:(CCDictionaryResultBlock)completed {
    __weak __typeof(self) weakSelf = self;
    NSDictionary *params = @{
                             @"unionid":unionID,
                             @"telnumber":phone,
                             @"code":PIN,
                             @"appkey":k_APP_KEY,
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlWechatBindTel]] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, nil);
    }];
}

- (void)changePhone:(NSString *)phone withUserID:(long)userID PIN:(NSString *)PIN completed:(CCDictionaryResultBlock)completed {
    __weak __typeof(self) weakSelf = self;
    NSDictionary *params = @{
                             @"user_id":@(userID),
                             @"telnumber":phone,
                             @"code":PIN,
                             @"appkey":k_APP_KEY,
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlBindTel]] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, nil);
    }];
}

- (void)unBindWeChatWithPhone:(NSString *)phone completed:(CCDictionaryResultBlock)completed {
    __weak __typeof(self) weakSelf = self;
    NSDictionary *params = @{
                             @"telnumber":phone,
                             @"appkey":k_APP_KEY,
                             };
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:[self methodAppendingAccount:kUrlUnbindWeChatUser]] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, nil);
    }];
}

#pragma mark - 新闻,广告

// 33. 广告
- (void)loadAdvertisementWithPhone:(NSString *)phone agent:(NSString *)agent location:(CLLocation *)location completed:(CCArrayResultBlock)completed {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = phone;
    
    if (agent) {
        params[@"agentName"] = agent;
    }
    if (location) {
        params[@"latitude"] = @(location.coordinate.latitude);
        params[@"longtitude"] = @(location.coordinate.longitude);
    }
    
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:params toURL:[self urlWithHttps4Ads:kUrlLoadAds] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([weakSelf requireSuccess:responseObject]) {
            NSArray *ads = responseObject[@"ads"];
            completed(nil, ads);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, nil);
    }];
}

- (void)loadNewsWithCompleted:(CCArrayResultBlock)completed {
    
    NSDictionary *params = @{@"task":@"getlist",
                             @"recommend":@1,
                             @"recommend_time":@""
                             };
    
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:params toURL:@"http://out.reduc.cn/interface/index/" success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject) {
            NSArray *newsJsonArray = responseObject;
            completed(nil, newsJsonArray);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

#pragma mark - 支付

- (void)checkBalanceWithPhone:(NSString *)phone completed:(void(^)(NSError *error, CGFloat accountBalance))completed {
    
    //NSLog(@"============ checkBalanceWithPhone ============");
    
    NSDictionary *params = @{@"telnumber":phone};
    
    [self postCCParams:params toURL:[self urlWithHttp4Application:kUrlCheckBalance] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([self requireSuccess:responseObject]) {
            CGFloat accountBalance = [responseObject[@"balance"] floatValue];
            completed(nil, accountBalance);
        }else {
            completed([self parseResponseError:responseObject], -1);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, -1);
    }];
}

- (void)rechargeToPhone:(NSString *)phone cardNumber:(NSString *)cardNumber cardPassword:(NSString *)cardPassword completed:(CCBooleanResultBlock)completed {
    
    //NSLog(@"============ rechargeToPhone ============");
    
    NSDictionary *params = @{@"context":@{@"telnumber":phone,
                                          @"cardnumber":cardNumber,
                                          @"cardpassword":cardPassword,
                                          },
                             @"rechargetype":@"normal",
                             };
    
    [self postCCParams:params toURL:[self urlWithHttps4Recharge:kUrlRecharge] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        if ([self requireSuccess:responseObject]) {
            completed(nil, YES);
        }else {
            completed([self parseResponseError:responseObject], NO);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, NO);
    }];
}

#pragma mark - 电话，联系人

- (void)callPhone:(NSString *)target backToPhone:(NSString *)phone completed:(CCDictionaryResultBlock)completed {
    
    //NSLog(@"============ callbackPhone ============");
    
    NSDictionary *params = @{@"called_number":target?:@"",
                             @"calling_number":phone?:@"",
                             };
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:params toURL:[self urlWithHttp4Application:kUrlCallBack] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

- (void)uploadContacts:(NSDictionary *)contactListDictionary toPhone:(NSString *)phone completed:(CCArrayResultBlock)completed {
    
    NSMutableArray *contactArray = [NSMutableArray array];
    
    for(NSString *key in [contactListDictionary allKeys]) {
        [contactArray addObject:@{@"number":key?:@"",
                                  @"name":contactListDictionary[key]?:@"",
                                  }];
    }
    
    NSDictionary *params = @{@"user_number":phone?:@"",
                             @"contact_list":contactArray,
                             };
    
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:params toURL:[self urlWithHttp4Auth:kUrlUploadContactList] success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject[@"friend_list"]);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completed(error, nil);
        
    }];
}

#pragma mark --- 设置推荐人
- (void)settingInviter:(NSString *)userNumber referee:(NSString *)referee completed:(CCDictionaryResultBlock)completed {
    
    NSDictionary *params = @{
                             @"user_number":userNumber?:@"",
                             @"referee":referee?:@""
                             };
    
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:params toURL:[self urlWithHttp4Application:kSetreferee] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

#pragma mark --- 获取推荐人详情
- (void)getTheInviterDetailInfo:(NSString *)userNumber completed:(CCDictionaryResultBlock)completed {
    
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:@{@"user_number":userNumber?:@""} toURL:[self urlWithHttp4Application:kGetrefer] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([weakSelf requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

#pragma mark - 摇一摇

- (void)shake4CharityWithPhone:(NSString *)phone advertisementID:(NSString *)adID latitude:(CGFloat)latitude longtitude:(CGFloat)longtitude completed:(CCDictionaryResultBlock)completed {
    
    [self postCCParams:@{@"telnumber":phone?:@""} toURL:[self urlWithHttp4Application:kUrlShake4Charity] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        completed(nil, responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

- (void)shake4SignInwithPhone:(NSString *)phone completed:(CCDictionaryResultBlock)completed {
    
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:@{@"user_number":phone?:@""} toURL:[self urlWithHttp4Application:kUrlSignN] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([self requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

#pragma mark - 检查更新

- (void)checkVersonUpdatedWithCompleted:(CCDictionaryResultBlock)completed {
    
    __weak __typeof(self) weakSelf = self;
    
    [self postCCParams:@{} toURL:[self urlWithHttp4Application:kUrlCheckVersion] success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"============ success:%@ ============",responseObject);
        
        if ([self requireSuccess:responseObject]) {
            completed(nil, responseObject);
        }else {
            completed([weakSelf parseResponseError:responseObject], nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"============ fail:%@ ============",error);
        completed(error, nil);
    }];
}

#pragma mark - Misc

- (NSString *)methodAppendingAccount:(NSString *)methodName {
    return [@"account/" stringByAppendingString:methodName];
}

- (NSString *)methodAppendingSocial:(NSString *)methodName {
    return [@"social/" stringByAppendingString:methodName];
}

- (NSString *)urlWithHttp4Auth:(NSString *)methodName {
    return [CC_ACCOUNT_IP stringByAppendingString:[NSString stringWithFormat:@"/Auth/%@",methodName]];
}

- (NSString *)urlWithHttp4Application:(NSString *)methodName {
    return [CC_ACCOUNT_IP stringByAppendingString:[NSString stringWithFormat:@"/Application/%@",methodName]];
}

- (NSString *)urlWithHttps4Ads:(NSString *)methodName {
    return [CC_ACCOUNT_IP stringByAppendingString:[NSString stringWithFormat:@"/ad/%@",methodName]];
}

- (NSString *)urlWithHttps4Recharge:(NSString *)methodName {
    return [CC_ACCOUNT_IP stringByAppendingString:[NSString stringWithFormat:@"/user/user/recharge/%@",methodName]];
}

- (NSError *)parseResponseError:(id)responseObject {
    if (!responseObject) {
        return [NSError errorWithDomain:@"服务器错误" code:-2 userInfo:responseObject];
    }
    
    if ([responseObject[kResponseResult] isEqualToString:kResponseResultFailed]) {
        NSString *message = responseObject[kResponseText];
        return [NSError errorWithDomain:message code:-1 userInfo:responseObject];
    }
    return nil;
}

- (BOOL)requireSuccess:(id)responseObject {
    if (responseObject && [responseObject[kResponseResult] isEqualToString:kResponseResultSuccess]) {
        return YES;
    }
    return NO;
}

- (NSMutableDictionary *)mutableParamsWithHeads {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"http_headers":self.requestSerializer.HTTPRequestHeaders}];
}

- (void)postCCParams:(NSDictionary *)dic toURL:(NSString *)url success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    __weak __typeof(self) weakSelf = self;
    
#ifdef NO_ENCRYPITON
    
    NSMutableDictionary *params = [weakSelf mutableParamsWithHeads];
    [params addEntriesFromDictionary:dic];
    [self POST:url parameters:params progress:nil success:success failure:failure];
#else
    
    [self POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSMutableDictionary *params = [weakSelf mutableParamsWithHeads];
        [params addEntriesFromDictionary:dic];
        
        NSData *data = transferDictionaryToData(params);
        
        if (data) {
            data = encryptData(data);
            [formData appendPartWithFileData:data name:@"param" fileName:@"file" mimeType:@"application/octet-stream"];
        }
    } progress:nil success:success failure:failure];
    
#endif
}

- (void)postCCParams:(NSDictionary *)dic withImages:(NSArray *)images toURL:(NSString *)url success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure  {
    
    __weak __typeof(self) weakSelf = self;
    
#ifdef NO_ENCRYPITON
    NSMutableDictionary *params = [weakSelf mutableParamsWithHeads];
    [params addEntriesFromDictionary:dic];
    
    [self POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for(int i = 0; i < images.count; i++) {
            UIImage *image = images[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            //            NSString *name = @"media";
            NSString *fileName = @"phone.png";
            if (i > 0 ) {
                //                name = [NSString stringWithFormat:@"media%i",i];
                fileName = [NSString stringWithFormat:@"phone%i.png",i];
            }
            [formData appendPartWithFileData:imageData name:@"images" fileName:fileName mimeType:@"application/octet-stream"];
        }
    } progress:nil success:success failure:failure];
    
#else
    
    [self POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSMutableDictionary *params = [weakSelf mutableParamsWithHeads];
        [params addEntriesFromDictionary:dic];
        
        NSData *data = transferDictionaryToData(params);
        
        if (data) {
            data = encryptData(data);
            [formData appendPartWithFileData:data name:@"param" fileName:@"file" mimeType:@"application/octet-stream"];
        }
        
        for(int i = 0; i < images.count; i++) {
            UIImage *image = images[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            NSString *name = @"media";
            NSString *fileName = @"phone.png";
            if (i > 0 ) {
                name = [NSString stringWithFormat:@"media%i",i];
                fileName = [NSString stringWithFormat:@"phone%i.png",i];
            }
            [formData appendPartWithFileData:imageData name:@"images" fileName:fileName mimeType:@"application/octet-stream"];
        }
        
        
        
        if (data) {
            data = encryptData(data);
            [formData appendPartWithFileData:data name:@"param" fileName:@"param.file" mimeType:@"application/octet-stream"];
        }
        
        NSData *imageData;
        if (image) {
            imageData = UIImageJPEGRepresentation(image, 0.5);
        }
        
        [formData appendPartWithFileData:imageData name:@"icon" fileName:@"phone.png" mimeType:@"application/octet-stream"];
        
        
    } success:success failure:failure];
#endif
    
}

- (NSString *)stringWithCCReason:(CCReason)reason {
    switch (reason) {
        case CCReasonSignUp:{
            return @"register";
            break;
        }
        case CCReasonReset:{
            return @"renew";
            break;
        }
        case CCReasonDoctorLogin:{
            return @"doctorslogin";
            break;
        }
        case CCReasonBindTel:{
            return @"bind";
            break;
        }
        default:
            return @"register";
            break;
    }
}

#pragma mark - 4 test

- (NSMutableDictionary *)apiConfigDictionary {
    if (!_apiConfigDictionary) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ApiConfig" ofType:@"plist"];
        _apiConfigDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    }
    return _apiConfigDictionary;
}

- (NSDictionary *)apiAtIndex:(NSInteger)index {
    NSDictionary *params = self.apiConfigDictionary[@"Root"];
    NSArray *apis = params[@"apis"];
    NSDictionary *api = apis[index];
    return api;
}



@end
