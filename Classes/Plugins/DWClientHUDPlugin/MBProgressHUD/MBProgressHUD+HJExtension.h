//
//  MBProgressHUD+HJExtension.h
//
//  Created by Haijun on 2018/8/14.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (HJExtension)

/**
 显示消息HUD

 @param message 消息
 @param toView toView
 */
+ (void)showMessage:(NSString *)message toView:(UIView *)toView;

/**
 显示进度HUD

 @param message 状态
 @param toView toView
 @return MBProgressHUD
 */
+ (MBProgressHUD *)showProgress:(NSString *)message toView:(UIView *)toView;

/**
 显示Loading HUD

 @param message 状态
 @param toView toView
 */
+ (void)showLoading:(NSString *)message toView:(UIView *)toView;

@end
