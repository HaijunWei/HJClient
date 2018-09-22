//
//  HJResponse.h
//  Temp
//
//  Created by Haijun on 2018/9/22.
//  Copyright © 2018年 Haijun. All rights reserved.
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

/// 原始响应数据
@property (nonatomic, strong) id rawData;

@end
