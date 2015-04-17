//
//  ViewController.h
//  TCPDemo
//
//  Created by wulanzhou-mini on 15-4-1.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : BasicViewController
@property (weak, nonatomic) IBOutlet UILabel *labWIFI;

@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
- (IBAction)startServerClick:(id)sender;

@end

