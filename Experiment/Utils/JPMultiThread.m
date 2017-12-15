//
//  JPMultiThread.m
//  Experiment
//
//  Created by King on 2017/12/12.
//  Copyright © 2017年 Rick. All rights reserved.
//

#import "JPMultiThread.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>
#import <pthread.h>

#define  ITERATIONS (1024*1024*32)
//static unsigned long long disp=0, land=0;
#if OS_OBJECT_USE_OBJC
#define JPDispatchQueueRelease(__v)
#else
#define JPDispatchQueueRelease(__v) (dispatch_release(__v));
#endif

@interface JPMultiThread() {
    dispatch_queue_t _queue;
}

@end

@implementation JPMultiThread

+ (JPMultiThread *)synchronizeQueue {
    static JPMultiThread * _multiThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _multiThread = [[self alloc] init];
    });
    return _multiThread;
}

- (void)dealloc {
    if (_queue) {
        JPDispatchQueueRelease(_queue);
        _queue = 0x00;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self dispatchAsync];
        [self test];
    }
    return self;
}

- (NSString *)randomBitString {
    u_int8_t length = 10;
    char data[length];
    for (int x = 0; x< length; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}

-(void)dispatchAsync {
    // 创建串行队列
    NSString *identifier = [@"com.rick.Experiment"  stringByAppendingString:[self randomBitString]];
    _queue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t dQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_set_target_queue(_queue, dQueue);
//    dispatch_async(_queue, ^{
//        block();
//    });
}

- (void)NSOperationQueueSync {
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    operationQueue.maxConcurrentOperationCount = 1;
}

//- (void)execSyncBlock:(void (^)(void))block {
//    if (NSOperationQueue.currentQueue == self.currentOperationQueue) {
//        block();
//    } else {
//        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
//        [self.currentOperationQueue addOperations:@[operation] waitUntilFinished:YES];
//    }
//}

- (void)test {
    double then, now;
    unsigned int i;
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    OSSpinLock spinlock = OS_SPINLOCK_INIT;
    
    // 1.NSLock
    NSLock *lock = [NSLock new];
    then = CFAbsoluteTimeGetCurrent();
    for(i=0;i<ITERATIONS;++i)
    {
        [lock lock];
        [lock unlock];
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("NSLock: %f sec\n", now-then);
    
    // 2.NSLock_IMP
    typedef void (*func)(id, SEL);
    SEL lockSEL = @selector(lock);
    SEL unlockSEL = @selector(unlock);
    func lockFunc = (void (*)(id, SEL))[lock methodForSelector : lockSEL];
    func unlockFunc = (void (*)(id, SEL))[lock methodForSelector : unlockSEL];
    
    then = CFAbsoluteTimeGetCurrent();
    for (i = 0; i < ITERATIONS; ++i) {
        lockFunc(lock, lockSEL);
        unlockFunc(lock, unlockSEL);
    }
    
    now = CFAbsoluteTimeGetCurrent();
    printf("NSLock_IMP: %f sec\n", now-then);
    
    // 3.pthread_mutex
    then = CFAbsoluteTimeGetCurrent();
    for(i = 0;i < ITERATIONS;++i)
    {
        pthread_mutex_lock(&mutex);
        pthread_mutex_unlock(&mutex);
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("pthread_mutex: %f sec\n", now-then);
    
    // 4.NSCondition
    NSCondition *condition = [[NSCondition alloc] init];
    then = CFAbsoluteTimeGetCurrent();
    for (i = 0; i < ITERATIONS; ++i) {
        [condition lock];
        [condition unlock];
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("NSCondition: %f sec\n", now-then);;
    
    // 5.NSConditionLock
    NSConditionLock *conditionLock = [[NSConditionLock alloc] init];
    then = CFAbsoluteTimeGetCurrent();
    for (i = 0; i < ITERATIONS; ++i) {
        [conditionLock lock];
        [conditionLock unlock];
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("NSConditionLock: %f sec\n", now-then);
    
    // 6.NSRecursiveLock
    NSRecursiveLock *recursiveLock = [[NSRecursiveLock alloc] init];
    then = CFAbsoluteTimeGetCurrent();
    for (i = 0; i < ITERATIONS; ++i) {
        [recursiveLock lock];
        [recursiveLock unlock];
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("NSRecursiveLock: %f sec\n", now - then);
    
    
    //7.OSSpinlock
    then = CFAbsoluteTimeGetCurrent();
    for(i=0;i<ITERATIONS;++i)
    {
        OSSpinLockLock(&spinlock);
        OSSpinLockUnlock(&spinlock);
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("OSSpinlock: %f sec\n", now-then);
    
    id obj = [NSObject new];
    //8.OSSpinlock
    then = CFAbsoluteTimeGetCurrent();
    for(i=0;i<ITERATIONS;++i)
    {
        @synchronized(obj)
        {
        }
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("@synchronized: %f sec\n", now-then);
    
    // 9.dispatch_barrier_async
    dispatch_queue_t queue = dispatch_queue_create("com.qq.ksnow", DISPATCH_QUEUE_CONCURRENT);
    
    then = CFAbsoluteTimeGetCurrent();
    for (i = 0; i < ITERATIONS; ++i) {
        dispatch_barrier_async(queue, ^{});
    }
    now = CFAbsoluteTimeGetCurrent();
    printf("@dispatch_barrier_async: %f sec\n", now - then);
}

#pragma mark - sync
+ (void)execSyncBlock:(void (^)(void))block {
    [[JPMultiThread synchronizeQueue] execSyncBlock:block];
}

- (void)execSyncBlock:(void (^)(void))block {
    dispatch_sync(_queue, ^{
        block();
    });
}

#pragma mark -async
+ (void)execAsynBlock:(void (^)(void))block {
    [[JPMultiThread synchronizeQueue] execAsynBlock:block];
}

- (void)execAsynBlock:(void (^)(void))block {
    dispatch_async(_queue, ^{
        block();
    });
}
@end
