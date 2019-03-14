//
//  HJChainRequest.h
//
//  Created by Haijun on 2018/11/25.
//

#import "HJBaseRequest.h"

@class HJChainRequest, HJResponse;

/// response = 当前请求成功的响应内容
typedef void (^HJChainRequestProgressBlock)(HJChainRequest *chainRequest, HJResponse *response, NSInteger nextIdx);

@interface HJChainRequest : HJBaseRequest

+ (instancetype)requestWithRequests:(NSArray *)requests
                           progress:(HJChainRequestProgressBlock)progress;

@property (nonatomic, strong) NSArray<HJBaseRequest *> *requests;
@property (nonatomic, copy) HJChainRequestProgressBlock progressBlock;

@end
