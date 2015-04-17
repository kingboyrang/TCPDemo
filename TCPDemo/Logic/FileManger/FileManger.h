//
//  FileManger.h
//  TCPDemo
//
//  Created by rang on 15-4-5.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <Foundation/Foundation.h>

// 接收缓存路径
#define KCacheReceivePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"CacheReceiveFile"]

// 发送缓存路径
#define KCacheSendPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"CacheSendFile"]

#define kNotificationLoadFileFinished @"kNotificationLoadFileFinished"

@interface FileManger : NSObject
@property (nonatomic,strong) NSMutableArray *groupArrays;
@property (nonatomic,strong) NSMutableArray *photoList;
@property (nonatomic,strong) NSMutableArray *movieList;
+ (FileManger *)shareInstance;
/**
 *  加载相册与视频
 */
- (void)loadFile;
/**
 *  文件数据写入
 *
 *  @param data 数据
 *  @param name 文件名
 */
- (NSString*)writeData:(NSData*)data withFileName:(NSString*)name;
/**
 *  将图片写入本地
 *
 *  @param url       ALAssetsLibrary url
 *  @param fileName  文件名
 *  @param completed 文件保存在本地的路径
 */
- (void)imageWithUrl:(NSURL *)url withFileName:(NSString *)fileName complete:(void(^)(NSString *path))completed;
/**
 *  将视频写入本地
 *
 *  @param url       ALAssetsLibrary url
 *  @param fileName  文件名
 *  @param completed 文件保存在本地的路径
 */
- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName  complete:(void(^)(NSString *path))completed;
/**
 *  取得视频缩图
 *
 *  @param videoURL 文件名路径
 */
- (UIImage *)getImage:(NSString *)videoURL;
/**
 *  取得已发送的文件列表
 *
 *  @return
 */
- (NSArray*)GetSendCacheFileList;
/**
 *  取得已接收的文件列表
 *
 *  @return
 */
- (NSArray*)GetReceiveCacheFileList;
@end
