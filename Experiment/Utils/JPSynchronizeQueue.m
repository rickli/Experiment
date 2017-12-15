//
//  JPSynchronizeQueue.m
//  Experiment
//
//  Created by King on 2017/12/13.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import "JPSynchronizeQueue.h"

@implementation JPSynchronizeQueue

+(JPSynchronizeQueue *)synchronizeQueue {
    static JPSynchronizeQueue *_jpSynchronizeQueue = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _jpSynchronizeQueue = [[self alloc] init];
    });
    return _jpSynchronizeQueue;
}

- (instancetype)init {
    if (self = [super init]) {
        self.maxConcurrentOperationCount = 1;
    }
    return self;
}

+ (void)cancleAllOperations {
    [[JPSynchronizeQueue synchronizeQueue] cancelAllOperations];
}

#pragma mark -sync
+ (void)execSyncBlock:(void (^)(void))block {
    [[JPSynchronizeQueue synchronizeQueue] execSyncBlock:block];
}

- (void)execSyncBlock:(void (^)(void))block {
    if (NSOperationQueue.currentQueue == self) {
        block();
    } else {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
        [self addOperations:@[operation] waitUntilFinished:YES];
    }
}

#pragma mark - async
+ (NSOperation *)execAsyncBlock:(void (^)(void))block {
    return [[JPSynchronizeQueue synchronizeQueue] execAsynBlock:block];
}

- (NSOperation *)execAsynBlock:(void (^)(void))block {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
    [self addOperation:operation];
    return operation;
}
@end
