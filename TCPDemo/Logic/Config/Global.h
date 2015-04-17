//
//  Global.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#ifndef UpdFileTransfer_Global_h
#define UpdFileTransfer_Global_h

/*****************************socket配置****************************/
#define kSocketPORT  9527  //端口
#define KReadWriteBlockSize 1024  //数据发送字节大小
#define kNotificationNewIPConnection     @"kNotificationNewIPConnection"  //收到用户连接
#define kNotificationUserDisconnection   @"kNotificationUserDisconnection"  //用户断开连接

#define KDataTagPackHead    10   //报文头

#define KDataTagPackId      20   //报文ID
#define KDataTagExtStrLen   21   //扩展长度
#define KDataTagExtStrData  23   //扩展数据
#define KDataTagBodyLen     24   //消息体长度
#define KDataTagBodyData    25   //消息体数据


//文件发送状态更改通知
#define kNotificationFileSendStatuChanged      @"kNotificationFileSendStatuChanged"
//文件接收状态更改通知
#define kNotificationFileReceiveStatuChanged   @"kNotificationFileReceiveStatuChanged"

typedef enum{
    FileSend=0,// 准备发送中
    FileSending,// 发送中
    FileSendPause,//暂停
    FileSendSuccess,//发送成功
    FileSendFailed//发送失败
}FileSendStatus;

typedef enum{
    FileReceive=0,// 准备接收(收到头文件)
    FileReceiving=0,// 接收中
    FileReceiveSuccess,//接收成功
    FileReceiveFailed//接收失败
}FileReceiveStatus;

#endif
