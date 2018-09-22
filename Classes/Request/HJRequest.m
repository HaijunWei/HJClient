//
//  HJRequest.m
//
//  Created by Haijun on 2018/9/22.
//

#import "HJRequest.h"

@implementation HJRequest

+ (instancetype)requestWithPath:(NSString *)path {
    return [self requestWithPath:path method:HJRequestMethodGET];
}

+ (instancetype)requestWithPath:(NSString *)path method:(HJRequestMethod)method {
    HJRequest *request = [self new];
    request.path = path;
    request.method = method;
    return request;
}

- (instancetype)init {
    if (self = [super init]) {
        _method = HJRequestMethodGET;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@>", self, self.path];
}

@end
