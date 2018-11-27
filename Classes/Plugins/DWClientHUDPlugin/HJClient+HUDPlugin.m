//
//  HJClient+HUDPlugin.m
//
//  Created by Haijun on 2018/9/28.
//

#import "HJClient+HUDPlugin.h"

@implementation HJClient (HUDPlugin)

+ (HJRequestTask *)enqueueRequest:(HJBaseRequest *)request hudView:(UIView *)hudView success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure; {
    request.userInfo[HJClientHUDView] = hudView;
    return [self enqueueRequest:request success:success failure:failure];
}

@end
