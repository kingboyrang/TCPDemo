//
//  FTConnector.m
//  TCPDemo
//
//  Created by bolin on 15-4-5.
//  Copyright (c) 2015年 com.chuzhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FTConnector.h"


@implementation FTConnector


- (id)init{
    
    if (self=[super init]){
        //self.ftClientSocket
        dataPackList = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)dealloc{
    dataPackList = nil;
    
}

- (void)disconnect{
    sendingDataPack = nil;
}

- (BOOL)sendDataPack:(BaseDataPack*)aDataPack{
    if(self.ftClientSocket && [self.ftClientSocket isConnected]){
        [dataPackList addObject:aDataPack];
        
        if (!sendingDataPack) {//如果当前没有发送报文，开始发送第一个报文头
            [self sendNextDataPack];
        }
       
        return YES;
    }
    return NO;
}



- (void)sendDataPackHead:(BaseDataPack *)aDataPack{
    NSMutableData *buf = [NSMutableData dataWithCapacity:1024];
    [aDataPack wirteHead:buf];
    [self.ftClientSocket writeData:buf withTimeout:-1 tag:KDataTagPackHead];
}

- (void)sendDataPackBody:(BaseDataPack *)aDataPack{
    if (!sendingDataPack) {
        NSLog(@"current sendingDataPack is null ...... \n");
        //当前没有报文在发送，发送下一个报文
        [self sendNextDataPack];
        return;
    }
    
    if (sendingDataPack.bodyLen == 0) {
        //body内容长度为0，不需要发送，发送下一个报文
        NSLog(@"current sendingDataPack body len is zero ...... \n");
        [self sendNextDataPack];
        return;
    }
    
    if (sendingDataPack.sendedLen >= sendingDataPack.bodyLen) {
        //内容已经发送完成
         NSLog(@"body sended ...... \n");
        [self sendNextDataPack];
        return;
    }
    
    if(sendingDataPack.packetId == kDataPackIDSendFile){//当前发送的报文为发送文件
        //读取文件内容，发送文件
        NSData *buf = [sendingDataPack readNextFileBlock];
        if (buf) {
           [self.ftClientSocket writeData:buf withTimeout:-1 tag:KDataTagBodyData];
            sendingDataPack.sendedLen += buf.length;
            //写入代理
            [self delegateWriteSocketDataPack:sendingDataPack];
            
        }else{
            //写入代理
            [self delegateWriteSocketDataPack:sendingDataPack];
            //文件发送完成 ，这个时候应该sendingDataPack.sendedLen == sendingDataPack.bodyLen
            NSLog(@"body sended ...... \n");
            [self sendNextDataPack];
        }
        
        return;
    }
    
    //json格式的body 一次性发送
    if(sendingDataPack.bodyJson && sendingDataPack.bodyJson.length > 0){
        NSData *buf = [sendingDataPack.bodyJson dataUsingEncoding:NSUTF8StringEncoding];
        [self.ftClientSocket writeData:buf withTimeout:-1 tag:KDataTagBodyData];
        sendingDataPack.sendedLen += buf.length;
    }
   
}

/**
 * @breif 发送下一个报文
 */
- (void)sendNextDataPack{
    NSLog(@"sendNextDataPack ...... \n");
    
    sendingDataPack = nil;
    if(dataPackList.count > 0){
        //弹出第一个报文
        sendingDataPack = [dataPackList objectAtIndex:0];
        [dataPackList removeObjectAtIndex:0];
        
        //存储当前要发送的文件名称，为下次使用
        if (sendingDataPack.packetId == kDataPackIDFileInfo) {
            self.sendingFileName = sendingDataPack.fileName;
        }
        
        //发送报文头
        [self sendDataPackHead:sendingDataPack];
    }
}

/**
 * @breif 读取下一个数据块
 */
- (void)readNextDataBlock{
    if(readingDataPack.bodyLen == 0){
        //当前报文已经读取完成，读取下一个报文
        [self onReceivedDataPack: readingDataPack];
        readingDataPack = nil;
        
        [self.ftClientSocket readDataToLength:1 withTimeout:-1  tag:KDataTagPackId];
        return;
    }
    
    //当前报文已经读取完成，
    if (readingDataPack.readedLen >=  readingDataPack.bodyLen) {
        
        [self delegateReadSocketDataPack:readingDataPack];
        
        //当前报文已经读取完成，
        [self onReceivedDataPack: readingDataPack];
        readingDataPack = nil;
        
        //开始读取下一个报文
        [self.ftClientSocket readDataToLength:1 withTimeout:-1  tag:KDataTagPackId];
        return;
    }
    
    
    if(readingDataPack.packetId == kDataPackIDSendFile){
        //分块读取
        NSUInteger willReadLen = readingDataPack.bodyLen - readingDataPack.readedLen;
        if (willReadLen > KReadWriteBlockSize) {
            willReadLen = KReadWriteBlockSize;
        }
        [self delegateReadSocketDataPack:readingDataPack];
        
        [self.ftClientSocket readDataToLength:willReadLen withTimeout:-1 tag:KDataTagBodyData];
    }else{
        //全部读取
        NSUInteger willReadLen = readingDataPack.bodyLen - readingDataPack.readedLen;
        [self.ftClientSocket readDataToLength:willReadLen withTimeout:-1 tag:KDataTagBodyData];
    }

}

/**
 * @brief 一个报文接收完成之后，会调用此函数
 * @param aDataPack 已经接收完了的报文
 */
- (void)onReceivedDataPack:(BaseDataPack*)aDataPack{
     NSLog(@"onReceivedDataPack...... %lu, %@, %@",(unsigned long)aDataPack.packetId,aDataPack.bodyJson,aDataPack.extStr);
    
    if (aDataPack.packetId == kDataPackIDFileInfo) {
        NSUInteger receiveTotal=[[BaseDataPack freeDiskSpace] unsignedIntegerValue];
        if (aDataPack.bodyLen<receiveTotal) {//表示可以收文件
            [self sendResponeDataPack: kDataPackIDResponeFileInfo result:0 reason:@"无错误"];
        }else{//不能收文件
            [self sendResponeDataPack: kDataPackIDResponeFileInfo result:1101 reason:@"容量不足"];
        }
        return;
    }
    
    if (aDataPack.packetId == kDataPackIDResponeFileInfo) {
        int result = [self getResponeResult:aDataPack.bodyJson];
        if(result == 0){
            //对方确认可以发送文件
            BaseDataPack* datapack = [[BaseDataPack alloc] initWithFileName:kDataPackIDSendFile filename:self.sendingFileName];
            [self sendDataPack:datapack];
        }
        return;
    }
    
    if (aDataPack.packetId == kDataPackIDSendFile) {
        [self sendResponeDataPack: kDataPackIDResponeSendFile result:0 reason:@"无错误"];
        return;
    }
    
    if (aDataPack.packetId == kDataPackIDResponeSendFile) {
        int result = [self getResponeResult:aDataPack.bodyJson];
        if(result == 0){
            NSLog(@"接收文件成功");
        }else{
             NSLog(@"接收文件失败");
        }
        return;
    }
    
}

/**
 * @brief 发送响应报文
 * @param packId 包ID
 * @param result 错误代码
 * @param reason 错误原因
 */
- (void)sendResponeDataPack:(NSUInteger)packId result:(NSUInteger)aResult  reason:(NSString*)aReason{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[NSNumber numberWithUnsignedInteger:aResult] forKey:@"result"];
    [dictionary setValue:aReason forKey:@"reason"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"jsonStr->%@",jsonStr);
    
    BaseDataPack* datapack = [[BaseDataPack alloc] initWithBodyJson:packId extStr:@"" bodyJson:jsonStr];
    [self sendDataPack: datapack];
}

