//
//  HJRequest.h
//
//  Created by Haijun on 2018/9/22.
//

#import <Foundation/Foundation.h>
#import "HJBaseRequest.h"
#import "HJRequestFormFile.h"

typedef NS_ENUM(NSInteger, HJRequestMethod) {
    HJRequestMethodGET = 0,
    HJRequestMethodPOST,
    HJRequestMethodPUT,
    HJRequestMethodDELETE
};

typedef NS_ENUM(NSInteger, HJRequestBodyType) {
    /* key-value数据格式 */
    HJRequestBodyTypeFormData = 0,
    /* JSON数据格式 */
    HJRequestBodyTypeJSON,
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
/// 请求超时时间
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/// 提交数据类型
@property (nonatomic, assign) HJRequestBodyType bodyType;

/// 解析多个Model，Model类型
@property (nonatomic, strong) NSArray<Class> *responseDataClsArray;
/// 解析多个Model，解析路径
@property (nonatomic, strong) NSArray<NSString *> *deserializationPathArray;

+ (instancetype)requestWithPath:(NSString *)path;
+ (instancetype)requestWithPath:(NSString *)path method:(HJRequestMethod)method;
+ (instancetype)requestWithPath:(NSString *)path method:(HJRequestMethod)method responseDataCls:(Class)responseDataCls;
+ (instancetype)requestWithPath:(NSString *)path
                         method:(HJRequestMethod)method
            deserializationPath:(NSString *)deserializationPath
                responseDataCls:(Class)responseDataCls;

+ (instancetype)GET:(NSString *)path responseDataCls:(Class)responseDataCls;
+ (instancetype)GET:(NSString *)path deserializationPath:(NSString *)deserializationPath responseDataCls:(Class)responseDataCls;

+ (instancetype)POST:(NSString *)path responseDataCls:(Class)responseDataCls;
+ (instancetype)POST:(NSString *)path deserializationPath:(NSString *)deserializationPath responseDataCls:(Class)responseDataCls;

@end

