//
//  Sender.m
//  ImageTransfer
//
//  Created by ly on 13-7-8.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import "SocketServer.h"



@implementation SocketServer



+ (SocketServer *)shareInstance{
    static SocketServer *notificationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notificationManager = [[SocketServer alloc] init];
    });
    return notificationManager;
}

- (id)init{
    if (self=[super init]) {
         asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        [asyncSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        
        connetorList = [NSMutableArray arrayWithCapacity:10];

        isRunning = NO;
    }
    return self;
}

- (BOOL)isListen{
    return isRunning;
}


//开始监听
- (void)startListen{
    if (!isRunning){
        NSError *error = nil;
        [asyncSocket acceptOnPort:kSocketPORT error:&error];
        NSLog(@"acceptOnPort error = %@",error);
        isRunning = YES;
    }
}

//监听断开
- (void)stopListen{
    if (isRunning){
        //断开所有客户端连接
        for (FTConnector *connector in connetorList) {
            [connector disconnect];
        }
        [connetorList removeAllObjects];
        
        [asyncSocket disconnect];
        isRunning = NO;
    }
}


/**
 * @brief 返回socket客户端列表中的第一个Connector
 */
- (FTConnector*)getFirstConnector{
    if (connetorList.count >0) {
        NSLog(@" connetorList =%@",((FTConnector*)[connetorList objectAtIndex:0]).ftClientSocket);
        return [connetorList objectAtIndex:0];
    }
    return nil;
}

/**
 * @brief 发送文件
 * @param filename 文件名称，全路径
 */
- (void)sendFile:(NSString*)filename{
    
}



#pragma mark - Delegate
/* socket发生错误时,socket关闭；连接时可能被调用，主要用于socket连接错误时读取错误发生前的数据*/
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"Socket disconnect with error:\n%@\n", err);
}

/*socket断开连接后被调用，你调用disconnect方法，还没有断开连接，只有调用这个方法时，才断开连接；可以在这个方法中release 一个 socket*/
- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserDisconnection object:nil];
    NSLog(@"onSocketDidDisconnect");
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    /* 开始从 socket 中读取字节流 */
    // P.S. 每次收到回调后立即读取数据会断开连接，所以采用延迟一秒后再读数据
    
    
 
//    double delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [[SocketPacketRead shareInstance] clear];//初始化
//        [self.clientSocket readDataToLength:1 withTimeout:-1  tag:KDataTagPackId];
//    });
}

/*监听到新连接时被调用，这个新socket的代理和listen socket相同*/
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"didAcceptNewSocket  =%@",newSocket);
 
    //新建立一个connector 代表一个客户端
    FTConnector* connector = [[FTConnector alloc] init];
    [newSocket setDelegate:connector];
    connector.ftClientSocket = newSocket;
    [connetorList addObject:connector];
    
    
    //NSString *homePath=NSHomeDirectory();
    //NSString *filePath=[homePath stringByAppendingFormat:@"/Documents/127658767_14282139143141n.jpg"];
    //[connector sendFile:filePath];
    
//    self.clientSocket=newSocket;
    //表示有用户连接通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewIPConnection object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:newSocket.connectedHost,@"host",[NSNumber numberWithInteger:newSocket.connectedPort],@"port", nil]];
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"Server wantsRunLoopForNewSocket:%@",newSocket);
    return [NSRunLoop currentRunLoop];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{
    NSLog(@"SonSocketWillConnect");
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
    NSLog(@"Socket write data with tag: %ld", tag);
}

- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"didWritePartialDataOfLength tag: %ld", tag);
}


- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"didReadPartialDataOfLength tag: %ld", tag);
    //[self.clientSocket readDataToLength:2 withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
 
    NSLog(@"didReadData tag: %ld", tag);
}


@end
