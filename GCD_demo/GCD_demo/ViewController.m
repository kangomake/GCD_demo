//
//  ViewController.m
//  GCD_demo
//
//  Created by gcr on 2019/7/31.
//  Copyright © 2019 teamwork. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)GCDDemo{
    
    //GCD死锁
    /*
     **串行和并行都是相对于队列而言的 **
     -队列（负责调度任务）
     -串行队列：一个接一个的调度任务
     -并发队列：可以同时调度多个任务
     
     在使用GCD的时候，我们会把需要处理的任务放到Block中，然后将任务追加到相应的队列里面，这个队列，叫做Dispatch Queue。
     队列一般存在于两种Dispatch Queue，
     一种是要等待上一个执行完，再执行下一个的Serial Dispatch Queue，这叫做串行队列；
     另一种，则是不需要上一个执行完，就能执行下一个的Concurrent Dispatch Queue，叫做并行队列。
     这两种，均遵循FIFO原则,也就是先进先出原则。
     
     串行与并行针对的是队列，而同步与异步，针对的则是线程。
     最大的区别在于，同步线程要阻塞当前线程，必须要等待同步线程中的任务执行完，返回以后，才能继续执行下一任务；而异步线程则是不用等待。
     
     
     *GCD API很多，这里仅介绍本文用到的。
     
     1.系统标准提供的两个队列
     
     // 全局队列，一个特殊的并行队列
     dispatch_get_global_queue
     // 主队列，在主线程中运行，因为主线程只有一个，所以这是一个特殊的串行队列
     dispatch_get_main_queue
     
     2.除此之外，还可以自己生成队列
     // 从DISPATCH_QUEUE_SERIAL看出，这是串行队列
     dispatch_queue_create("com.demo.serialQueue", DISPATCH_QUEUE_SERIAL)
     // 同理，这是一个并行队列
     dispatch_queue_create("com.demo.concurrentQueue", DISPATCH_QUEUE_CONCURRENT)
     3.同步与异步线程的创建：
     dispatch_sync(..., ^(block)) // 同步线程
     dispatch_async(..., ^(block)) // 异步线程
     */
    
    //会造成死锁
    /*
     dispatch_sync表示是一个同步线程；
     dispatch_get_main_queue表示运行在主线程中的主队列；
     任务2是同步线程的任务。
     任务3需要等待任务2结束之后再执行.
     
     */
    
    //    NSLog(@"1");
    //    dispatch_sync(dispatch_get_main_queue(), ^{
    //        NSLog(@"2");
    //    });
    //    NSLog(@"3");
    
    /*
     首先说明一点，主队列属于串行队列，串行队列中只有一个线程。
     在主线程中正在执行时，执行到sync任务时会卡住主线程，并向主队列派发一个任务。这个任务想要被执行，需要主线程正在执行的代码执行完成才能被执行，而主线程此时正在被sync任务卡住，所以不能继续往下执行，当前被执行的代码就一直不能被执行下去。这样造成了一个等待问题，任务执行不下去就会死锁。
     
     并行队列不会造成死锁的原因是，虽然在当前并行队列的线程中卡住当前线程，但是并行队列派发sync任务的时候可以派发到其他线程中。并行队列是存在多个线程的，所以不会造成死锁。
     
     为什么async不会造成死锁，因为async不会卡住当前线程。假设在串行队列中，向串行队列中添加一个async任务，这个任务不会卡当前队列的执行，而是继续向下执行。执行完下面的代码后，再执行async任务。这也就是为什么在并行队列中，同一个方法中的async代码要比下面代码执行晚的原因。
     
     并行队列是存在多个线程的。这句话你是理解错了吧？并行队列并不会默认开启多个线程，还是一个线程，只有dispatch_async才能开启多线程。
     
     
     */
    
    
    
    //不会造成死锁
    /*
     dispatch_sync表示是一个同步线程；
     dispatch_get_global_queue全局队列，一个特殊的并行队列；
     */
    
    NSLog(@"1");
    dispatch_sync(dispatch_get_global_queue(0,0), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
    
}

#pragma mark - 任务+队列 相关方法
/**
 * 同步执行 + 并发队列
 * 特点：在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncConcurrent {
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    
}

//

/**
 * 异步执行 + 并发队列
 * 特点：可以开启多个线程，任务交替（同时）执行。
 */
- (void)asyncConcurrent {
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
}


/**
 * 同步执行 + 串行队列
 * 特点：不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void)syncSerial {
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testqueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"syncSerial---end");
    
}



/**
 * 异步执行 + 串行队列
 * 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void)asyncSerial {
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testqueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
}

//

/**
 * 同步执行 + 主队列
 * 特点(主线程调用)：互等卡主不执行。
 * 特点(其他线程调用)：不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncMain {
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"main_end");
    
    
}


/**
 * 异步执行 + 主队列
 * 特点：只在主线程中执行任务，执行完一个任务，再执行下一个任务
 */
- (void)asyncMain{
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
}


#pragma mark - 线程间通信

/**
 * 线程间通信
 */
- (void)communication {
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 异步追加任务
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
        
        // 回到主线程
        dispatch_async(mainQueue, ^{
            // 追加在主线程中执行的任务
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
    
    
}

#pragma mark - GCD 其他相关方法

/**
 * 栅栏方法 dispatch_barrier_async
 */
- (void)barrier {
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testqueue",DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_barrier_async(queue, ^{
        // 追加任务 barrier
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
        }
    });
    
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务4
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
}

/**
 * 延时执行方法 dispatch_after
 */
- (void)after {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"after--%@",[NSThread currentThread]);
    });
    
}

/**
 * 一次性代码（只执行一次）dispatch_once
 */
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行1次的代码(这里面默认是线程安全的)
    });
    
}

/**
 * 快速迭代方法 dispatch_apply
 */
- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
        
    });
    
    NSLog(@"apply__end");
}

#pragma mark - dispatch_group 队列组

/**
 * 队列组 dispatch_group_notify
 */
- (void)groupNotify {
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务1、任务2都执行完毕后，回到主线程执行下边任务
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
        NSLog(@"group---end");
    });
    
}



#pragma mark --- 多线程

- (void)dispatch_group{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"request_1");
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"request_2");
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"request_3");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //界面刷新
        NSLog(@"任务均完成，刷新界面");
    });
    
}




@end
