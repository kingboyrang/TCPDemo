//
//  AndroidFileReceiveViewController.m
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "AndroidFileReceiveViewController.h"
#import "ReceiveListViewController.h"
#import "PhotosViewController.h"
#import "SendListViewController.h"
#import "SocketServer.h"
#import "FileMangerViewController.h"
#import "FileManger.h"
#import "CTAssetsPickerController.h"
@interface AndroidFileReceiveViewController ()<FileMangerDelegate,FTConnectorDelegate,UINavigationControllerDelegate,CTAssetsPickerControllerDelegate>{
    SendListViewController *_sendViewController;
    ReceiveListViewController *_receiveViewController;
    UIViewController *currentViewController;
}

@end

@implementation AndroidFileReceiveViewController
- (void)viewDidLoad {
    [super viewDidLoad];
     self.title=@"传输中";
    
    //添加按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 40, 30);
    btn.showsTouchWhenHighlighted=YES;
    [btn setTitle:@"添加" forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(chooseFileSendClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=rightBtn;
    
    //断开连接通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveConnectionStop:) name:kNotificationUserDisconnection object:nil];
    
     //添加UIViewController
    _sendViewController=[[SendListViewController alloc] initWithStyle:UITableViewStylePlain];
    _sendViewController.view.frame=self.containView.bounds;
    //显示接收者
    _receiveViewController=[[ReceiveListViewController alloc] initWithStyle:UITableViewStylePlain];
    _receiveViewController.view.frame=self.containView.bounds;
    [self addChildViewController:_sendViewController];
    
    
    [self.containView  addSubview:_sendViewController.view];
    [_sendViewController didMoveToParentViewController:self];
    currentViewController=_sendViewController;
    
    
    self.containView.backgroundColor=[UIColor whiteColor];
    
    //接收与发送文件代理
    [[SocketServer shareInstance] getFirstConnector].delegate=self;
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated{
   [super viewWillDisappear:animated];
   
}
#pragma mark -重写父类事件
- (BOOL)isNavigationBack{
   [[SocketServer shareInstance] getFirstConnector].delegate=nil;
   [[SocketServer shareInstance] stopListen];
   return YES;
}
#pragma mark -FTConnectorDelegate Methods
//正在写入的数据包
- (void)writeSocketDataPack:(BaseDataPack*)dataPack{
    if (dataPack.packetId!=kDataPackIDSendFile) {
        return;
    }
    [self changeTabSendWithCompleted:^{
        [_sendViewController updateCellWithPack:dataPack];
    }];
}
//正在读取的数据包
- (void)readSocketDataPack:(BaseDataPack*)dataPack{
    if (dataPack.packetId!=kDataPackIDSendFile) {
        return;
    }
    [self changeTabReceiveWithCompleted:^{
         [_receiveViewController updateCellWithPack:dataPack];
    }];
}
#pragma mark -断开连接通知
//对方已断开连接通知
- (void)receiveConnectionStop:(NSNotification*)notification{
    [AlertHelper initWithTitle:@"温馨提示" message:@"连接已断开!" confirmTitle:@"我知道了" confirmAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark -按钮事件
//已完成
- (IBAction)finishClick:(id)sender {
   [self changeTabReceiveWithCompleted:nil];
}
//传输中
- (IBAction)translClick:(id)sender {
   [self changeTabSendWithCompleted:nil];
}
//文件选择
- (void)chooseFileSendClick{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0){
        FileMangerViewController *photos=[self.storyboard instantiateViewControllerWithIdentifier:@"FileMangerVC"];
        photos.delegate=self;
        [self.navigationController pushViewController:photos animated:YES];
        return;
    }
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelection = 10;
    picker.assetsFilter = [ALAssetsFilter allAssets];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark -切换标签处理
/**
 *  切换到传输中(发送)标签
 *
 *  @param completed 切换完成的做其它事
 */
- (void)changeTabSendWithCompleted:(void(^)())completed{
    NSLog(@"class =%@",[currentViewController class]);
    if (currentViewController==_sendViewController) {
        if (completed) {
            completed();
        }
        return;
    }
    
    CGRect r=self.labLine.frame;
    r.origin.x=0;
    if (![self.childViewControllers containsObject:_sendViewController]) {
        [self addChildViewController:_sendViewController];
    }
    [self transitionFromViewController:currentViewController toViewController:_sendViewController duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        self.labLine.frame=r;
        self.title=@"传输中";
    } completion:^(BOOL finished) {
        
        NSLog(@"changeTabSendWithCompleted finished =%@",finished?@"YES":@"NO");
        for (UIView *item in self.containView.subviews) {
            [item removeFromSuperview];
        }
        [self.containView addSubview:_sendViewController.view];
        [_sendViewController didMoveToParentViewController:self];
        [_receiveViewController willMoveToParentViewController:nil];
        [_receiveViewController removeFromParentViewController];
        currentViewController = _sendViewController;
        
        if (completed) {
            completed();
        }
        
        /**
        if (finished) {
           
        }else{
            currentViewController = _receiveViewController;
        }
         **/
    }];
}
/**
 *  切换到完成中(接收中)标签
 *
 *  @param completed 切换完成的做其它事
 */
- (void)changeTabReceiveWithCompleted:(void(^)())completed{
    if (currentViewController==_receiveViewController) {
        if (completed) {
            completed();
        }
        return;
    }
    
    CGRect r=self.labLine.frame;
    r.origin.x=106;
    if (![self.childViewControllers containsObject:_receiveViewController]) {
        [self addChildViewController:_receiveViewController];
    }
    [self transitionFromViewController:currentViewController toViewController:_receiveViewController duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        self.labLine.frame=r;
        self.title=@"已完成";
    } completion:^(BOOL finished) {
         NSLog(@"changeTabReceiveWithCompleted finished =%@",finished?@"YES":@"NO");
        if (finished) {
            for (UIView *item in self.containView.subviews) {
                [item removeFromSuperview];
            }
            _receiveViewController.view.frame=self.containView.bounds;
            [self.containView addSubview:_receiveViewController.view];
            [_receiveViewController didMoveToParentViewController:self];
            [_sendViewController willMoveToParentViewController:nil];
            [_sendViewController removeFromParentViewController];
            currentViewController = _receiveViewController;
            
            if (completed) {
                completed();
            }
        }else{
            currentViewController = _sendViewController;
        }
    }];
}
#pragma mark -FileMangerDelegate Methods
//选择系统文件进行发送
- (void)selectedFileList:(NSArray*)List{
    [self changeTabSendWithCompleted:^{
        [_sendViewController addSendFileWithArray:List];
    }];
}
#pragma mark -
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    if (assets&&[assets count]>0) {
        NSMutableArray *sources=[NSMutableArray arrayWithCapacity:0];
        for (ALAsset *item in assets) {
            FileAttribute *mod=[[FileAttribute alloc] initWithAsset:item];
            [sources addObject:mod];
        }
        [self changeTabSendWithCompleted:^{
            [_sendViewController addSendFileWithArray:sources];
        }];
    }
}
@end
