//
//  CCAccountAPI.h
//  CCFanMi
//
//  Created by cloudtech on 10/28/16.
//  Copyright © 2016 cloundCall. All rights reserved.
//

#ifndef CCAccountAPI_h
#define CCAccountAPI_h

NSString *const kUrlRequestPIN4Phone = @"getAuthCode.do";
NSString *const kUrlVerifyPIN4Phone = @"verifyAuthCode.do";
NSString *const kUrlSignUp = @"doRegister.do";
NSString *const kUrlSignIn = @"confirmInfo.do";
NSString *const kUrlChangePassword = @"resetPasswd.do";
NSString *const kUrlResetPassword = @"setPasswd.do"; //不要对名字感到奇怪，服务器接口是这样子，没办法

NSString *const kUrlUnbindWeChatUser = @"unbindWeixin.do";
NSString *const kUrlLoginByWeChat = @"weixinLogin.do";
NSString *const kUrlBindWeChatUser = @"bindWeixin.do";
NSString *const kUrlWechatBindTel = @"weixinBindPhone.do";
NSString *const kUrlBindTel = @"bindPhone.do";


NSString *const kUrlUploadUserInfo = @"userinfo.do";
NSString *const kUrlLoadUserInfo = @"downloaduserinfo.do";
NSString *const kUrlUploadUserImage = @"setusericonv2.do";
NSString *const kUrlLoadUserImageUrl = @"getusericonv2.do";
NSString *const kSetreferee = @"social/setreferee.do"; //设置推荐人
NSString *const kGetrefer = @"social/getrefer.do"; //获取推荐人详情


NSString *const kUrlLoadAds = @"getAds.do";
NSString *const kUrlCheckBalance = @"user/getbalance.do";
NSString *const kUrlRecharge = @"recharge.jsp";
NSString *const kUrlCheckVersion = @"update/getlatestversion.do";
NSString *const kUrlCallBack = @"call/doCallBack.do";
NSString *const kUrlUploadContactList = @"contact/upload.do";
NSString *const kUrlLoadNotificaiton = @"cloudcall/sysmsg.jsp";
NSString *const kUrlSignN = @"sign.do"; //签到
NSString *const kUrlShake4Charity = @"charity.do"; //慈善摇一摇



#endif /* CCAccountAPI_h */
