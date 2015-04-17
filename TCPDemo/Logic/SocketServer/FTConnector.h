//
//  FTConnector.h
//  TCPDemo
//
//  Created by bolin on 15-4-5.
//  Copyright (c) 2015年 com.chuzhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "Global.h"

#import "BaseDataPack.h"

@protocol FTConnectorDelegate <NSObject>
//正在读取的数据包
- (void)readSocketDataPack:(BaseDataPack*)dataPack;
//正在写入的数据包
- (void)writeSocketDataPack:(BaseDataPack*)dataPack;
@end

@interface FTConnector : NSObject<AsyncSocketDelegate>{
    //AsyncSocket *ftClientSocket;
    NSMutableArray* dataPackList; //<! 待发送报文列表
    BaseDataPack* sendingDataPack; //<! 当前正在发送报文
    BaseDataPack* readingDataPack; //<! 当前正在读取的报文
}
@property (nonatomic,assign) id<FTConnectorDelegate> delegate;
@property (retain,nonatomic) AsyncSocket* ftClientSocket;

@property (nonatomic,strong) NSString   *sendingFileName; //<! 待传送的文件名，文件全路径

//@property (retain,nonatomic) NSMutableArray* dataPackList;

//@property (retain,nonatomic) BaseDataPack* sendingDataPack;

/**
 * 初始化一个Connector
 */
- (id)init;

- (void)dealloc;


- (void)disconnect;

/**
 * @brief 发送数据报文
 * @param aDataPack 数据报文
 */
- (BOOL)sendDataPack:(BaseDataPack*)aDataPack;

/**
 * @brief 发送文件
 * @param filename 文件名称，全路径
 */
- (void)sendFile:(NSString*)filename;



@end
