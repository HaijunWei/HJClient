//
//  HJClient.m
//
//  Created by Haijun on 2018/9/22.
//

#import "HJClient.h"
#import <MJExtension/MJExtension.h>
#import <AFNetworking/AFNetworking.h>

HJClientResponseKey const HJClientResponseCodeKey = @"code";
HJClientResponseKey const HJClientResponseDataKey = @"data";
HJClientResponseKey const HJClientResponseMessageKey = @"message";

@interface HJClient ()

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) NSMutableArray<id<HJClientPlugin>> *plugins;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@property (nonatomic, strong) AFJSONRequestSerializer *jsonRequestSerializer;

@end

@implementation HJClient

#pragma mark - Class Method

+ (HJRequestTask *)enqueueRequest:(HJBaseRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
    return [[self shared] enqueueRequest:request success:success failure:failure];
}

#pragma mark - Reuqest

/// 入列请求
- (HJRequestTask *)enqueueRequest:(HJBaseRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
    if ([request isKindOfClass:[HJRequest class]]) {
        return [self executionRequest:(HJRequest *)request success:success failure:failure];
    } else if ([request isKindOfClass:[HJBatchRequest class]]) {
        return [self executionBatchReuqest:(HJBatchRequest *)request success:success failure:failure];
    } else {
        return [self excutionChainRequest:(HJChainRequest *)request success:success failure:failure];
    }
}

/// 执行并发请求
- (HJRequestTask *)executionBatchReuqest:(HJBatchRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
    [self willExecutionRequest:request];
    dispatch_group_t group = dispatch_group_create();
    HJRequestTask *task = [HJRequestTask new];
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < request.requests.count; i++) { [result addObject:[NSNull null]]; }
    __block NSString *resultError;
    void (^completionHanlder)(HJResponse *, NSString *, NSInteger) = ^(HJResponse *response, NSString *error, NSInteger index) {
        if (response) {
            result[index] = response;
            return;
        }
        // 排除后续取消Task抛出的错误
        if (!resultError) { resultError = error; }
        // 某个任务发生错误，结束全部任务
        [task cancel];
    };
    for (int i = 0; i < request.requests.count; i++) {
        HJBaseRequest *subRequest = request.requests[i];
        dispatch_group_enter(group);
        [task addSubtask:[self enqueueRequest:subRequest success:^(HJResponse *response) {
            completionHanlder(response, nil, i);
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            completionHanlder(nil, error, i);
            dispatch_group_leave(group);
        }]];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self didFinishRequest:request error:resultError];
        if (resultError) {
            failure(resultError);
            return;
        }
        HJResponse *response = [HJResponse new];
        response.dataObject = result;
        success(response);
    });
    return task;
}

/// 执行链式请求
- (HJRequestTask *)excutionChainRequest:(HJChainRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
    [self willExecutionRequest:request];
    HJRequestTask *task = [HJRequestTask new];
    NSMutableArray *resultResponses = [NSMutableArray array];
    for (int i = 0; i < request.requests.count; i++) { [resultResponses addObject:[NSNull null]]; }
    [self excutionChainRequest:request task:task resultResponses:resultResponses success:success failure:failure];
    return task;
}

/// 递归链式请求
- (void)excutionChainRequest:(HJChainRequest *)request
                        task:(HJRequestTask *)task
             resultResponses:(NSMutableArray *)resultResponses
                     success:(HJRequestSuccessBlock)success
                     failure:(HJRequestFailureBlock)failure {
    void (^callback)(NSString *) = ^(NSString *error) {
        [self didFinishRequest:request error:error];
        if (error) { failure(error); return; }
        HJResponse *response = [HJResponse new];
        response.dataObject = resultResponses;
        success(response);
    };
    NSInteger idx = [resultResponses indexOfObject:[NSNull null]];
    if (idx == NSNotFound || task.isCanceled) {
        callback(nil);
        return;
    }
    [task addSubtask:[self enqueueRequest:request.requests[idx] success:^(HJResponse *response) {
        resultResponses[idx] = response;
        NSInteger nextIdx = idx + 1;
        if (nextIdx >= request.requests.count) { nextIdx = NSNotFound; }
        request.progressBlock(request, response, nextIdx);
        [self excutionChainRequest:request task:task resultResponses:resultResponses success:success failure:failure];
    } failure:^(NSString *error) {
        [task cancel];
        callback(error);
    }]];
}

