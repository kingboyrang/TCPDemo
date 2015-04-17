//
//  SendListViewController.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileAttribute.h"
#import "BaseDataPack.h"
@interface SendListViewController : BasicTableViewController
@property (nonatomic,strong) NSMutableArray *listData;
/**
 *  添加单个要发送的文件
 *
 *  @param mod  发送的文件对象
 */
- (void)addSendFile:(FileAttribute*)mod;
/**
 *  添加多个要发送的文件
 *
 *  @param files  发送的文件列表
 */
- (void)addSendFileWithArray:(NSArray*)files;
/**
 *  更新当前正在发送的文件信息
 *
 *  @param dataPack 发送数据
 */
- (void)updateCellWithPack:(BaseDataPack*)dataPack;
@end
