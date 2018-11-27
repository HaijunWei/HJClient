//
//  HJBatchRequest.h
//
//  Created by Haijun on 2018/9/22.
//

#import <Foundation/Foundation.h>
#import "HJBaseRequest.h"

@interface HJBatchRequest : HJBaseRequest

+ (instancetype)requestWithRequests:(NSArray *)requests;

@property (nonatomic, strong) NSArray<HJBaseRequest *> *requests;

@end
