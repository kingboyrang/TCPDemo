//
//  FileMangerViewController.h
//  TCPDemo
//
//  Created by rang on 15-4-6.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FileMangerDelegate <NSObject>

- (void)selectedFileList:(NSArray*)List;

@end

@interface FileMangerViewController : BasicViewController

@property (nonatomic,assign) id<FileMangerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *containView;
@property (weak, nonatomic) IBOutlet UILabel *labLine;
- (IBAction)photoClick:(id)sender;
- (IBAction)videoClick:(id)sender;


@end
