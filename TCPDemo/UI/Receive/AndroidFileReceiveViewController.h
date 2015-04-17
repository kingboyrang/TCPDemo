//
//  AndroidFileReceiveViewController.h
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AndroidFileReceiveViewController : BasicViewController{
    BOOL _isFirst;
}

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *containView;
@property (weak, nonatomic) IBOutlet UILabel *labLine;

- (IBAction)finishClick:(id)sender;
- (IBAction)translClick:(id)sender;


@end
