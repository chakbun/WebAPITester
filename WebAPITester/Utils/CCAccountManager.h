//
//  CCAccountManager.h
//  CCWeLove
//
//  Created by cloudtech on 15/8/18.
//  Copyright (c) 2015年 CloudTel. All rights reserved.
//

/**
 *  依赖框架
 *  1. AFNetworking
 *  2. MJExtension
 *  3. CCServerDefine.h
 */
#import "AFNetworking.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>
#import "ConfigURL.h"
#import "CCServerTool.h"
#import "CCAccountEnum.h"

#define kTimeoutInterval 20

@interface CCAccountManager : AFHTTPSessionManager

@property (nonatomic, strong) NSMutableDictionary *apiConfigDictionary;

+ (instancetype)shareManager;

#pragma mark - 账号相关

- (void)requestPIN4Phone:(NSString *)phone way:(CCPINWay)way reason:(CCReason)reason completed:(CCBooleanResultBlock)completed;

- (void)verifyPIN4Phone:(NSString *)phone pin:(NSString *)pin reason:(CCReason)reason completed:(CCBooleanResultBlock)completed;

- (void)signUpWithPhone:(NSString *)phone password:(NSString *)password PIN:(NSString *)PIN completed:(CCDictionaryResultBlock)completed;

- (void)signInWithPhone:(NSString *)phone password:(NSString *)password completed:(CCModelResultBlock)completed;

- (void)signInWithWeChatID:(NSString *)unionID completed:(void(^)(NSError *loginErr, NSDictionary *loginInfo))completed;

- (void)loadUserInfoWithValue:(id)value valueType:(NSInteger)type completed:(CCModelResultBlock)completed;

- (void)uploadUserIcon:(UIImage *)image phone:(NSString *)phone completed:(void(^)(NSError *error, NSString *iconURL, NSString *thumbIconURL))completed;

- (void)loadUserIconURLWithPhone:(NSString *)phone completed:(void(^)(NSError *error, NSString *iconURL, NSString *thumbIconURL))completed;

- (void)updateUser:(id)userInfo completed:(CCBooleanResultBlock)completed;

- (void)updatePassword:(NSString *)newPSW fromOld:(NSString *)oldPSW forPhone:(NSString *)phone completed:(CCBooleanResultBlock)completed;

- (void)resetPassword:(NSString *)password forPhone:(NSString *)phone completed:(CCBooleanResultBlock)completed;

/**
 after user registered via phone number , they can bind wechat with this mehotd
 */
- (void)bindWeChatID:(NSString *)unionID withUserID:(long)userID completed:(CCDictionaryResultBlock)completed;

/**
 after user registered via wechat, they can bind phone number with this method
 */
- (void)bindPhone:(NSString *)phone withWeChatID:(NSString *)unionID PIN:(NSString *)PIN completed:(CCDictionaryResultBlock)completed;

- (void)unBindWeChatWithPhone:(NSString *)phone completed:(CCDictionaryResultBlock)completed;

- (void)changePhone:(NSString *)phone withUserID:(long)userID PIN:(NSString *)PIN completed:(CCDictionaryResultBlock)completed;


#pragma mark - 广告资讯

- (void)loadNewsWithCompleted:(CCArrayResultBlock)completed;

- (void)loadAdvertisementWithPhone:(NSString *)phone agent:(NSString *)agent location:(CLLocation *)location completed:(CCArrayResultBlock)completed;


#pragma mark - 支付相关

- (void)checkBalanceWithPhone:(NSString *)phone completed:(void(^)(NSError *error, CGFloat accountBalance))completed;

- (void)rechargeToPhone:(NSString *)phone cardNumber:(NSString *)cardNumber cardPassword:(NSString *)cardPassword completed:(CCBooleanResultBlock)completed;

#pragma mark - 电话，联系人

- (void)callPhone:(NSString *)target backToPhone:(NSString *)phone completed:(CCDictionaryResultBlock)completed;

- (void)uploadContacts:(NSDictionary *)contactListDictionary toPhone:(NSString *)phone completed:(CCArrayResultBlock)completed;

- (void)settingInviter:(NSString *)userNumber referee:(NSString *)referee completed:(CCDictionaryResultBlock)completed;

- (void)getTheInviterDetailInfo:(NSString *)userNumber completed:(CCDictionaryResultBlock)completed;

#pragma mark - 摇一摇

- (void)shake4CharityWithPhone:(NSString *)phone advertisementID:(NSString *)adID latitude:(CGFloat)latitude longtitude:(CGFloat)longtitude completed:(CCDictionaryResultBlock)completed;

- (void)shake4SignInwithPhone:(NSString *)phone completed:(CCDictionaryResultBlock)completed;

- (void)checkVersonUpdatedWithCompleted:(CCDictionaryResultBlock)completed;

#pragma mark - Misc

- (NSMutableDictionary *)mutableParamsWithHeads;

- (NSString *)urlWithHttp4Auth:(NSString *)methodName;

- (NSString *)urlWithHttp4Application:(NSString *)methodName;

- (NSString *)urlWithHttps4Ads:(NSString *)methodName;

- (NSString *)urlWithHttps4Recharge:(NSString *)methodName;

- (NSError *)parseResponseError:(id)responseObject;

- (BOOL)requireSuccess:(id)responseObject;

- (void)postCCParams:(NSDictionary *)dic toURL:(NSString *)url success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (void)postCCParams:(NSDictionary *)dic withImages:(NSArray *)images toURL:(NSString *)url success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
