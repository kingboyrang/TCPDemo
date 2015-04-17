//
//  ReceiveListViewController.m
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "ReceiveListViewController.h"
#import "ReceiveFileCell.h"
#import "FileManger.h"
#import "PreviewFileManger.h"
@implementation ReceiveListViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.listData=[NSMutableArray array];
    
    NSArray *arr=[[FileManger shareInstance] GetReceiveCacheFileList];
    if (arr&&[arr count]>0) {
        [self.listData addObjectsFromArray:arr];
    }
}
- (void)addReceiveFile:(FileAttribute*)mod{
    [self.listData addObject:mod];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:[self.listData count]-1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}
- (void)updateCellWithPack:(BaseDataPack*)dataPack{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name==%@", dataPack.extStr];
    NSArray *results = [self.listData filteredArrayUsingPredicate:predicate];
    if (results&&[results count]>0) {
        FileAttribute *mod=[results objectAtIndex:0];
        mod.readedLen=dataPack.readedLen;
        
        NSInteger index=[self.listData indexOfObject:mod];
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
        
        ReceiveFileCell *cell=(ReceiveFileCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.progresView.progress!=1.0) {
            cell.progresView.progress=dataPack.readedLen*1.0/mod.bodyLen*1.0;
        }

    }else{
        
        FileAttribute *mod=[[FileAttribute alloc] init];
        mod.readedLen=dataPack.readedLen;
        mod.bodyLen=dataPack.bodyLen;
        //mod.extStrLen=dataPack.extStrLen;
        mod.name=dataPack.extStr;
        mod.readStauts=FileReceive;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:EStorageFilePath];
        NSString* targetFile = [path stringByAppendingPathComponent:dataPack.extStr];
        mod.localPath=targetFile;
       
        [self.listData insertObject:mod atIndex:0];
        
        [self.tableView reloadData];
    }
}
#pragma mark -table source & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"cellIdentifier";
    ReceiveFileCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        NSArray *nibs=[[NSBundle mainBundle] loadNibNamed:@"ReceiveFileCell" owner:self options:nil];
        if (nibs&&[nibs count]>0) {
            cell=[nibs objectAtIndex:0];
        }
    }
    FileAttribute *mod=[self.listData objectAtIndex:indexPath.row];
    [cell receiveFile:mod];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FileAttribute *mod=[self.listData objectAtIndex:indexPath.row];
    
    NSLog(@"local =%@",mod.localPath);
    [[PreviewFileManger shareInstance] openDocumentWithURL:mod.localPath];
    //[[PreviewFileManger shareInstance] previewDocumentWithURL:mod.localPath viewController:self];
    //[self previewDocumentUrl:mod.localPath];
    //[self openDocumentUrl:mod.localPath];
}
@end
