//
//  PhotosTableViewCell.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labSize;

@end
