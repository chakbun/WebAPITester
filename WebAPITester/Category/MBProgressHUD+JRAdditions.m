//
//  MBProgressHUD+JRAdditions.m
//  CCFanMi
//
//  Created by cloudtech on 4/6/16.
//  Copyright © 2016 cloundCall. All rights reserved.
//

#import "MBProgressHUD+JRAdditions.h"
#import "NSString+JRAdditions.h"

@implementation MBProgressHUD (JRAdditions)

+ (MB_INSTANCETYPE)showLoadingAddedTo:(UIView *)view withText:(NSString *)text {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    return hud;
}

+ (MB_INSTANCETYPE)showTipsAddedTo:(UIView *)view withText:(NSString *)text dismissInSeconds:(CGFloat)seconds {
    
    MBProgressHUD *hud = nil;
    
    if (text.length > 10) {
        CGFloat width = [[UIScreen mainScreen] bounds].size.width - 40;
        UIFont *font = [UIFont systemFontOfSize:16];
        CGFloat height = [text getSizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT)].height;
        hud = [[MBProgressHUD alloc] initWithView:view];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        label.text = text;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.font = font;
        label.textAlignment = NSTextAlignmentCenter;
        hud.customView = label;
        hud.mode = MBProgressHUDModeCustomView;
        [view addSubview:hud];
        [hud show:YES];
    }else {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = text;
    }
    [hud hide:YES afterDelay:seconds];
    return hud;
}

@end
