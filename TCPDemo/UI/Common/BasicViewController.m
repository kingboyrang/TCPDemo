//
//  BasicViewController.m
//  UpdFileTransfer
//
//  Created by rang on 15-3-28.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "BasicViewController.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

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
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    
    if ([self.navigationController.viewControllers count]>1) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 0, 15, 30);
        [btn setImage:[UIImage imageNamed:@"barbuttonicon_back.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backNavigationClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBtn=[[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem=backBtn;
    }
    
}
- (BOOL)isNavigationBack{
    return YES;
}
- (void)backNavigationClick{
    if ([self isNavigationBack]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
