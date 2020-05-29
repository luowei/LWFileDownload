//
// Created by Luo Wei on 2020/5/29.
//

#import "LWDownloadBiz.h"
#import "LWFileDownloadManager.h"


@implementation LWDownloadBiz {

}

+ (instancetype)share {
    static LWDownloadBiz *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

// ---- 下载文件 ----

/**
 * 根据dbFileName,dbURLString 获得db文件的路径
 * dbFileName：EnwordsFileName，WBwordsFileName，BiHuaFileName，PinYinFileName，ZidianFileName
 * dbURLString：EnwordsURLString，WBwordsURLString，BiHuaURLString，PinYinURLString，ZidianURLString
 */
- (NSString *)dbPathWithDBFileName:(NSString *)dbFileName dbURLString:(NSString *)dbURLString {

    NSString *filePath = [LWFileDownloadManager filePathWithFileName:dbFileName];
    if(![self downloadDBFileWithDBFileName:dbFileName dbURLString:dbURLString]){    //从本地bundle中获取
        filePath = [[[NSBundle bundleForClass:self.class] resourcePath] stringByAppendingPathComponent:dbFileName];
    }
    return filePath;
}

- (NSString *)dbPathWithZipFileName:(NSString *)dbFileName dbURLString:(NSString *)dbURLString {
    //下载zip文件
    NSString *filePath = [LWFileDownloadManager filePathWithFileName:dbFileName];
    NSString *zipFileName = [dbFileName stringByAppendingString:@".zip"];
    BOOL success=[self downloadDBFileWithDBFileName:zipFileName dbURLString:dbURLString completeBlock:^{
        //todo:解压zip文件
        LWFileDownloadManager *manager = [LWFileDownloadManager shareManager];
        NSString *zipPath = [manager.fileDirectoryPath stringByAppendingPathComponent:zipFileName];
        NSString *unzipPath = [manager.fileDirectoryPath stringByAppendingPathComponent:dbFileName];
        [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
    }];
    if(!success){
        filePath = [[[NSBundle bundleForClass:self.class] resourcePath] stringByAppendingPathComponent:dbFileName];
    }
    return filePath;
}


//下载文件
-(BOOL)downloadDBFileWithDBFileName:(NSString *)dbFileName dbURLString:(NSString *)dbURLString {
    return [self downloadDBFileWithDBFileName:dbFileName dbURLString:dbURLString completeBlock:nil];
}

- (BOOL)downloadDBFileWithDBFileName:(NSString *)dbFileName dbURLString:(NSString *)dbURLString completeBlock:(void (^)())completeBlock{
    BOOL exsit = [LWFileDownloadManager exsitFileWithFileName:dbFileName];
    if (!exsit) {
        __block LWFileDownloadTask *task = nil;
        /*task = */[LWFileDownloadManager downloadFileWithFileName:dbFileName
                                                         URLString:dbURLString
                                                requestHandleBlock:^NSMutableURLRequest *(NSMutableURLRequest *request) {
                                                    LWDLLog(@"=====开始下载");
//                                                    [LWMaskProgressView showMaskProgressViewin:vc.view withText:NSLocalizedString(@"Cancel", nil) progress:0 dismissBlock:^{
//                                                        [task.curretnDataTask cancel];
//                                                    }];
                                                    return request;
                                                }
                                               updateProgressBlock:^(float progress) {
                                                   LWDLLog(@"======下载：%f", progress);
//                                                   [LWMaskProgressView showMaskProgressViewin:vc.view withText:NSLocalizedString(@"Cancel", nil) progress:progress dismissBlock:^{
//                                                       [task.curretnDataTask cancel];
//                                                   }];
                                               }
                                               serialCompleteBlock:^{
                                                   LWDLLog(@"======下载完成");
//                                                   [LWMaskProgressView dismissMaskProgressViewin:vc.view];
                                                    if(completeBlock){
                                                        completeBlock();
                                                    }
                                               }];
    }
    return exsit;
}

@end