//
//  HJClient+HUDPlugin.h
//
//  Created by Haijun on 2018/9/28.
//

#import <UIKit/UIKit.h>
#import "HJClient.h"
#import "HJClientHUDPlugin.h"

@interface HJClient (HUDPlugin)

+ (HJRequestTask *)enqueueRequest:(HJBaseRequest *)request hudView:(UIView *)hudView success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure;

@end
