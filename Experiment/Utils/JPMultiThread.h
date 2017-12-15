//
//  JPMultiThread.h
//  Experiment
//
//  Created by King on 2017/12/12.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline void onMainThreadAsync(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void onMainThreadSync (void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static inline void onGlobalThreadAsync(void (^block)(void)) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

static inline void onMainThreadDelayExec(NSTimeInterval second, void(^block)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

@interface JPMultiThread : NSObject
@property(nonatomic, strong) NSOperationQueue *currentOperationQueue;

+ (void)execSyncBlock:(void (^)(void))block;
+ (void)execAsynBlock:(void (^)(void))block;

- (void)execSyncBlock:(void (^)(void))block;
- (void)execAsynBlock:(void (^)(void))block;

@end
