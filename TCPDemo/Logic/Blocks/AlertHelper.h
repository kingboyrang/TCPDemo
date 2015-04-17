//
//  AlertHelper.h
//  Eland
//
//  Created by aJia on 13/9/30.
//  Copyright (c) 2013年 rang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
@interface AlertHelper : NSObject
+ (void)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelButtonItem:(RIButtonItem *)inCancelButtonItem otherButtonItems:(RIButtonItem *)inOtherButtonItems, ...;
+ (void)showAlertWithMessage:(NSString *)inMessage;
+ (void)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage;

+ (void)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage confirmTitle:(NSString*)confirmTitle confirmAction:(void (^)(void))confirmAction;

+ (void)initWithTitle:(NSString *)inTitle message:(NSString *)inMessage cancelTitle:(NSString*)cancelTitle cancelAction:(void (^)(void))cancelAction confirmTitle:(NSString*)confirmTitle confirmAction:(void (^)(void))confirmAction;

+ (void)confirmWithTitle:(NSString*)confirm confirm:(void (^)(void))confirmAction innnerView:(UIView*)view;
@end
