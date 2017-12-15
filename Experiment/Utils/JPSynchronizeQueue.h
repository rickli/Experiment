//
//  JPSynchronizeQueue.h
//  Experiment
//
//  Created by King on 2017/12/13.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPSynchronizeQueue : NSOperationQueue
+ (void)execSyncBlock:(void (^)(void))block;
+ (NSOperation *)execAsyncBlock:(void (^)(void))block;
+ (void)cancleAllOperations;

- (void)execSyncBlock:(void (^)(void))block;
- (NSOperation *)execAsynBlock:(void (^)(void))block;
@end
