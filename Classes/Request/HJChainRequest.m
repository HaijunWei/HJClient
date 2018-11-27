//
//  HJChainRequest.m
//
//  Created by Haijun on 2018/11/25.
//

#import "HJChainRequest.h"

@implementation HJChainRequest

+ (instancetype)requestWithRequests:(NSArray *)requests progress:(HJChainRequestProgressBlock)progress {
    HJChainRequest *request = [self new];
    request.requests = requests;
    request.progressBlock = progress;
    return request;
}

@end
