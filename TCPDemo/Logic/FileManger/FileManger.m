//
//  FileManger.m
//  TCPDemo
//
//  Created by rang on 15-4-5.
//  Copyright (c) 2015年 wulanzhou-mini. All rights reserved.
//

#import "FileManger.h"
#import "FileAttribute.h"
#import "BaseDataPack.h"
#import <AssetsLibrary/AssetsLibrary.h>  // 必须导入
#import <AVFoundation/AVFoundation.h>
@implementation FileManger
+ (FileManger *)shareInstance{
    static FileManger *notificationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notificationManager = [[FileManger alloc] init];
    });
    return notificationManager;
}
- (void)loadFile{
    if (!self.photoList) {
        self.photoList=[[NSMutableArray alloc] init];
    }
    if (!self.movieList) {
        self.movieList=[[NSMutableArray alloc] init];
    }
    if (!self.groupArrays) {
        self.groupArrays=[[NSMutableArray alloc] init];
    }
    if (self.photoList&&[self.photoList count]>0) {
        return;
    }
    __weak FileManger *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [weakSelf.groupArrays addObject:group];
            } else {
                [weakSelf.groupArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if ([result thumbnail] != nil) {
                            NSString *fileName = [[result defaultRepresentation] filename];
                            NSURL *url = [[result defaultRepresentation] url];
                            int64_t fileSize = [[result defaultRepresentation] size];
                             UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                            // 照片
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                                //NSDate *date= [result valueForProperty:ALAssetPropertyDate];
                               
                               
                                
                                FileAttribute *file=[[FileAttribute alloc] init];
                                file.name=fileName;
                                file.thumbImage=image;
                                file.bodyLen=(NSUInteger)fileSize;
                                file.assetsURL=url;
                                file.fileType=1;
                                file.sendLen=0;
                                file.sendStauts=FileSend;
                                [self.photoList addObject:file];
                                
                                
                               // NSLog(@"photoTable =%@",[weakSelf.groupArrays objectAtIndex:idx]);
                               
                               
                            }
                            // 视频
                            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ){
                                // 和图片方法类似
                                FileAttribute *file=[[FileAttribute alloc] init];
                                file.name=fileName;
                                file.thumbImage=image;
                                file.bodyLen=(NSUInteger)fileSize;
                                file.sendLen=0;
                                file.assetsURL=url;
                                file.fileType=2;
                                file.sendStauts=FileSend;
                                [self.movieList addObject:file];
                                
                            }
                            
                            
                            //最后一项表示文件加载完成
                            if (idx==[weakSelf.groupArrays count]-1) {
                                
                                if (index==[[weakSelf.groupArrays objectAtIndex:idx] numberOfAssets]-1) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadFileFinished object:nil];
                                }
                                
                            }
                        }
                    }];
                }];
            }
        };
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
        {
            NSString *errorMessage = nil;
            switch ([error code]) {
                case ALAssetsLibraryAccessUserDeniedError:
                case ALAssetsLibraryAccessGloballyDeniedError:
                    errorMessage = @"用户拒绝访问相册,请在<隐私>中开启";
                    break;
                default:
                    errorMessage = @"Reason unknown.";
                    break;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误,无法访问!"
                                                                   message:errorMessage
                                                                  delegate:self
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil, nil];
                [alertView show];
            });
        };
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]  init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:listGroupBlock failureBlock:failureBlock];
    });
    
}
/**
 *  文件数据写入
 *
 *  @param data 数据
 *  @param name 文件名
 */
- (NSString*)writeData:(NSData*)data withFileName:(NSString*)name{
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KCacheReceivePath]) {
        [fileManager createDirectoryAtPath:KCacheReceivePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path=[KCacheReceivePath stringByAppendingPathComponent:name];
    [data writeToFile:path atomically:YES];
    
    return path;
}
/**
 *  将图片写入
 *
 *  @param url       ALAssetsLibrary url
 *  @param fileName  文件名
 *  @param completed 文件保存在本地的路径
 */
- (void)imageWithUrl:(NSURL *)url withFileName:(NSString *)fileName complete:(void(^)(NSString *path))completed{
    // 进这个方法的时候也应该加判断,如果已经转化了的就不要调用这个方法了
    // 如何判断已经转化了,通过是否存在文件路径
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KCacheSendPath]) {
        [fileManager createDirectoryAtPath:KCacheSendPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{});
    if (url) {
        // 主要方法
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            NSString * imagePath = [KCacheSendPath stringByAppendingPathComponent:fileName];
            [data writeToFile:imagePath atomically:YES];
            
            if (completed) {
                completed(imagePath);
            }
            NSLog(@"图片保存成功!!!");
            
        } failureBlock:^(NSError *error) {
            NSLog(@"图片保存失败!!! error=%@",error);
            if (completed) {
                completed(@"");
            }
        }];
    }
}
/**
 *  将视频写入本地
 *
 *  @param url       ALAssetsLibrary url
 *  @param fileName  文件名
 *  @param completed 文件保存在本地的路径
 */
- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName  complete:(void(^)(NSString *path))completed{
    // 创建存放原始video的文件夹
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KCacheSendPath]) {
        [fileManager createDirectoryAtPath:KCacheSendPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    if (url) {
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            NSString * videoPath = [KCacheSendPath stringByAppendingPathComponent:fileName];
            char const *cvideoPath = [videoPath UTF8String];
            FILE *file = fopen(cvideoPath, "a+");
            if (file) {
                const int bufferSize = 1024 * 1024;
                // 初始化一个1M的buffer
                Byte *buffer = (Byte*)malloc(bufferSize);
                NSUInteger read = 0, offset = 0, written = 0;
                NSError* err = nil;
                if (rep.size != 0)
                {
                    do {
                        read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                        written = fwrite(buffer, sizeof(char), read, file);
                        offset += read;
                    } while (read != 0 && !err);//没到结尾，没出错，ok继续
                }
                // 释放缓冲区，关闭文件
                free(buffer);
                buffer = NULL;
                fclose(file);
                file = NULL;
                
                if (completed) {
                    completed(videoPath);
                }
            }
        } failureBlock:^(NSError *error) {
            if (completed) {
                completed(@"");
            }
        }];
    }
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{});
    
}
//取得视频缩图
- (UIImage *)getImage:(NSString *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    return thumb;
}
/**
 *  取得文件夹下的所有文件
 *
 *  @param dirString 文件目录路径
 *
 *  @return 文件列表
 */
- (NSArray*) allFilesAtPath:(NSString*) dirString {
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    for (NSString* fileName in tempArray) {
        BOOL flag = YES;
        NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                [array addObject:fullPath];
            }else{
                NSArray *childs=[self allFilesAtPath:fullPath];
                if (childs&&[childs count]>0) {
                    [array addObjectsFromArray:childs];
                }
            }
        }
        
    }
    return array;
}
/**
 *  取得已发送的文件列表
 *
 *  @return
 */
- (NSArray*)GetSendCacheFileList{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KCacheSendPath]) {
        [fileManager createDirectoryAtPath:KCacheSendPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray *source=[self allFilesAtPath:KCacheSendPath];
    NSMutableArray *cacheFiles=[NSMutableArray arrayWithCapacity:0];
    if ([source count]>0) {
        for (NSString *item in source) {
            FileAttribute *mod=[[FileAttribute alloc] init];
            mod.name=[item lastPathComponent];
            mod.localPath=item;
            mod.bodyLen=(NSUInteger)[self fileSizeAtPath:item];
            mod.sendStauts=FileSendSuccess;
            
            [cacheFiles addObject:mod];
        }
    }
    
    return cacheFiles;
}
/**
 *  取得文件大小
 *
 *  @param filePath 文件路径
 *
 *  @return         文件大小
 */
- (long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
/**
 *  取得已接收的文件列表
 *
 *  @return
 */
- (NSArray*)GetReceiveCacheFileList{
    NSArray *source=[self allFilesAtPath:[BaseDataPack getReceiveFilePath]];
    NSMutableArray *cacheFiles=[NSMutableArray arrayWithCapacity:0];
    if ([source count]>0) {
        for (NSString *item in source) {
            FileAttribute *mod=[[FileAttribute alloc] init];
            mod.localPath=item;
            mod.name=[item lastPathComponent];
            mod.bodyLen=(NSUInteger)[self fileSizeAtPath:item];
            mod.readedLen = mod.bodyLen;
            mod.readStauts=FileReceiveSuccess;
            [cacheFiles addObject:mod];
        }
    }
    return cacheFiles;
}
@end