/**
 * @brief 分析json数据，返回result的值
 */
- (int) getResponeResult:(NSString*)data{
    int result = -1;
    NSError *error = nil;
    NSData* jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (jsonObject != nil && error == nil){
        NSLog(@"Successfully deserialized...");
        if ([jsonObject isKindOfClass:[NSDictionary class]]){
            NSDictionary * root = (NSDictionary *)jsonObject;
            NSLog(@"Dersialized JSON Dictionary = %@", root);
            NSNumber* resultObj = [root objectForKey:@"result"];
            result = [resultObj intValue];
            return  result;
        }
    }
    return result;
}


/**
 * @brief 发送文件
 * @param filename 文件名称，全路径
 */
- (void)sendFile:(NSString*)filename{
    //创建NSFileManager实例
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:filename] == NO){
        return;
    }
    
    NSUInteger fileLength  =(NSUInteger)[BaseDataPack fileSizeAtPath: filename];
    NSString*  justFileName = [filename lastPathComponent];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:justFileName forKey:@"fileName"];
    [dictionary setValue:[NSNumber numberWithUnsignedInteger:fileLength] forKey:@"fileLength"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"jsonStr->%@",jsonStr);
    
    
    BaseDataPack* datapack = [[BaseDataPack alloc] initWithBodyJson:kDataPackIDFileInfo extStr:justFileName bodyJson:jsonStr];
    datapack.fileName = filename;
    [self sendDataPack:datapack];
}



