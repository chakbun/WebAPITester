//
//  CCServerTool.h
//  CCWeLove
//
//  Created by Jaben on 15/12/11.
//  Copyright © 2015年 CloudTel. All rights reserved.
//

#ifndef CCServerTool_h
#define CCServerTool_h

#import "CCServerDefine.h"
#import "encryption.h"

#pragma mark - MD5 String转换

CG_INLINE NSString * encryptTo32BitMd5String(NSString *rawString) {
    
    const char *cStr = [rawString UTF8String];
    
    unsigned char digest[16];
    
    CC_MD5( cStr, (int)rawString.length, digest );
    
    NSMutableString *result = [NSMutableString stringWithCapacity:16 * 2];
    
    for(int i = 0; i < 16; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

#pragma mark - 利用加密库对数据加密

CG_INLINE NSData * encryptData(NSData *data) {
    
    NSData *rawData = data;
    
    EncryptPacket((char*)[rawData bytes], (int)[rawData length]);
    
    return rawData;
}

CG_INLINE NSData * transferDictionaryToData(NSDictionary *dict) {
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!error) {
        return data;
    }
    
    return nil;
}

CG_INLINE NSString * errMsgWithErrCode(NSInteger code) {
    switch (code) {
        case 0:
            return @"正常无错误";
            break;
        case -500:
            return @"系统内部错误";
            break;
        case -410:
            return @"被请求的资源在服务器上已经不再可用，而且没有任何已知的转发地址";
            break;
        case -400:
            return @"错误请求，请求数据参数有误";
            break;
        case -401:
            return @"认证信息失败或黑名单等";
            break;
        case -412:
            return @"参数不完整，参数没填写完全";
            break;
        case -408:
            return @"参数不符合范围";
            break;
        case -427:
            return @"Signature参数错误";
            break;
        case -421:
            return @"IP限制";
            break;
        case -422:
            return @"参数格式有误，如非正确手机号/主被叫号码一样";
        case -430:
            return @"用户已存在";
            break;
        case -431:
            return @"用户不存在";
            break;
        case -403:
            return @"权限错误，不允许使用该函数操作";
        case -406:
            return @"访问次数超过上限，禁止操作";
            break;
        case -404:
            return @"找不到资源";
            break;
        case -999:
            return @"未知错误";
            break;
        default:
            break;
    }
    return @"";
}

#endif /* CCServerTool_h */
