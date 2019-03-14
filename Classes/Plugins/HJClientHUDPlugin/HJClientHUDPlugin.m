//
//  HJClientHUDPlugin.m
//
//  Created by Haijun on 2018/9/28.
//

#import "HJClientHUDPlugin.h"
#import "HJRequest.h"
#import "MBProgressHUD+HJExtension.h"
#import <objc/runtime.h>

NSString * const HJClientHUDView = @"HJClientHUDView";

@implementation HJClientHUDPlugin

- (void)client:(HJClient *)client willExecutionRequest:(HJBaseRequest *)request {
    UIView *targetView = request.userInfo[HJClientHUDView];
    if (!targetView) { return; }
    [MBProgressHUD showLoading:nil toView:targetView];
}

- (void)client:(HJClient *)client uploadProgress:(NSProgress *)progress forRequest:(HJRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *targetView = request.userInfo[HJClientHUDView];
        if (!targetView) { return; }
        MBProgressHUD *hud = [self progressHUHJithView:targetView];
        if (!hud) {
            hud = [MBProgressHUD showProgress:@"上传中..." toView:targetView];
            [self setProgressHUD:hud withView:targetView];
        }
        hud.progressObject = progress;
    });
}

- (void)client:(HJClient *)client didFinishRequest:(HJBaseRequest *)request {
    UIView *targetView = request.userInfo[HJClientHUDView];
    if (!targetView) { return; }
    [MBProgressHUD hideHUDForView:targetView animated:YES];
}

#pragma mark - Getter & Setter

static const char kHJClientProgressHUDKey;

- (MBProgressHUD *)progressHUHJithView:(UIView *)view {
    return objc_getAssociatedObject(view, &kHJClientProgressHUDKey);
}

- (void)setProgressHUD:(MBProgressHUD *)hud withView:(UIView *)view {
    objc_setAssociatedObject(view, &kHJClientProgressHUDKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
