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

+ (instancetype)requestWithPath:(NSString *)path method:(HJRequestMethod)method responseDataCls:(Class)responseDataCls {
    HJRequest *request = [self requestWithPath:path method:method];
    request.responseDataCls = responseDataCls;
    return request;
}

+ (instancetype)requestWithPath:(NSString *)path method:(HJRequestMethod)method deserializationPath:(NSString *)deserializationPath responseDataCls:(Class)responseDataCls {
    HJRequest *request = [self requestWithPath:path method:method responseDataCls:responseDataCls];
    request.deserializationPath = deserializationPath;
    return request;
}

+ (instancetype)GET:(NSString *)path responseDataCls:(Class)responseDataCls {
    return [self requestWithPath:path method:HJRequestMethodGET responseDataCls:responseDataCls];
}

+ (instancetype)GET:(NSString *)path deserializationPath:(NSString *)deserializationPath responseDataCls:(Class)responseDataCls {
    return [self requestWithPath:path method:HJRequestMethodGET deserializationPath:deserializationPath responseDataCls:responseDataCls];
}

+ (instancetype)POST:(NSString *)path responseDataCls:(Class)responseDataCls {
    return [self requestWithPath:path method:HJRequestMethodPOST responseDataCls:responseDataCls];
}

+ (instancetype)POST:(NSString *)path deserializationPath:(NSString *)deserializationPath responseDataCls:(Class)responseDataCls {
    return [self requestWithPath:path method:HJRequestMethodPOST deserializationPath:deserializationPath responseDataCls:responseDataCls];
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
