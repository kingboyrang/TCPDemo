//
//  VideoViewController.h
//  TCPDemo
//
//  Created by rang on 15-4-6.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileAttribute.h"
#import "PhotosTableViewCell.h"
#import "FileManger.h"
@interface VideoViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate>{
    NSInteger _selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *videoTable;
@property (nonatomic,strong) NSMutableArray *selectedList;//选中的项
- (void)removeAllSelected;//删除选中项
- (NSArray*)GetSelectedVideoList;//取得选中的视频
@end
