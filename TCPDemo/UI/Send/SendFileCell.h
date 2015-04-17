//
//  AndroidFileCell.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdpConfig.h"
#import "FileAttribute.h"

#define kNotificationNextSendFile @"kNotificationNextSendFile"

@interface SendFileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labProgress;//显示发送进度
@property (weak, nonatomic) IBOutlet UILabel *labFileSize;//文件大小
@property (weak, nonatomic) IBOutlet UILabel *labFileName;//文件名
@property (weak, nonatomic) IBOutlet UIProgressView *progresView;//发送进度条
/**
 *  发送文件处理显示
 *
 *  @param info 发送文件
 */
- (void)sendFile:(FileAttribute*)info;
@end
