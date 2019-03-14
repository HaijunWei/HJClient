//
//  HJRequestTask.m
//
//  Created by Haijun on 2018/11/25.
//

#import "HJRequestTask.h"

@interface HJRequestTask ()

@property (nonatomic, strong) NSMutableArray<id<HJTaskCancelable>> *tasks;

@end

@implementation HJRequestTask

- (instancetype)init {
    if (self = [super init]) {
        _tasks = [NSMutableArray array];
    }
    return self;
}

- (void)cancel {
    for (id<HJTaskCancelable> task in self.tasks) {
        [task cancel];
    }
    _isCanceled = YES;
}

- (void)addSubtask:(id<HJTaskCancelable>)task {
    [self.tasks addObject:task];
}

- (void)removeSubtask:(id<HJTaskCancelable>)task {
    [self.tasks removeObject:task];
}

@end