#pragma mark - Delegate
/**
 * socket发生错误时,socket关闭；连接时可能被调用，主要用于socket连接错误时读取错误发生前的数据
 */
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"Socket disconnect with error:\n%@\n", err);
}

/**
 * socket断开连接后被调用，你调用disconnect方法，还没有断开连接，只有调用这个方法时，才断开连接；可以在这个方法中release 一个 socket
 *
 */
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
   
    NSLog(@"onSocketDidDisconnect");
}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    
    /* 开始从 socket 中读取字节流 */
    // P.S. 每次收到回调后立即读取数据会断开连接，所以采用延迟一秒后再读数据
     NSLog(@"didConnectToHost....");
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //[[SocketPacketRead shareInstance] clear];//初始化
        [self.ftClientSocket readDataToLength:1 withTimeout:-1  tag:KDataTagPackId];
    });
    
}
/*监听到新连接时被调用，这个新socket的代理和listen socket相同*/
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    
    NSLog(@"didAcceptNewSocket  =%@",newSocket);
    
 /*
    self.clientSocket=newSocket;
    //表示有用户连接通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewIPConnection object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:newSocket.connectedHost,@"host",[NSNumber numberWithInteger:newSocket.connectedPort],@"port", nil]];
  */
    
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"Server wantsRunLoopForNewSocket");
    return [NSRunLoop currentRunLoop];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    NSLog(@"SonSocketWillConnect......");
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"Socket write data with tag: %ld", tag);
    
    if(KDataTagPackHead == tag) {
        if(sendingDataPack && sendingDataPack.bodyLen > 0){
            //有报文内容就发送报文体
            [self sendDataPackBody:sendingDataPack];
        }else{
            //发送下一个报文
            [self sendNextDataPack];
        }
    }

    if(KDataTagBodyData == tag) {
        //发送报文体
        [self sendDataPackBody:sendingDataPack];
    }
    
}

- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"didWritePartialDataOfLength tag: %ld", tag);
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"didReadPartialDataOfLength tag: %ld", tag);
    //[self.clientSocket readDataToLength:2 withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    //NSLog(@"Socket read data : %@", data);


    if (tag==KDataTagPackId) {//报文ID
        readingDataPack = [[BaseDataPack alloc] initWithBodyJson:0 extStr:@"" bodyJson:@""];
        readingDataPack.packetId = [BaseDataPack readByte:data];
        
       
        
        [self.ftClientSocket readDataToLength:2  withTimeout:-1 tag:KDataTagExtStrLen];
        return;
    }
    
    if (tag==KDataTagExtStrLen) {//扩展字符串长度
        readingDataPack.extStrLen = [BaseDataPack readShort:data];
        
        if (readingDataPack.extStrLen == 0) {
            //读取body长度
            [self.ftClientSocket readDataToLength:4 withTimeout:-1 tag:KDataTagBodyLen];
        }else{
            //读取扩展内容
            [self.ftClientSocket readDataToLength:readingDataPack.extStrLen withTimeout:-1 tag:KDataTagExtStrData];
        }
        
        return;
    }
    
    if (tag==KDataTagExtStrData) {//扩展内容
        readingDataPack.extStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //读取body长度
        [self.ftClientSocket readDataToLength:4 withTimeout:-1 tag:KDataTagBodyLen];
        return;
    }
    
    if (tag==KDataTagBodyLen) {//消息体长度
        readingDataPack.bodyLen = [BaseDataPack readInt:data];
        //读取下一块数据
        [self readNextDataBlock];
        return;
    }
    
    if (tag==KDataTagBodyData) {//消息体数据
        readingDataPack.readedLen += data.length;
        
        if (readingDataPack.packetId == kDataPackIDSendFile) {//文件数据
            //把数据写入文件
            [readingDataPack writeDataToFile:data];

        }else{//json数据
            readingDataPack.bodyJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            /*
            //写放数据
            [SocketPacketRead shareInstance].readedLen+=[data length];
            if ([data length]>0) {
                [[SocketPacketRead shareInstance].bodyData appendData:data];
            }
            NSLog(@"readlen =%lu",[SocketPacketRead shareInstance].readedLen);
           
     
            //进度条
            float progress=[SocketPacketRead shareInstance].readedLen*1.0/[SocketPacketRead shareInstance].bodyLen*1.0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileReceiving object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:[SocketPacketRead shareInstance].readedLen],@"size",[NSNumber numberWithFloat:progress],@"progress", nil]];
            
            //表示读取完成
            if ([SocketPacketRead shareInstance].readedLen==[SocketPacketRead shareInstance].bodyLen) {
     
                //表示读取完成
                [SocketPacketRead shareInstance].readStauts=SocketReadSuccess;
                //告诉对方表示接收完成
                [self handleReceiveFinishedBack];
                
                SocketPacketRead *mode=[[SocketPacketRead shareInstance] copy];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketReadFinished object:mode userInfo:nil];
                //接收完成通知
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileReceiveFinished object:nil userInfo:nil];
                
                //[self receiveFileData:[SocketPacketRead shareInstance].bodyData];
                [self.clientSocket readDataToLength:1 withTimeout:-1 tag:KDataTagPackId];
                [[SocketPacketRead shareInstance] clear];//重置
            }
            //剩下未读的长度
            NSUInteger len=[SocketPacketRead shareInstance].bodyLen-[SocketPacketRead shareInstance].readedLen;
            if (len>kDataTagReadBodyLen) {
                [self.clientSocket readDataToLength:kDataTagReadBodyLen withTimeout:-1 tag:KDataTagBodyData];
            }else{
                [self.clientSocket readDataToLength:len withTimeout:-1 tag:KDataTagBodyData];
            }
            */
        }
        
        //读取下一块数据
        [self readNextDataBlock];
    }
}

