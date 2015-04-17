//
//  SocketClient.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-4-1.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "AsyncSocket.h"
#import "FTConnector.h"

@interface SocketClient : NSObject{
    FTConnector *connector;//<! 管理收发数据和连接状况
}

@property (nonatomic, retain) NSString       *remoteAddress; // 远程地址

+ (SocketClient *)shareInstance;
- (void)connect:(NSString*) address;//连接
- (void)disconnect;//断开

- (void)sendFile:(NSString*)filename;

- (FTConnector*)GetConnector;
@end
