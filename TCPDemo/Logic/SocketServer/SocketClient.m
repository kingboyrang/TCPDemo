//
//  SocketClient.m
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-4-1.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "SocketClient.h"

@implementation SocketClient

+ (SocketClient *)shareInstance{
    static SocketClient *notificationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notificationManager = [[SocketClient alloc] init];
    });
    return notificationManager;
}

/**
 * 构造
 */
- (id)init{
    if (self=[super init]) {
        connector = [[FTConnector alloc] init];
    }
    return self;
}



/**
 * 连接
 */
- (void)connect:(NSString*) address{
    NSLog(@"will connect");
   
    if (!connector.ftClientSocket) {
        connector.ftClientSocket =[[AsyncSocket alloc] initWithDelegate:connector];
    }
    if (![connector.ftClientSocket isConnected])
    {
        NSError *error = nil;
        [connector.ftClientSocket connectToHost:address onPort:kSocketPORT withTimeout:-1 error:&error];
        
        if (error)
        {
            NSLog(@"connectToHost error %@",error);
            [connector.ftClientSocket disconnect];
        }else{
            
        }
    }
   
}

/**
 * 断开
 */
- (void)disconnect{
    if ([connector.ftClientSocket isConnected])
    {
       [connector.ftClientSocket disconnect];
    }
}
- (FTConnector*)GetConnector{
    return connector;
}

- (void)sendFile:(NSString*)filename{
    [connector sendFile:filename];
}

@end
