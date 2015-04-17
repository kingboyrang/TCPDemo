//
//  FileAttribute.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface FileAttribute : NSObject
@property (nonatomic,strong) NSString *name;//文件名
@property (nonatomic,strong) NSString *localPath;//本地文件路径

@property (nonatomic,assign) NSUInteger readedLen;//读取了多少
@property (nonatomic,assign) NSUInteger sendLen;//发送了多少

@property (nonatomic,assign) NSUInteger bodyLen;//文件大小
@property (nonatomic,readonly) NSString *fileSizeMemo;
@property (nonatomic,assign) FileSendStatus sendStauts;//文件发送状态

@property (nonatomic,assign) FileReceiveStatus readStauts;//数据读取状态
@property (nonatomic,strong) UIImage *thumbImage;//缩略图
@property (nonatomic,strong) NSURL *assetsURL;//相册文件URL
@property (nonatomic,assign) NSInteger fileType;//1：图片 2:视频

- (id)initWithAsset:(ALAsset*)asset;

- (void)saveWithCompleted:(void(^)(NSString *path))completed;
@end
