//
// Created by Luo Wei on 2020/5/29.
//

#import "LWDownloadBiz.h"
#import "LWFileDownloadManager.h"
#import "ZipArchive.h"


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

- (NSString *)bundlePathWithBundleFileName:(NSString *)bundleFileName bundleURLString:(NSString *)dbURLString {
    //下载zip文件
    NSString *zipName=[bundleFileName stringByAppendingString:@".zip"];

    //下载
    NSString *unZipPath=[LWFileDownloadManager shareManager].fileDirectoryPath;
    NSString *zipPath = [unZipPath stringByAppendingPathComponent:zipName];
    __block BOOL exsitZip = [[NSFileManager defaultManager] fileExistsAtPath:zipPath];
    exsitZip=[self downloadDBFileWithDBFileName:zipName dbURLString:dbURLString completeBlock:^{

        //解压
        exsitZip = [[NSFileManager defaultManager] fileExistsAtPath:zipPath];
        if(exsitZip && ![LWFileDownloadManager exsitFileWithFileName:bundleFileName] ){ //不存在就解压
            [SSZipArchive unzipFileAtPath:zipPath toDestination:unZipPath];  //解压zip文件
        }
    }];

    NSString *bundlePath = [unZipPath stringByAppendingPathComponent:bundleFileName];

    //是否存在解压后的文件
    BOOL exsitBundle= [LWFileDownloadManager exsitFileWithFileName:bundleFileName];
    if (exsitZip && !exsitBundle) {
        [SSZipArchive unzipFileAtPath:zipPath toDestination:unZipPath];
    }

    //如果沙盒里没有，就从bundle中去找
    exsitBundle= [LWFileDownloadManager exsitFileWithFileName:bundleFileName];
    if(!exsitBundle){
        bundlePath = [[[NSBundle bundleForClass:self.class] resourcePath] stringByAppendingPathComponent:bundleFileName];
    }
    return bundlePath;
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
                                                    LWDLLog(@"=====%@开始下载",dbFileName);
//                                                    [LWMaskProgressView showMaskProgressViewin:vc.view withText:NSLocalizedString(@"Cancel", nil) progress:0 dismissBlock:^{
//                                                        [task.curretnDataTask cancel];
//                                                    }];
                                                    return request;
                                                }
                                               updateProgressBlock:^(float progress) {
                                                   //LWDLLog(@"======%@下载：%f", progress,dbFileName);
//                                                   [LWMaskProgressView showMaskProgressViewin:vc.view withText:NSLocalizedString(@"Cancel", nil) progress:progress dismissBlock:^{
//                                                       [task.curretnDataTask cancel];
//                                                   }];
                                               }
                                               serialCompleteBlock:^{
                                                   LWDLLog(@"======%@下载完成",dbFileName);
//                                                   [LWMaskProgressView dismissMaskProgressViewin:vc.view];
                                                    if(completeBlock){
                                                        completeBlock();
                                                    }
                                               }];
    }
    return exsit;
}

@end
