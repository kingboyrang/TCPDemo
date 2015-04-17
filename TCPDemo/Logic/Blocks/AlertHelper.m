//
//  AlertHelper.m
//  Eland
//
//  Created by aJia on 13/9/30.
//  Copyright (c) 2013年 rang. All rights reserved.
//

#import "AlertHelper.h"
#import "RIButtonItem.h"
#import "AppDelegate.h"
@implementation AlertHelper
+(void)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonItem:(RIButtonItem *)inCancelButtonItem otherButtonItems:(RIButtonItem *)inOtherButtonItems, ...{
    UIAlertView *alter=[[UIAlertView alloc] initWithTitle:inTitle message:inMessage cancelButtonItem:inCancelButtonItem otherButtonItems:inOtherButtonItems, nil];
    [alter show];
}
+(void)showAlertWithMessage:(NSString *)inMessage{
    [self initWithTitle:@"温馨提示" message:inMessage];
}
+(void)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage{
    RIButtonItem *button=[RIButtonItem item];
    button.label=@"我知道了";
    button.action=nil;
    [self initWithTitle:inTitle message:inMessage cancelButtonItem:nil otherButtonItems:button];
}

+ (void)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage confirmTitle:(NSString*)confirmTitle confirmAction:(void (^)(void))confirmAction{

    RIButtonItem *button=[RIButtonItem item];
    button.label=confirmTitle;
    button.action=confirmAction;
    
    UIAlertView *alter=[[UIAlertView alloc] initWithTitle:inTitle message:inMessage cancelButtonItem:nil otherButtonItems:button, nil];
    [alter show];
}

+(void)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelTitle:(NSString*)cancelTitle cancelAction:(void (^)(void))cancelAction confirmTitle:(NSString*)confirmTitle confirmAction:(void (^)(void))confirmAction{
    RIButtonItem *cancel=[RIButtonItem item];
    cancel.label=cancelTitle;
    cancel.action=cancelAction;
    
    RIButtonItem *confirm=[RIButtonItem item];
    confirm.label=confirmTitle;
    confirm.action=confirmAction;
    
    [self initWithTitle:inTitle message:inMessage cancelButtonItem:cancel otherButtonItems:confirm];
}
+(void)confirmWithTitle:(NSString*)confirm confirm:(void (^)(void))confirmAction innnerView:(UIView*)view{
    RIButtonItem *canBtn=[RIButtonItem item];
    canBtn.label=@"取消";
    canBtn.action=nil;

    RIButtonItem *delBtn=[RIButtonItem item];
    delBtn.label=confirm;
    delBtn.action=confirmAction;
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:canBtn destructiveButtonItem:nil otherButtonItems:delBtn, nil];
    [sheet showInView:view];
}
@end
