//
//  FileMangerViewController.m
//  TCPDemo
//
//  Created by rang on 15-4-6.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "FileMangerViewController.h"
#import "VideoViewController.h"
#import "PhotosViewController.h"
@interface FileMangerViewController (){
    PhotosViewController *_photoController;
    VideoViewController  *_videoController;
    UIViewController *currentViewController;
}

@end

@implementation FileMangerViewController

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
    self.title=@"文件选择";
    
    _photoController=[self.storyboard instantiateViewControllerWithIdentifier:@"PhotosVC"];
    _photoController.view.frame=self.containView.bounds;
    _videoController=[self.storyboard instantiateViewControllerWithIdentifier:@"VideoVC"];
    _videoController.view.frame=self.containView.bounds;
    //默认加载图片
    [self addChildViewController:_photoController];
    [self.containView addSubview:_photoController.view];
    [_photoController didMoveToParentViewController:self];
    currentViewController=_photoController;
    
    //完成按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 40, 30);
    btn.showsTouchWhenHighlighted=YES;
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(buttonFinishedClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=rightBtn;
}
//获取选择的文件
- (void)buttonFinishedClick{
   
    NSMutableArray *list=[NSMutableArray arrayWithCapacity:0];
    
    NSArray *photos=[_photoController GetSelectedPhotoList];
    if (photos&&[photos count]>0) {
        [list addObjectsFromArray:photos];
    }
    NSArray *videos=[_videoController GetSelectedVideoList];
    if (videos&&[videos count]>0) {
        [list addObjectsFromArray:videos];
    }
    if ([list count]==0) {
        [AlertHelper showAlertWithMessage:@"请至少选择一项要发送的文件!"];
        return;
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(selectedFileList:)]) {
        [self.delegate selectedFileList:list];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//照片
- (IBAction)photoClick:(id)sender {
    
    if (currentViewController==_photoController) {
        return;
    }
    
    CGRect r=self.labLine.frame;
    r.origin.x=0;
    if (![self.childViewControllers containsObject:_photoController]) {
        [self addChildViewController:_photoController];
    }
    [self transitionFromViewController:currentViewController toViewController:_photoController duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        self.labLine.frame=r;
    } completion:^(BOOL finished) {
        if (finished) {
            for (UIView *item in self.containView.subviews) {
                [item removeFromSuperview];
            }
            
            [self.containView addSubview:_photoController.view];
            [_photoController didMoveToParentViewController:self];
            [_videoController willMoveToParentViewController:nil];
            [_videoController removeFromParentViewController];
            currentViewController = _photoController;
            
           
        }else{
            currentViewController = _videoController;
        }
    }];
}
//视频
- (IBAction)videoClick:(id)sender {
    
    
    
    if (currentViewController==_videoController) {
        return;
    }
    
    CGRect r=self.labLine.frame;
    r.origin.x=self.view.bounds.size.width/2;
    
    if (![self.childViewControllers containsObject:_videoController]) {
        [self addChildViewController:_videoController];
    }
    
    [self transitionFromViewController:currentViewController toViewController:_videoController duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
          self.labLine.frame=r;
       } completion:^(BOOL finished) {
        if (finished) {
            for (UIView *item in self.containView.subviews) {
                [item removeFromSuperview];
            }
            _videoController.view.frame=self.containView.bounds;
            [self.containView addSubview:_videoController.view];
            [_videoController didMoveToParentViewController:self];
            [_photoController willMoveToParentViewController:nil];
            [_photoController removeFromParentViewController];
            currentViewController = _videoController;
            
            
        }else{
            currentViewController = _photoController;
        }
    }];
}
@end
