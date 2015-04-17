//
//  BaseDataPack.h
//  TCPDemo
//
//  Created by bolin on 15-4-6.
//  Copyright (c) 2015年 com.chuzhong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDataPackIDNone                 0  //<! 报文ID
#define kDataPackIDFileInfo             1  //<! 报文ID 待发送文件信息报文
#define kDataPackIDResponeFileInfo      11 //<! 报文ID 待文件信息回应报文

#define kDataPackIDSendFile             2  //<! 报文ID 发送文件内容报文
#define kDataPackIDResponeSendFile      12 //<! 报文ID 接收文件内容结果报文

extern NSString *const EStorageFilePath;

/**
 * 数据报文类
 */
@interface BaseDataPack : NSObject{
    
    NSFileHandle*  outFile;
    
    NSInputStream *inputStream;
}


@property (nonatomic,assign) NSUInteger packetId; //<! 报文ID
@property (nonatomic,strong) NSString   *extStr; //<! 扩展字段
@property (nonatomic,assign) NSUInteger bodyLen; //<! Body数据的长度
@property (nonatomic,strong) NSString   *bodyJson; //<! body数据，为json时候的数据

@property (nonatomic,strong) NSString   *fileName; //<! 待传送的文件名，文件全路径

@property (nonatomic,assign) NSUInteger extStrLen; //扩展长度
@property (nonatomic,assign) NSUInteger readedLen;//读取了多少
@property (nonatomic,assign) NSUInteger sendedLen;//已经发送了多少


- (id)initWithBodyJson:(NSUInteger)packId extStr:(NSString*)aExtStr bodyJson:(NSString*)aBodyJson;

- (id)initWithFileName:(NSUInteger)packId filename:(NSString*)aFileName;

/**
 * @brief 把头数据写入到缓存中
 */
- (void)wirteHead:(NSMutableData *)data;


- (void)writeDataToFile:(NSData *)data;


- (NSData*)readNextFileBlock;


/**
 * @brief 读取1个byte,未判断data的数据长度
 * @return
 */
+ (NSUInteger)readByte:(NSData *)data;

/**
 * @brief 读取2个byte,未判断data的数据长度
 * @return
 */
+ (NSUInteger)readShort:(NSData *)data;

/**
 * @brief 读取4个byte,未判断data的数据长度
 * @return
 */
+ (NSUInteger)readInt:(NSData *)data;

/**
 * @brief 读取2+N个byte,未判断data的数据长度
 * @return
 */
+ (NSString*)readString:(NSData *)data;

+ (void)writeByte:(NSMutableData *)data value:(NSUInteger)aValue;
+ (void)writeShort:(NSMutableData *)data value:(NSUInteger)aValue;
+ (void)writeInt:(NSMutableData *)data value:(NSUInteger)aValue;
+ (void)writetring:(NSMutableData *)data str:(NSString*)aStr;

/**
 * @brief 得到文件长度
 * @return
 */
+ (long long)fileSizeAtPath:(NSString*) filePath;

+ (NSString*)getDocumentsPath;
/**
 *  接收文件保存路径
 *
 *  @return 接收文件路径
 */
+ (NSString*)getReceiveFilePath;

+ (NSNumber *)freeDiskSpace;

@end
