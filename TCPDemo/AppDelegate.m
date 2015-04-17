//
//  AppDelegate.m
//  TCPDemo
//
//  Created by wulanzhou-mini on 15-4-1.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "AppDelegate.h"
#import "FileManger.h"
#import "Reachability.h"
#import "SVProgressHUD.h"
@interface AppDelegate ()
@property (nonatomic) Reachability *wifiReachability;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];

    
    return YES;
}
/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    
    
    if (reachability == self.wifiReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        if (netStatus!=ReachableViaWiFi) {
            //[SVProgressHUD showErrorWithStatus:@"WiFi已断开,请重新连接!" duration:1.0f];
            //[SVProgressHUD dismissWithError:@"WiFi已断开,请重新连接!" afterDelay:1.0f];
            UINavigationController *nav=(UINavigationController*)self.window.rootViewController;
            [nav popToRootViewControllerAnimated:YES];
           /**
            [AlertHelper initWithTitle:@"温馨提示" message:@"WiFi已断开,请重新连接!" confirmTitle:@"确认" confirmAction:^{
                UINavigationController *nav=(UINavigationController*)self.window.rootViewController;
                [nav popToRootViewControllerAnimated:YES];
            }];
            return;
            **/
        }
       
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<6.0) {
        [[FileManger shareInstance] loadFile];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
