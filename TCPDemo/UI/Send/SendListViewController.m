//
//  SendListViewController.m
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "SendListViewController.h"
#import "SendFileCell.h"
#import "SocketServer.h"
#import "FileManger.h"
#import "PreviewFileManger.h"
@implementation SendListViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.listData=[NSMutableArray array];
    
    NSArray *arr=[[FileManger shareInstance] GetSendCacheFileList];
    if (arr&&[arr count]>0) {
        [self.listData addObjectsFromArray:arr];
    }
}
/**
 *  添加单个要发送的文件
 *
 *  @param mod  发送的文件对象
 */
- (void)addSendFile:(FileAttribute*)mod{
    mod.sendStauts=FileSending;
    [self.listData insertObject:mod atIndex:0];
    [self.tableView reloadData];
}
/**
 *  添加多个要发送的文件
 *
 *  @param files  发送的文件列表
 */
- (void)addSendFileWithArray:(NSArray*)files{
    if (files&&[files count]>0) {
    
        for (FileAttribute *item in files) {
            item.sendStauts=FileSending;
            [item saveWithCompleted:^(NSString *path) {
                 [[[SocketServer shareInstance] getFirstConnector] sendFile:path];
            }];
            
            [self.listData insertObject:item atIndex:0];
        }
        [self.tableView reloadData];
    }
}
/**
 *  更新当前正在发送的文件信息
 *
 *  @param dataPack 发送数据
 */
- (void)updateCellWithPack:(BaseDataPack*)dataPack{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name==%@", [dataPack.fileName lastPathComponent]];
    NSArray *results = [self.listData filteredArrayUsingPredicate:predicate];
    if (results&&[results count]>0) {
        FileAttribute *mod=[results objectAtIndex:0];
        NSInteger index=[self.listData indexOfObject:mod];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
        SendFileCell *cell=(SendFileCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.progresView.progress=dataPack.sendedLen*1.0/mod.bodyLen*1.0;
    }
}
#pragma mark -table source & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"cellIdentifier";
    SendFileCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        NSArray *nibs=[[NSBundle mainBundle] loadNibNamed:@"SendFileCell" owner:self options:nil];
        if (nibs&&[nibs count]>0) {
            cell=[nibs objectAtIndex:0];
        }
    }
    FileAttribute *mod=[self.listData objectAtIndex:indexPath.row];
    [cell sendFile:mod];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FileAttribute *mod=[self.listData objectAtIndex:indexPath.row];
    [[PreviewFileManger shareInstance] openDocumentWithURL:mod.localPath];
    //[[PreviewFileManger shareInstance] previewDocumentWithURL:mod.localPath viewController:self];
}
@end
