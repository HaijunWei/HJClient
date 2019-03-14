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

- (void)setRequests:(NSArray<HJBaseRequest *> *)requests {
    _requests = requests;
    [requests enumerateObjectsUsingBlock:^(HJBaseRequest *obj, NSUInteger idx, BOOL *stop) {
        obj.isSubrequest = YES;
    }];
}

@end
