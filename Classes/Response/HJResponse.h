//
//  HJResponse.h
//
//  Created by Haijun on 2018/9/22.
//

#import <Foundation/Foundation.h>

@interface HJResponse : NSObject

/// 响应数据
@property (nonatomic, strong) id data;
/// 响应消息
@property (nonatomic, copy) NSString *message;
/// 响应代码
@property (nonatomic, assign) NSInteger code;
/// 原始JSON
@property (nonatomic, strong) id json;
/// 已解析的数据
@property (nonatomic, strong) id dataObject;
/// 如果解析多个Model，用此属性接收
@property (nonatomic, strong) NSArray *dataObjects;

/// 原始响应数据
@property (nonatomic, strong) id rawData;

@end
