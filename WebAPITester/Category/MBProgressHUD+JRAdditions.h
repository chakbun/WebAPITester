//
//  MBProgressHUD+JRAdditions.h
//  CCFanMi
//
//  Created by cloudtech on 4/6/16.
//  Copyright © 2016 cloundCall. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (JRAdditions)

+ (MB_INSTANCETYPE)showLoadingAddedTo:(UIView *)view withText:(NSString *)text;

+ (MB_INSTANCETYPE)showTipsAddedTo:(UIView *)view withText:(NSString *)text dismissInSeconds:(CGFloat)seconds;

@end
