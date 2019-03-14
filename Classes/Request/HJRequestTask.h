//
//  HJRequestTask.h
//
//  Created by Haijun on 2018/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HJTaskCancelable <NSObject>

- (void)cancel;

@end

@interface NSURLSessionTask (HJTaskCancelable) <HJTaskCancelable>
@end

@interface HJRequestTask : NSObject <HJTaskCancelable>

@property (nonatomic, assign, readonly) BOOL isCanceled;

- (void)addSubtask:(id<HJTaskCancelable>)task;
- (void)removeSubtask:(id<HJTaskCancelable>)task;

@end

NS_ASSUME_NONNULL_END
