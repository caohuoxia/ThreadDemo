//
//  ViewController.m
//  ThreadDemo
//
//  Created by admin on 16/4/12.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSInteger ticketCount;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ticketCount = 50;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadExitNotice) name:NSThreadWillExitNotification object:nil];
    //新建两个子线程（代表两个窗口同时销售门票）
    NSThread * window1 = [[NSThread alloc]initWithTarget:self selector:@selector(thread1) object:nil];
    [window1 start];
    NSThread * window2 = [[NSThread alloc]initWithTarget:self selector:@selector(thread2) object:nil];
    [window2 start];
    
    [self performSelector:@selector(saleTicket) onThread:window1 withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(saleTicket) onThread:window2 withObject:nil waitUntilDone:NO];
//    NSThread *thread_beijing = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
//    thread_beijing.name = @"北京售票窗口";
//    [thread_beijing start];
//    NSThread *thread_guangzhou = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
//    thread_guangzhou.name = @"广州售票窗口";
//    [thread_guangzhou start];
}

- (void)thread1 {
    [NSThread currentThread].name = @"北京售票窗口";
    NSRunLoop * runLoop1 = [NSRunLoop currentRunLoop];
    [runLoop1 runUntilDate:[NSDate date]]; //一直运行
}
- (void)thread2 {
    [NSThread currentThread].name = @"广州售票窗口";
    NSRunLoop * runLoop2 = [NSRunLoop currentRunLoop];
    [runLoop2 runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10.0]]; //自定义运行时间
}

- (void)threadExitNotice{
    
}

//线程启动后，执行saleTicket，执行完毕后就会退出，为了模拟持续售票的过程，我们需要给它加一个循环
- (void)saleTicket {
    while (1) {
        @synchronized(self) {
            //如果还有票，继续售卖
            if (ticketCount > 0) {
                ticketCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", ticketCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
            }
            //如果已卖完，关闭售票窗口
            else {
                if ([NSThread currentThread].isCancelled)
                {
                    [NSThread exit];
                    break;
                }
                else
                {
                    NSLog(@"售卖完毕");
                    //给当前线程标记为取消状态
                    [[NSThread currentThread] cancel];
                    //停止当前线程的runLoop
                    CFRunLoopStop(CFRunLoopGetCurrent());
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
