//
//  FileAttribute.m
//  UpdFileTransfer
//
//  Created by wulanzhou-mini on 15-3-31.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "FileAttribute.h"
#import "FileManger.h"
@implementation FileAttribute

- (void)setSendStauts:(FileSendStatus)status
{
    if (_sendStauts!=status) {
        _sendStauts=status;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileSendStatuChanged object:self];
    }
}
- (void)setReadStauts:(FileReceiveStatus)status{
    if (_readStauts!=status) {
        _readStauts=status;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileReceiveStatuChanged object:self];
    }
}
- (NSString*)fileSizeMemo{
    UInt64 GBUnit=1073741824;
    UInt64 MBUnit=1048576;
    UInt64 KBUnit=1024;
    
    NSString *showFileSize = nil;
    if (self.bodyLen>GBUnit)
        showFileSize = [[NSString alloc] initWithFormat:@"%.1fG", self.bodyLen / (CGFloat)GBUnit];
    if (self.bodyLen>MBUnit && self.bodyLen<=GBUnit)
        showFileSize = [[NSString alloc] initWithFormat:@"%.1fMB", self.bodyLen / (CGFloat)MBUnit];
    else if (self.bodyLen>KBUnit && self.bodyLen<=MBUnit)
        showFileSize = [[NSString alloc] initWithFormat:@"%lliKB", self.bodyLen / KBUnit];
    else if (self.bodyLen<=KBUnit)
        showFileSize = [[NSString alloc] initWithFormat:@"%dB", self.bodyLen];
    return showFileSize;
}
- (id)initWithAsset:(ALAsset*)asset{
    if (self=[super init]) {
       self.name= [[asset defaultRepresentation] filename];
       self.assetsURL= [[asset defaultRepresentation] url];
       self.bodyLen= (NSUInteger)[[asset defaultRepresentation] size];
       self.thumbImage= [UIImage imageWithCGImage:[asset thumbnail]];
       self.fileType=([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])?1:2;
       self.sendStauts=FileSend;
    }
    return self;
}
- (void)saveWithCompleted:(void(^)(NSString *path))completed{
    
    
    if (self.fileType==1) {
        [[FileManger shareInstance] imageWithUrl:self.assetsURL withFileName:self.name complete:^(NSString *path) {
            self.localPath=path;
            if (completed) {
                completed(path);
            }
        }];
    }
    if (self.fileType==2) {//视频
        [[FileManger shareInstance] videoWithUrl:self.assetsURL withFileName:self.name complete:^(NSString *path) {
            
            self.localPath=path;
            if (completed) {
                completed(path);
            }
        }];
    }
}
@end
