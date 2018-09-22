//
//  HJRequest.h
//  Temp
//
//  Created by Haijun on 2018/9/22.
//  Copyright © 2018年 Haijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HJBaseRequest.h"
#import "HJRequestFormFile.h"

typedef NS_ENUM(NSInteger, HJRequestMethod) {
    HJRequestMethodGET = 0,
    HJRequestMethodPOST,
};

@interface HJRequest : HJBaseRequest

/// 请求接口
@property (nonatomic, copy) NSString *path;
/// 参数
@property (nonatomic, strong) NSDictionary *params;
/// 请求方式
@property (nonatomic, assign) HJRequestMethod method;
/// 上传的文件
@property (nonatomic, strong) NSArray<HJRequestFormFile *> *files;

/// 响应数据类型，如果待解析的数据是数组类型，则返回数组
@property (nonatomic, assign) Class responseDataCls;
/// 从指定路径开始反序列化（xxx.xxx）
@property (nonatomic, strong) NSString *deserializationPath;

+ (instancetype)requestWithPath:(NSString *)path;
+ (instancetype)requestWithPath:(NSString *)path method:(HJRequestMethod)method;

@end

