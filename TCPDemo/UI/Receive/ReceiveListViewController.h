//
//  ReceiveListViewController.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseDataPack.h"
#import "FileAttribute.h"
#import <QuickLook/QuickLook.h>
@interface ReceiveListViewController : BasicTableViewController
@property (nonatomic,strong) NSMutableArray *listData;
- (void)addReceiveFile:(FileAttribute*)mod;
- (void)updateCellWithPack:(BaseDataPack*)dataPack;
@end
