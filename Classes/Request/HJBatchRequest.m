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

@end
