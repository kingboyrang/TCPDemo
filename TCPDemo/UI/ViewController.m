//
//  ViewController.m
//  TCPDemo
//
//  Created by wulanzhou-mini on 15-4-1.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "SocketServer.h"
#import "SVProgressHUD.h"
#import "AndroidFileReceiveViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"连接配件Android OS";
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        //返回颜色
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    }
    //导航字体大小与颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], UITextAttributeTextColor,
                                                                     [UIFont fontWithName:@"Arial-Bold" size:25.0], UITextAttributeFont,
                                                                     nil]];
    
    self.btnConnect.layer.cornerRadius=5.0;
    self.btnConnect.layer.masksToBounds=YES;
    [self.btnConnect setBackgroundImage:[UIImage createImageWithColor:UIColorMakeRGB(48, 181, 237)] forState:UIControlStateNormal];
    
    //用户连接成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveConnection:) name:kNotificationNewIPConnection object:nil];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *wifi=[self getWifiName];
    self.labWIFI.text=[NSString stringWithFormat:@"当前连接的WiFi:%@",wifi&&[wifi length]>0?wifi:@"未连接"];
    //停止监听
    //[[SocketServer shareInstance] stopListen];
    //[self.serverManger sendBroadcast];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -用户连接成功
- (void)receiveConnection:(NSNotification*)notification{
    [SVProgressHUD dismiss];
    if (![self.navigationController.topViewController  isKindOfClass:[AndroidFileReceiveViewController class]]) {
        
        AndroidFileReceiveViewController *receive=[self.storyboard instantiateViewControllerWithIdentifier:@"AndroidFileReceiveVC"];
        [self.navigationController pushViewController:receive animated:YES];
    }
   
}
//取得wifi名称
- (NSString *)getWifiName
{
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}
- (IBAction)startServerClick:(id)sender {
    /** **/
    NSString *wifiName=[self getWifiName];
    if (wifiName==nil) {
        self.labWIFI.text=@"当前连接的WiFi:未连接";
        [AlertHelper showAlertWithMessage:@"wifi未连接!"];
        return;
    }
    self.labWIFI.text=[NSString stringWithFormat:@"当前连接的WiFi:%@",wifiName];
    if (![wifiName isEqualToString:@"android-os-wifi"]) {
        [AlertHelper showAlertWithMessage:[NSString stringWithFormat:@"%@,请连接wifi:android-os-wifi",self.labWIFI.text]];
        return;
    }
    //开始监听
    [[SocketServer shareInstance] startListen];
    
    
    [SVProgressHUD showWithStatus:@"连接中..." maskType:SVProgressHUDMaskTypeClear];
    
    //[self receiveConnection:nil];
}
@end
