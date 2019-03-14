//
//  HJBaseRequest.m
//
//  Created by Haijun on 2018/9/22.
//

#import "HJBaseRequest.h"

@implementation HJBaseRequest

- (instancetype)init {
    if (self = [super init]) {
        _userInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

@end
