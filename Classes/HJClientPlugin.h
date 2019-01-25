//
//  HJClientPlugin.h
//
//  Created by Haijun on 2018/9/22.
//

#import <Foundation/Foundation.h>

@class HJClient, HJBaseRequest, HJRequest, HJResponse;

@protocol HJClientPlugin <NSObject>

@optional
/// 将要执行请求
- (void)client:(HJClient *)client willExecutionRequest:(HJBaseRequest *)request;

/// 自定义请求响应，如果此方法有返回，不会去请求服务器内容
- (id)client:(HJClient *)client customResponseForRequest:(HJRequest *)request;

/// 请求出错时，可在此方法中自定义响应数据
- (id)client:(HJClient *)client customResponseOnErrorForRequest:(HJRequest *)request;

/// 收到响应
- (void)client:(HJClient *)client didReceiveResponse:(HJResponse *)response isCustomData:(BOOL)isCustomData forRequest:(HJRequest *)request;

/// 上传进度
- (void)client:(HJClient *)client uploadProgress:(NSProgress *)progress forRequest:(HJRequest *)request;

/// 完成请求
- (void)client:(HJClient *)client didFinishRequest:(HJBaseRequest *)request;

@end
