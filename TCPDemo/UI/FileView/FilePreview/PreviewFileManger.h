//
//  PreviewFileManger.h
//  TCPDemo
//
//  Created by wulanzhou-mini on 15-4-9.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

/**
 *  文件预缆
 */

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface PreviewFileManger : NSObject<UIDocumentInteractionControllerDelegate,QLPreviewControllerDelegate>{
    
   QLPreviewController *_previewoCntroller;
   UIDocumentInteractionController *documentController;
}

/**
 *  单例模式
 *
 *  @return PreviewFileManger对象
 */
+ (PreviewFileManger *)shareInstance;
/**
 *  (QLPreviewController)预缆文件
 *
 *  @param fileUrl        文件路径
 *  @param viewcontroller 当前所在显示的UIViewController
 */
-(void)previewDocumentWithURL:(NSString*)fileUrl viewController:(UIViewController*)viewcontroller;
/**
 *  (UIDocumentInteractionController)预缆文件
 *
 *  @param fileUrl        文件路径
 */
- (void)openDocumentWithURL:(NSString*)fileUrl;

@end