/// 执行单个请求
- (HJRequestTask *)executionRequest:(HJRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
    // 附加参数
    if ([self.delegate respondsToSelector:@selector(client:prepareRequest:)]) {
        request = [self.delegate client:self prepareRequest:request];
    }
    NSMutableURLRequest *URLRequest = [self createURLRequest:request];
    if ([self.delegate respondsToSelector:@selector(client:prepareURLRequest:)]) {
        URLRequest = [self.delegate client:self prepareURLRequest:URLRequest];
    }
    
    void (^successHandler)(id, BOOL) = ^(id responseObject, BOOL isCustomData) {
        HJResponse *res = [self createResponse:request responseObject:responseObject];
        // 校验响应数据
        if ([self.delegate respondsToSelector:@selector(client:verifyResponse:forRequest:error:)]) {
            NSString *verifyMessage;
            if (![self.delegate client:self verifyResponse:res forRequest:request error:&verifyMessage]) {
                [self didFinishRequest:request error:verifyMessage];
                failure(verifyMessage);
                return;
            }
        }
        [self didReceiveResponse:res isCustomData:isCustomData forRequest:request];
        [self didFinishRequest:request error:nil];
        success(res);
    };
    
    [self willExecutionRequest:request];
    // 判断是否有自定义数据
    id responseObject = [self getCustomResponse:request];
    if (responseObject) { successHandler(responseObject, YES); }
    // 发起请求
    NSURLSessionDataTask * task = [self.httpManager dataTaskWithRequest:URLRequest uploadProgress:^(NSProgress *uploadProgress) {
        if (request.files) { /* 上传请求更新进度 */
            [self uploadProgress:uploadProgress forRequest:request];
        }
    } downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSString *errorMsg;
            // 如果是服务器响应错误，设置错误码为响应码
            if ([error.userInfo.allKeys containsObject:AFNetworkingOperationFailingURLResponseErrorKey]) {
                NSHTTPURLResponse *res = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                error = [NSError errorWithDomain:error.domain code:res.statusCode userInfo:error.userInfo];
            }
            // 如果responseObject中有值，取出错误信息
            if (responseObject) {
                errorMsg = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            } else {
                errorMsg = [self errorStringWithError:error];
            }
            if ([self.delegate respondsToSelector:@selector(client:request:didReceiveError:)]) {
                NSString *msg = [self.delegate client:self request:request didReceiveError:error];
                // 有自定义错误信息
                if (msg) { errorMsg = msg; }
            }
            [self didFinishRequest:request error:errorMsg];
            failure(errorMsg);
            return;
        }
        successHandler(responseObject, NO);
    }];
    [task resume];
    HJRequestTask *rqeustTask = [HJRequestTask new];
    [rqeustTask addSubtask:task];
    return rqeustTask;
}

#pragma mark - Helpers

/// 创建请求
- (NSMutableURLRequest *)createURLRequest:(HJRequest *)request {
    NSError *error;
    NSMutableURLRequest *URLRequest;
    NSString *method = [self methodNameWithRequest:request];
    NSString *URLString = [[NSURL URLWithString:request.path relativeToURL:self.baseURL] absoluteString];
    AFHTTPRequestSerializer *requestSerializer;
    switch (request.bodyType) {
        case HJRequestBodyTypeFormData:
            requestSerializer = self.httpRequestSerializer;
            break;
        case HJRequestBodyTypeJSON:
            requestSerializer = self.jsonRequestSerializer;
            break;
    }
    if (request.files) {
        URLRequest = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:request.params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (HJRequestFormFile *file in request.files) {
                [formData appendPartWithFileData:file.data name:file.name fileName:file.fileName mimeType:file.mineType];
            }
        } error:&error];
    } else {
        URLRequest = [requestSerializer requestWithMethod:method URLString:URLString parameters:request.params error:&error];
    }
    NSAssert(error == nil, @"创建请求失败");
    request.timeoutInterval = self.timeoutInterval;
    if (request.timeoutInterval > 0) {
        URLRequest.timeoutInterval = request.timeoutInterval;
    }
    return URLRequest;
}

/// 创建请求响应
- (HJResponse *)createResponse:(HJRequest *)request responseObject:(id)responseObject {
    HJResponse *response = [HJResponse new];
    id json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
    response.code = 200;
    response.json = json;
    response.rawData = responseObject;
    if (json == nil) { /* json = nil，代表数据仅仅是一段文字，直接解析字符串 */
        response.data = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        return response;
    }
    NSDictionary *jsonDict = json;
    BOOL isNeedResponseKeyMapping = self.responseKeyMapping != nil;
    for (NSString *key in self.responseKeyMapping.allValues) {
        // 判断响应是否包含必要键
        if (![jsonDict.allKeys containsObject:key]) {
            isNeedResponseKeyMapping = NO;
            break;
        }
    }
    if (isNeedResponseKeyMapping) {
        for (NSString *key in self.responseKeyMapping.allKeys) {
            [response setValue:jsonDict[self.responseKeyMapping[key]] forKey:key];
        }
    } else { response.data = json; }
    
    if (request.responseDataClsArray && request.deserializationPathArray) { /* 解析多个Model */
        NSAssert(request.responseDataClsArray.count == request.deserializationPathArray.count, @"解析类型与解析路径数量不一致");
        NSMutableArray *dataObjects = [NSMutableArray array];
        for (int i = 0; i < request.responseDataClsArray.count; i++) {
            [dataObjects addObject:[self deserializationWithResponseDataCls:request.responseDataClsArray[i]
                                                        deserializationPath:request.deserializationPathArray[i]
                                                                       data:response.data]];
        }
        response.dataObjects = dataObjects;
    } else { /* 解析单个Model */
        response.dataObject = [self deserializationWithResponseDataCls:request.responseDataCls
                                                   deserializationPath:request.deserializationPath
                                                                  data:response.data];
    }
    return response;
}

