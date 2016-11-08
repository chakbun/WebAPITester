//
//  ConfigURL.h
//  CCWeLove
//
//  Created by CloudTel on 15/8/7.
//  Copyright (c) 2015年 CloudTel. All rights reserved.
//

// 调试信息
#ifdef DEBUG
#else
#endif

#define DEV_DEBUG 1  //  1开发环境，0正式环境


#if DEV_DEBUG == 0
#define CC_ACCOUNT_IP   @"https://fm.ipinkme.com:8089"
#define CC_BASE_HTTP_IP @"https://fm.ipinkme.com:8089"

#define CCHEALTH_HTTP_API CC_BASE_HTTP_IP"/api"

#elif DEV_DEBUG == 1
#define CC_ACCOUNT_IP   @"https://test.ydkjcp.com:8089"
#define CC_BASE_HTTP_IP @"https://test.ydkjcp.com:8089"

#define CCHEALTH_HTTP_API CC_BASE_HTTP_IP"/api"

#endif

