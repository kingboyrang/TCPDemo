//
//  PreviewFileManger.m
//  TCPDemo
//
//  Created by wulanzhou-mini on 15-4-9.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "PreviewFileManger.h"
#import "BZPreviewDataSource.h"
@implementation PreviewFileManger

+ (PreviewFileManger *)shareInstance{
    static PreviewFileManger *notificationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notificationManager = [[PreviewFileManger alloc] init];
    });
    return notificationManager;
}
/**
 *  (QLPreviewController)预缆文件
 *
 *  @param fileUrl        文件路径
 *  @param viewcontroller 当前所在显示的UIViewController
 */
-(void)previewDocumentWithURL:(NSString*)fileUrl viewController:(UIViewController*)viewcontroller{
    
    _previewoCntroller= [[QLPreviewController alloc] init];
    BZPreviewDataSource *dataSource = [[BZPreviewDataSource alloc]init];
    dataSource.path = fileUrl;
    _previewoCntroller.dataSource = dataSource;
    [_previewoCntroller setDelegate:self];
    
    [viewcontroller.navigationController pushViewController:_previewoCntroller animated:YES];
    
}
/**
 *  (UIDocumentInteractionController)预缆文件
 *
 *  @param fileUrl        文件路径
 */
- (void)openDocumentWithURL:(NSString*)fileUrl{
    NSURL *url=[NSURL fileURLWithPath:fileUrl];
    documentController = [UIDocumentInteractionController  interactionControllerWithURL:url];
    documentController.delegate=self;
    documentController.name=[fileUrl lastPathComponent];
    [documentController presentPreviewAnimated:YES];
}
#pragma mark -QLPreviewControllerDelegate Methods
- (void)previewControllerDidDismiss:(QLPreviewController *)controller{
    _previewoCntroller=nil;
}
#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate Methods
- (UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)controller
{
    
  UIViewController  *nav=[[UIApplication sharedApplication] keyWindow].rootViewController;
    return nav;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    UIViewController  *nav=[[UIApplication sharedApplication] keyWindow].rootViewController;
    return nav.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    UIViewController  *nav=[[UIApplication sharedApplication] keyWindow].rootViewController;
    return nav.view.frame;
}
// 点击预览窗口的“Done”(完成)按钮时调用
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController*)_controller
{
    documentController=nil;
}
@end
