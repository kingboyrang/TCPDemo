//
//  ReceiveFileCell.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdpConfig.h"
#import "FileAttribute.h"
@interface ReceiveFileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labProgress;//进度显示文字
@property (weak, nonatomic) IBOutlet UILabel *labFileSize;//文件大小
@property (weak, nonatomic) IBOutlet UILabel *labFileName;//文件名
@property (weak, nonatomic) IBOutlet UIProgressView *progresView;//进度条
/**
 *  接收文件处理显示
 *
 *  @param info 文件对象
 */
- (void)receiveFile:(FileAttribute*)info;
@end
