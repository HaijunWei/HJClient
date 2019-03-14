//
//  MBProgressHUD+HJExtension.m
//
//  Created by Haijun on 2018/8/14.
//

#import "MBProgressHUD+HJExtension.h"

@implementation MBProgressHUD (HJExtension)

+ (void)load {
    [MBProgressHUD appearance].margin = 10;
    [MBProgressHUD appearance].contentColor = [UIColor whiteColor];
    [MBProgressHUD appearance].animationType = MBProgressHUDAnimationZoom;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [MBProgressHUD appearance].color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
#pragma clang diagnostic pop
}

+ (void)showMessage:(NSString *)message toView:(UIView *)toView {
    if (!toView) { return; }
    MBProgressHUD *hud = [self HUDWithMessage:message toView:toView isModal:NO];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0, CGRectGetHeight(hud.bounds) * 0.5 - 150);
    [hud hideAnimated:YES afterDelay:2];
}

+ (MBProgressHUD *)showProgress:(NSString *)message toView:(UIView *)toView {
    MBProgressHUD *hud = [self HUDWithMessage:message toView:toView isModal:YES];
    hud.minSize = CGSizeMake(100, 100);
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    return hud;
}

+ (void)showLoading:(NSString *)message toView:(UIView *)toView {
    MBProgressHUD *hud = [self HUDWithMessage:message toView:toView isModal:YES];
    hud.minSize = CGSizeMake(100, 100);
}

+ (MBProgressHUD *)HUDWithMessage:(NSString *)message toView:(UIView *)toView isModal:(BOOL)isModal {
    [MBProgressHUD hideHUDForView:toView animated:YES];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:toView];
    hud.detailsLabel.text = message;
    hud.removeFromSuperViewOnHide = YES;
    hud.detailsLabel.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:14] ? : [UIFont systemFontOfSize:14];
    hud.userInteractionEnabled = isModal;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [toView addSubview:hud];
    [hud showAnimated:YES];
    return hud;
}

@end
