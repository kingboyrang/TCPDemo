//
//  ReceiveFileCell.m
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "ReceiveFileCell.h"

@interface ReceiveFileCell ()
@property (nonatomic,strong) FileAttribute *entity;
@end

@implementation ReceiveFileCell
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_progresView removeObserver:self forKeyPath:@"progress"];
}
- (void)awakeFromNib {
    // 发送状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFileChange:) name:kNotificationFileReceiveStatuChanged object:nil];
    //监听进度条的值是否发生改变
    [_progresView addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"progress"]) {
        self.labProgress.textColor=[UIColor blueColor];
        float rate=[[change objectForKey:@"new"] floatValue];
        self.labProgress.text=[NSString stringWithFormat:@"%d%%",(int)(rate*100)];
        if (rate==1.0) {
            self.entity.readStauts=FileReceiveSuccess;
        }else{
            self.entity.readStauts=FileReceiving;
        }
    }
}
- (void)changeStatusWithFile:(FileAttribute*)mod{
    //状态改变处理
    if (mod.readStauts==FileReceive) {
        self.progresView.hidden=NO;
        self.labProgress.text=@"准备接收";
        self.labProgress.textColor=[UIColor grayColor];
    }else if (mod.readStauts==FileReceiveFailed){
        self.progresView.hidden=YES;
        self.labProgress.text=@"接收失败";
        self.labProgress.textColor=[UIColor redColor];
    }else if (mod.readStauts==FileReceiveSuccess){
        self.progresView.hidden=YES;
        self.labProgress.text=@"已完成";
        self.labProgress.textColor=[UIColor grayColor];
    }else{
        self.progresView.hidden=NO;
        self.labProgress.textColor=[UIColor blueColor];
    }
   
}
//文件发送状态发生改变
- (void)receiveFileChange:(NSNotification*)notifice{
    FileAttribute *mod=[notifice object];
    if (mod==self.entity) {
        // 主线程执行：
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeStatusWithFile:mod];
        });
    }
}
- (void)receiveFile:(FileAttribute*)info{
    self.entity=info;
    self.labFileName.text=info.name;
    self.labFileSize.text=[info fileSizeMemo];
    [self changeStatusWithFile:self.entity];
}
@end
