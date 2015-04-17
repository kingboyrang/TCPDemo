//
//  BZPreviewDataSource.m
//  TCPDemo
//
//  Created by rang on 15-4-9.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "BZPreviewDataSource.h"

@implementation BZPreviewDataSource

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.path];
}
@end
