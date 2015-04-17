//
//  BZPreviewDataSource.h
//  TCPDemo
//
//  Created by rang on 15-4-9.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>
@interface BZPreviewDataSource : NSObject<QLPreviewControllerDataSource>
@property (nonatomic, retain) NSString *path;
@end

/**
 self.previewoCntroller = [[QLPreviewController alloc] init];
 BZPreviewDataSource *dataSource = [[BZPreviewDataSource alloc]init];
 dataSource.path = [[NSString alloc] initWithString:KnowledgeFullPath];
 self.previewoCntroller.dataSource = dataSource;
 [self.previewoCntroller setDelegate:self];
 float version = [[[UIDevice currentDevice] systemVersion] floatValue];
 if (version >= 5.0){
 //此函数是5.0之后的函数。
 [self presentViewController:self.previewoCntroller animated:YES completion:nil];}
 else { [self.navigationController pushViewController:self.previewoCntroller animated:YES];
 }
**/