//告诉对方表示接收完成
- (void)handleReceiveFinishedBack{
    NSLog(@"dhandleReceiveFinishedBack");
    //NSData *data=[SocketDataEncoded sendFileSocketPocketBackData];
    //[self.clientSocket writeData:data withTimeout:-1 tag:KDataTagPackId];
}

//待文件信息回应报文
- (BOOL)handleReceiveBackWithData:(NSData*)data{
    
/*
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:1 error:nil];
    NSUInteger receiveTotal=[[dic objectForKey:@"fileLength"] unsignedIntegerValue];
    BOOL boo;
    NSData *send=[SocketDataEncoded waitSendBackSocketPocketWithSize:receiveTotal isReceive:&boo];
    [self.clientSocket writeData:send withTimeout:-1 tag:KDataTagPackId];
    if (boo) {
        [SocketDataFile shareInstance].packetId=1;
        [SocketDataFile shareInstance].name=[dic objectForKey:@"fileName"];
        [SocketDataFile shareInstance].bodyLen=receiveTotal;
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileReceive object:nil userInfo:dic];
    }
    return boo;
*/
    return YES;
}

- (void)receiveFileData:(NSData*)data{
    
/*
    [SocketDataFile shareInstance].readedLen+=[data length];
    if ([data length]>0) {
        [[SocketDataFile shareInstance].bodyData appendData:data];
    }
    NSLog(@"readedLen =%lu",[SocketDataFile shareInstance].readedLen);
    //进度条
    float progress=[SocketDataFile shareInstance].readedLen*1.0/[SocketDataFile shareInstance].bodyLen*1.0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileReceiving object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:[SocketDataFile shareInstance].readedLen],@"size",[NSNumber numberWithFloat:progress],@"progress", nil]];
    if ([SocketDataFile shareInstance].readedLen==[SocketDataFile shareInstance].bodyLen) {
        //表示读取完成
        [SocketDataFile shareInstance].readStauts=SocketReadSuccess;
        //告诉对方表示接收完成
        [self handleReceiveFinishedBack];
        
        SocketDataFile *mode=[[SocketDataFile shareInstance] copy];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSocketPacketReadFinished object:mode userInfo:nil];
        //接收完成通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileReceiveFinished object:nil userInfo:nil];
        
        [[SocketDataFile shareInstance] clear];//重置
    }
 */
    
}
- (void)delegateReadSocketDataPack:(BaseDataPack*)dataPack{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(readSocketDataPack:)]) {
        [self.delegate readSocketDataPack:dataPack];
    }
}
- (void)delegateWriteSocketDataPack:(BaseDataPack*)dataPack{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(writeSocketDataPack:)]) {
        [self.delegate writeSocketDataPack:dataPack];
    }
}
@end