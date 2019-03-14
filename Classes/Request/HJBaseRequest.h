//
//  HJBaseRequest.h
//
//  Created by Haijun on 2018/9/22.
//

#import <Foundation/Foundation.h>

@interface HJBaseRequest : NSObject

/// 自定义信息
@property (nonatomic, strong) NSMutableDictionary *userInfo;
/// 是否属于某个请求的子请求
@property (nonatomic, assign) BOOL isSubrequest;

@end
