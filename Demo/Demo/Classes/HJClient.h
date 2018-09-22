//
//  HJClient.h
//
//  Created by Haijun on 2018/9/22.
//

#import <Foundation/Foundation.h>
#import "HJRequest.h"
#import "HJResponse.h"
#import "HJBatchRequest.h"
#import "HJClientPlugin.h"

typedef void(^HJRequestSuccessBlock)(HJResponse *response);
typedef void(^HJRequestFailureBlock)(NSString *error);

@class HJClient;

@protocol HJClientDelegate <NSObject>

/// 创建请求之前调用，可在此方法附加额外参数
- (HJRequest *)client:(HJClient *)client prepareRequest:(HJRequest *)request;
/// 执行请求之前调用，可在此方法中给请求头附加参数
- (NSMutableURLRequest *)client:(HJClient *)client prepareURLRequest:(NSMutableURLRequest *)request;
/// 检验响应数据，返回值为空 = 验证通过
- (NSString *)client:(HJClient *)client verifyResponse:(HJResponse *)response forRequest:(HJRequest *)request;

@end

@interface HJClient : NSObject

+ (instancetype)shared;

/// 是否打印日志，默认 = YES
@property (nonatomic, assign) BOOL isPrintLog;

/// Delegate
@property (nonatomic, weak) id<HJClientDelegate> delegate;

/// BaseURL
@property (nonatomic, strong) NSURL *baseURL;

/// 响应对象键值映射，@{@"message":@"xxx", @"code":@"xxx", @"data":@"xxx"}
@property (nonatomic, strong) NSDictionary *responseKeyMapping;

/// 注册插件
- (void)registerPlugin:(id<HJClientPlugin>)plugin;

/// 入列请求
- (void)enqueueRequest:(HJBaseRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure;

/// 入列请求
+ (void)enqueueRequest:(HJBaseRequest *)request success:(HJRequestSuccessBlock)success failure:(HJRequestFailureBlock)failure;

@end
