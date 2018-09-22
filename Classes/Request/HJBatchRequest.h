//
//  HJBatchRequest.h
//
//  Created by Haijun on 2018/9/22.
//

#import <Foundation/Foundation.h>
#import "HJBaseRequest.h"
#import "HJRequest.h"

@interface HJBatchRequest : HJBaseRequest

@property (nonatomic, strong) NSArray<HJRequest *> *requests;

@end
