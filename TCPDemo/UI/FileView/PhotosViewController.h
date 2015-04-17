//
//  PhotosViewController.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosViewController : BasicViewController<UITableViewDataSource,UITableViewDelegate>{
    NSInteger _selectedIndex;
}
@property (nonatomic,strong) NSMutableArray *selectedList;//选中的项
@property (weak, nonatomic) IBOutlet UITableView *photoTable;
- (void)removeAllSelected;//删除选中项
- (NSArray*)GetSelectedPhotoList;//取得选中的照片
@end