/// 获取指定Requet请求方式名称
- (NSString *)methodNameWithRequest:(HJRequest *)request {
    switch (request.method) {
        case HJRequestMethodGET: return @"GET";
        case HJRequestMethodPOST: return @"POST";
        case HJRequestMethodPUT: return @"PUT";
        case HJRequestMethodDELETE: return @"DELETE";
    }
}

/// 反序列化数据
- (id)deserializationWithResponseDataCls:(Class)cls deserializationPath:(NSString *)path data:(id)data {
    if (cls == NULL) { return nil; }
    if (path && [data isKindOfClass:[NSDictionary class]]) {
        // 跳到指定路径
        NSArray *paths = [path componentsSeparatedByString:@"."];
        for (NSString *path in paths) {
            data = data[path];
        }
    }
    if ([data isKindOfClass:[NSArray class]]) {
        return [cls mj_objectArrayWithKeyValuesArray:data];
    } else {
        return [cls mj_objectWithKeyValues:data];
    }
}

/// 解析错误消息
- (NSString *)errorStringWithError:(NSError *)error {
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        if (error.code == NSURLErrorNotConnectedToInternet) {
            return @"您似乎已断开与互联网的连接，请检查网络设置";
        } else if (error.code == NSURLErrorTimedOut) {
            return @"您的网络状态似乎不太好，请求超时";
        } else if (error.code == NSURLErrorCancelled) {
            return @"请求已取消";
        }
    }
    return error.localizedDescription;
}

#pragma mark - Plugin

/// 注册插件
- (void)registerPlugin:(id<HJClientPlugin>)plugin {
    [self.plugins addObject:plugin];
}

/// 请求将要执行
- (void)willExecutionRequest:(HJBaseRequest *)request {
    if (self.isPrintLog) {
        if ([request isKindOfClass:[HJRequest class]]) { NSLog(@"开始请求: %@, %@", request, ((HJRequest *)request).params); }
        else { NSLog(@"开始请求: %@", request); }
    }
    if (request.isSubrequest) { return; }
    for (id<HJClientPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(client:willExecutionRequest:)]) {
            [plugin client:self willExecutionRequest:request];
        }
    }
}

/// 获取请求自定义响应
- (id)getCustomResponse:(HJRequest *)request {
    for (id<HJClientPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(client:customResponseForRequest:)]) {
            id data = [plugin client:self customResponseForRequest:request];
            if (data) {
                if (self.isPrintLog) { NSLog(@"请求获取到自定义响应: %@", request); }
                return data;
            }
        }
    }
    return nil;
}

/// 请求接收到数据
- (void)didReceiveResponse:(HJResponse *)response isCustomData:(BOOL)isCustomData forRequest:(HJRequest *)request {
    if (self.isPrintLog) { NSLog(@"请求收到数据: %@", request); }
    if (request.isSubrequest) { return; }
    for (id<HJClientPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(client:didReceiveResponse:isCustomData:forRequest:)]) {
            [plugin client:self didReceiveResponse:response isCustomData:isCustomData forRequest:request];
        }
    }
}

/// 更新下载请求进度
- (void)uploadProgress:(NSProgress *)progress forRequest:(HJRequest *)request {
    if (request.isSubrequest) { return; }
    for (id<HJClientPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(client:uploadProgress:forRequest:)]) {
            [plugin client:self uploadProgress:progress forRequest:request];
        }
    }
}

/// 请求已完成
- (void)didFinishRequest:(HJBaseRequest *)request error:(NSString *)error {
    if (self.isPrintLog) {
        if (error) { NSLog(@"请求完成: %@, %@", request, error); }
        else { NSLog(@"请求完成: %@", request); }
    }
    if (request.isSubrequest) { return; }
    for (id<HJClientPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(client:didFinishRequest:)]) {
            [plugin client:self didFinishRequest:request];
        }
    }
}

#pragma mark - Getter

- (AFHTTPRequestSerializer *)httpRequestSerializer {
    if (!_httpRequestSerializer) {
        _httpRequestSerializer = [AFHTTPRequestSerializer new];
    }
    return _httpRequestSerializer;
}

- (AFJSONRequestSerializer *)jsonRequestSerializer {
    if (!_jsonRequestSerializer) {
        _jsonRequestSerializer = [AFJSONRequestSerializer new];
    }
    return _jsonRequestSerializer;
}

#pragma mark - Init

/// 单例对象
+ (instancetype)shared {
    static id client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[self alloc] init];
    });
    return client;
}

/// 初始化
- (instancetype)init {
    if (self = [super init]) {
        _timeoutInterval = 15;
        
        _httpManager = [AFHTTPSessionManager manager];
        _httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _plugins = [NSMutableArray array];
        _isPrintLog = YES;
    }
    return self;
}

@end
