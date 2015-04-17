//
//  Sender.h
//  ImageTransfer
//
//  Created by ly on 13-7-8.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "FTConnector.h"
#import "Global.h"


@interface SocketServer : NSObject<AsyncSocketDelegate>{
    BOOL isRunning;
//    NSMutableData *_tmpData;
//    BOOL isReadHead;
//    BOOL _receiveFile;
    
    AsyncSocket *asyncSocket;
    
    NSMutableArray* connetorList;
}

+ (SocketServer *)shareInstance;


//@property (nonatomic,strong) AsyncSocket *clientSocket;


//是否在监听中
- (BOOL)isListen;

//开始监听
- (void)startListen;

//监听断开
- (void)stopListen;

/**
 * @brief 返回socket客户端列表中的第一个Connector
 */
- (FTConnector*)getFirstConnector;

/**
 * @brief 发送文件
 * @param filename 文件名称，全路径
 */
- (void)sendFile:(NSString*)filename;


@end
