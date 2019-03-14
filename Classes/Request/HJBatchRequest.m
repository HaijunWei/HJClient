//
//  HJBatchRequest.m
//
//  Created by Haijun on 2018/9/22.
//

#import "HJBatchRequest.h"

@implementation HJBatchRequest

+ (instancetype)requestWithRequests:(NSArray *)requests {
    HJBatchRequest *request = [self new];
    request.requests = requests;
    return request;
}

- (void)setRequests:(NSArray<HJBaseRequest *> *)requests {
    _requests = requests;
    [requests enumerateObjectsUsingBlock:^(HJBaseRequest *obj, NSUInteger idx, BOOL *stop) {
        obj.isSubrequest = YES;
    }];
}

@end
