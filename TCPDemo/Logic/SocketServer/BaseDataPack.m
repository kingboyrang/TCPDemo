//
//  BaseDataPack.m
//  TCPDemo
//
//  Created by bolin on 15-4-6.
//  Copyright (c) 2015年 com.chuzhong. All rights reserved.
//

#import "BaseDataPack.h"



NSString *const EStorageFilePath = @"storage/";

@implementation BaseDataPack




- (id)initWithBodyJson:(NSUInteger)packId extStr:(NSString*)aExtStr bodyJson:(NSString*)aBodyJson{
    if (self=[super init]) {
        self.readedLen = 0;
        self.sendedLen = 0;
        
        self.packetId = packId;
        self.extStr = aExtStr;
        self.bodyJson = aBodyJson;
        
        if (aBodyJson && aBodyJson.length>0) {
            NSData *buf = [aBodyJson dataUsingEncoding:NSUTF8StringEncoding];
            self.bodyLen = buf.length;
        }
    }
    return self;
}

- (id)initWithFileName:(NSUInteger)packId  filename:(NSString *)aFileName{
    if (self=[super init]) {
        self.readedLen = 0;
        self.sendedLen = 0;
        
        self.packetId = packId;
        
        //文件全路径
        self.fileName = aFileName;

        //文件名称
        self.extStr =  [aFileName lastPathComponent];
        
        //得到文件的长度
        self.bodyLen = [BaseDataPack fileSizeAtPath:aFileName];
    }
    return self;
}

- (void)wirteHead:(NSMutableData *)data{
    [BaseDataPack writeByte:data value:self.packetId];
    [BaseDataPack writetring:data str:self.extStr];
    if (self.bodyJson && self.bodyJson.length>0) {
        NSData *buf = [self.bodyJson dataUsingEncoding:NSUTF8StringEncoding];
        self.bodyLen = buf.length;
        [BaseDataPack writeInt:data value:self.bodyLen];
    }else{
        [BaseDataPack writeInt:data value:self.bodyLen];
    }
}

- (void)writeDataToFile:(NSData *)data{
    
    if(!outFile){
        //获取用户域覆径信息
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *path = [documentsDirectory stringByAppendingPathComponent:EStorageFilePath];
        
        NSFileManager *fileManager =[NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:path]) {
            //创建一个新的目录
            BOOL res=[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            
            if (res) {
                NSLog(@"文件夹创建成功");
            }else{
                NSLog(@"文件夹创建失败");
            }
        }
        
        NSString* targetFile = [path stringByAppendingPathComponent:self.extStr];
        {
            BOOL res=[fileManager createFileAtPath:targetFile contents:nil attributes:nil];
            if (res) {
                NSLog(@"文件创建成功: %@" ,targetFile);
            }else{
                NSLog(@"文件创建失败");
            }
        }
        
        //写入文件
        outFile = [NSFileHandle fileHandleForWritingAtPath:targetFile];
        //将文件的字节设置为0，因为他可能包含数据
        [outFile truncateFileAtOffset:0];

        // NSString* targetFile = [NSString initWithFormat:@"%@%@", , string2
    }
    
    
    {
    
        if(outFile!=nil){
            
            //将读取的内容内容写到outFile.txt中
            [outFile writeData:data];
            
            //关闭输出
            //[outFile closeFile];
        }
    }
    
}

- (NSData*)readNextFileBlock{
    //通过流打开一个文件
    if (!inputStream) {
        inputStream = [[NSInputStream alloc] initWithFileAtPath: self.fileName];
        [inputStream open];
    }
   
    NSInteger maxLength = 1024;
    uint8_t readBuffer[maxLength];
    
    //是否已经到结尾标识
    NSInteger bytesRead = [inputStream read: readBuffer maxLength:maxLength];
    if(bytesRead <=0){
        return nil;
    }
    
    NSData *readedData = [NSData dataWithBytes:readBuffer length:bytesRead];
    self.readedLen += bytesRead;
    if (self.readedLen>=self.bodyLen) {
        inputStream=nil;
    }
    //[inputStream close];
    //[inputStream release];
    return readedData;
}


+ (NSUInteger)readByte:(NSData *)data{
    Byte *b = (Byte *)[data bytes];
    NSUInteger value = b[0]&0xff;
    return value;
}

+ (NSUInteger)readShort:(NSData *)data{
    Byte *b = (Byte *)[data bytes];
    NSUInteger value = (int) (((int)(b[0]&0xff))|(((int)(b[1]&0xff))<<8));
    return value;
}

+ (NSUInteger)readInt:(NSData *)data{
    Byte *b = (Byte *)[data bytes];
    NSUInteger value = (int) (((int)(b[0]&0xff))|(((int)(b[1]&0xff))<<8)|(((int)(b[2]&0xff))<<16)|(((int)(b[3]&0xff))<<24));
    return value;
}

+ (NSString*)readString:(NSData *)data{
    return nil;
}

+ (void)writeByte:(NSMutableData *)data value:(NSUInteger)aValue{
    Byte b[1];
    b[0] = (Byte) (aValue & 0xff);
    [data appendBytes:b length:1];
}

+ (void)writeShort:(NSMutableData *)data value:(NSUInteger)aValue{
    Byte b[2];
    b[0] = (Byte) (aValue & 0xff);
    b[1] = (Byte) ((aValue >> 8) & 0xff);
    [data appendBytes:b length:2];
}

+ (void)writeInt:(NSMutableData *)data value:(NSUInteger)aValue{
    Byte b[4];
    b[0] = (Byte) (aValue & 0xff);
    b[1] = (Byte) ((aValue >> 8) & 0xff);
    b[2] = (Byte) ((aValue >> 16) & 0xff);
    b[3] = (Byte) ((aValue >> 24) & 0xff);
    [data appendBytes:b length:4];
}

+ (void)writetring:(NSMutableData *)data str:(NSString*)aStr{
    if (aStr == nil || aStr.length == 0) {
        [BaseDataPack writeShort:data value:0];
        return;
    }
    NSData *buf = [aStr dataUsingEncoding:NSUTF8StringEncoding];
    [BaseDataPack writeShort:data value:buf.length];
    [data appendData:buf];
}


+ (long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (NSString*)getDocumentsPath{
    //获取用户域覆径信息
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;

}
/**
 *  接收文件保存路径
 *
 *  @return 接收文件路径
 */
+ (NSString*)getReceiveFilePath{
    //获取用户域覆径信息
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:EStorageFilePath];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
/**
 *  取得设备可用容量
 *
 *  @return 取得设备可用容量
 */
+ (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}
                                
@end