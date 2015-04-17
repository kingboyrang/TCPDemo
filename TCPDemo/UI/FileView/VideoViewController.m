//
//  VideoViewController.m
//  TCPDemo
//
//  Created by rang on 15-4-6.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化
    self.selectedList=[[NSMutableArray alloc] init];
    //表示文件加载完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFileLoadFinish) name:kNotificationLoadFileFinished object:nil];
    
    
}
//表示文件加载完成
- (void)receiveFileLoadFinish{
    [self.videoTable reloadData];
}
//删除选中项
- (void)removeAllSelected{
    [self.selectedList removeAllObjects];
}
//取得选中的视频
- (NSArray*)GetSelectedVideoList{
    NSMutableArray *sources=[NSMutableArray arrayWithCapacity:0];
    for (NSNumber *num in self.selectedList) {
        [sources addObject:[[FileManger shareInstance].movieList objectAtIndex:[num integerValue]]];
    }
    [self removeAllSelected];
    return sources;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -table source & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[FileManger shareInstance].movieList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"cellIdentifier";
    PhotosTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        NSArray *nibs=[[NSBundle mainBundle] loadNibNamed:@"PhotosTableViewCell" owner:self options:nil];
        if (nibs&&[nibs count]>0) {
            cell=[nibs objectAtIndex:0];
        }
    }
    
    NSNumber *num=[NSNumber numberWithInteger:indexPath.row];
    if ([self.selectedList containsObject:num]) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    //cell.accessoryType=_selectedIndex==indexPath.row? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    FileAttribute *mod=[[FileManger shareInstance].movieList objectAtIndex:indexPath.row];
    cell.thumbImageView.image=mod.thumbImage;
    cell.labName.text=mod.name;
    cell.labSize.text=mod.fileSizeMemo;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSNumber *num=[NSNumber numberWithInteger:indexPath.row];
    if ([self.selectedList containsObject:num]) {//已选中
        if (newCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            newCell.accessoryType = UITableViewCellAccessoryNone;
        }
        [self.selectedList removeObject:num];
    }else{//未选中
        if (newCell.accessoryType == UITableViewCellAccessoryNone) {
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        [self.selectedList addObject:num];
    }
   
}

@end
