//
//  HJClient.m
//
//  Created by Haijun on 2018/9/22.
//

#import "HJClient.h"
#import <MJExtension/MJExtension.h>
#import <AFNetworking/AFNetworking.h>

@interface HJClient ()

@property (nonatomic, strong) AFHTTPSessionManager *httpManager;
@property (nonatomic, strong) NSMutableArray<id<HJClientPlugin>> *plugins;

@end

@implementation HJClient

#pragma mark - Class Method

+ (void)enqueueRequest:(HJBaseRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
    [[self shared] enqueueRequest:request success:success failure:failure];
}

#pragma mark - Reuqest

/// 入列请求
- (void)enqueueRequest:(HJBaseRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
    if ([request isKindOfClass:[HJRequest class]]) {
        [self executionRequest:(HJRequest *)request success:success failure:failure];
    } else {
        [self executionBatchReuqest:(HJBatchRequest *)request success:success failure:failure];
    }
}

/// 执行单个请求
- (NSURLSessionDataTask *)executionRequest:(HJRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
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
        if (!res) {
            [self didFinishRequest:request error:@"解析数据出错"];
            failure(@"解析数据出错");
            return;
        }
        // 校验响应数据
        if ([self.delegate respondsToSelector:@selector(client:verifyResponse:forRequest:)]) {
            NSString *verifyMessage = [self.delegate client:self verifyResponse:res forRequest:request];
            if (verifyMessage) {
                [self didFinishRequest:request error:verifyMessage];
                failure(verifyMessage);
                return;
            }
        }
        [self didReceiveResponse:res isCustomData:YES forRequest:request];
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
            [self didFinishRequest:request error:error.localizedDescription];
            failure(error.localizedDescription);
            return;
        }
        successHandler(responseObject, NO);
    }];
    [task resume];
    return task;
}

/// 执行并发请求
- (void)executionBatchReuqest:(HJBatchRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure {
    [self willExecutionRequest:request];
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray<NSURLSessionDataTask *> *tasks = [NSMutableArray array];
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < request.requests.count; i++) { [result addObject:@(i)]; }
    __block NSString *_error;
    void (^completionHanlder)(HJResponse *, NSInteger) = ^(HJResponse *response, NSInteger index) {
        if (response) {
            result[index] = response;
            return;
        }
        /// 某个任务发生错误，结束全部任务
        for (NSURLSessionDataTask *task in tasks) { [task cancel]; }
    };
    for (int i = 0; i < request.requests.count; i++) {
        HJRequest *subRequest = request.requests[i];
        dispatch_group_enter(group);
        NSURLSessionDataTask *task = [self executionRequest:subRequest success:^(HJResponse *response) {
            completionHanlder(response, i);
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            _error = error;
            completionHanlder(nil, i);
            dispatch_group_leave(group);
        }];
        [tasks addObject:task];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self didFinishRequest:request error:_error];
        if (_error) {
            failure(_error);
            return;
        }
        HJResponse *response = [HJResponse new];
        response.dataObject = result;
        success(response);
    });
}

#pragma mark - Helpers

/// 创建请求
- (NSMutableURLRequest *)createURLRequest:(HJRequest *)request {
    NSError *error;
    NSMutableURLRequest *URLRequest;
    NSString *method = [self methodNameWithRequest:request];
    NSString *URLString = [[NSURL URLWithString:request.path relativeToURL:self.baseURL] absoluteString];
    if (request.files) {
        URLRequest = [self.httpManager.requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:request.params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (HJRequestFormFile *file in request.files) {
                [formData appendPartWithFileData:file.data name:file.name fileName:file.fileName mimeType:file.mineType];
            }
        } error:&error];
    } else {
        URLRequest = [self.httpManager.requestSerializer requestWithMethod:method URLString:URLString parameters:request.params error:&error];
    }
    NSAssert(error == nil, @"创建请求失败");
    return URLRequest;
}

/// 创建请求响应
- (HJResponse *)createResponse:(HJRequest *)request responseObject:(id)responseObject {
    NSAssert(self.responseKeyMapping, @"responseKeyMapping 未设值");
    id json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
    // 判断响应是否为json数据
    if (!(json && [json isKindOfClass:[NSDictionary class]])) { return nil; }
    NSDictionary *jsonDict = json;
    for (NSString *key in self.responseKeyMapping.allValues) {
        // 判断响应是否包含必要键
        if (![jsonDict.allKeys containsObject:key]) { return nil; }
    }
    HJResponse *response = [HJResponse new];
    response.json = jsonDict;
    for (NSString *key in self.responseKeyMapping.allKeys) {
        [response setValue:jsonDict[self.responseKeyMapping[key]] forKey:key];
    }
    response.rawData = responseObject;
    response.dataObject = [self deserializationWithRequest:request data:response.data];
    return response;
}

/// 获取指定Requet请求方式名称
- (NSString *)methodNameWithRequest:(HJRequest *)request {
    switch (request.method) {
            case HJRequestMethodGET: return @"GET";
            case HJRequestMethodPOST: return @"POST";
    }
}

/// 反序列化数据
- (id)deserializationWithRequest:(HJRequest *)request data:(id)data {
    if (request.responseDataCls == NULL) { return nil; }

    if (request.deserializationPath && [data isKindOfClass:[NSDictionary class]]) {
        // 跳到指定路径
        NSArray *paths = [request.deserializationPath componentsSeparatedByString:@"."];
        for (NSString *path in paths) {
            data = data[path];
        }
    }
    if ([data isKindOfClass:[NSArray class]]) {
        return [request.responseDataCls mj_objectArrayWithKeyValuesArray:data];
    } else {
        return [request.responseDataCls mj_objectWithKeyValues:data];
    }
}

#pragma mark - Plugin

/// 注册插件
- (void)registerPlugin:(id<HJClientPlugin>)plugin {
    [self.plugins addObject:plugin];
}

/// 请求将要执行
- (void)willExecutionRequest:(HJBaseRequest *)request {
    if (self.isPrintLog) { NSLog(@"开始请求: %@", request); }
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
    for (id<HJClientPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(client:didReceiveResponse:isCustomData:forRequest:)]) {
            [plugin client:self didReceiveResponse:response isCustomData:isCustomData forRequest:request];
        }
    }
}

/// 更新下载请求进度
- (void)uploadProgress:(NSProgress *)progress forRequest:(HJRequest *)request {
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
    for (id<HJClientPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(client:didFinishRequest:)]) {
            [plugin client:self didFinishRequest:request];
        }
    }
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
        _httpManager = [AFHTTPSessionManager manager];
        _httpManager.requestSerializer.timeoutInterval = 15;
        _httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];

        _plugins = [NSMutableArray array];
        _isPrintLog = YES;
    }
    return self;
}

@end
