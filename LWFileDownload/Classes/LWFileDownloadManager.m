//
// Created by Luo Wei on 2017/11/25.
// Copyright (c) 2017 wodedata. All rights reserved.
//

#import "LWFileDownloadManager.h"

@interface LWFileDownloadManager ()

@property(nonatomic, copy) NSString *diretoryName;

@end

@implementation LWFileDownloadManager {
    NSString *_fileDirectoryPath;
}

static LWFileDownloadManager *_instance = nil;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+(int)alreadyExsitCode{
    return 300;
}

-(NSMutableDictionary *)taskMap{
    if(!_taskMap){
        _taskMap = @{}.mutableCopy;
    }
    return _taskMap;
}

//根据文件名与下载地址，获得路径
+ (NSString *)filePathWithFileName:(NSString *)fileName downloadURLString:(NSString *)urlString
              requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *,LWFileDownloadTask *))requestHandleBlock
             progressBlock:(void (^)(float,LWFileDownloadTask *))updateProgressBlock
             completeBlock:(void (^)(NSError *,LWFileDownloadTask *))serialCompleteBlock {

    NSString *filePath = [LWFileDownloadManager filePathWithFileName:fileName];

    BOOL exsit = [LWFileDownloadManager downloadFileWithFileName:fileName urlString:urlString requestBlock:requestHandleBlock progressBlock:updateProgressBlock completeBlock:serialCompleteBlock];

    if(!exsit){    //从本地bundle中获取
        filePath = [[[NSBundle bundleForClass:self.class] resourcePath] stringByAppendingPathComponent:fileName];
    }
    return filePath;

}

//判断是存已存在，如果不存在就下载,返回下载后的文件路径
+ (BOOL)downloadFileWithFileName:(NSString *)fileName urlString:(NSString *)urlString
                          requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *,LWFileDownloadTask *))requestHandleBlock
                         progressBlock:(void (^)(float,LWFileDownloadTask *))updateProgressBlock
                         completeBlock:(void (^)(NSError *,LWFileDownloadTask *))serialCompleteBlock{

    BOOL exsit = [LWFileDownloadManager exsitFileWithFileName:fileName];
    if (!exsit) {

        //更新request
        NSMutableURLRequest * (^updateRequest)(NSMutableURLRequest *,LWFileDownloadTask *)=^NSMutableURLRequest *(NSMutableURLRequest *request,LWFileDownloadTask *task){
            NSMutableURLRequest *req = request;
            if(requestHandleBlock){
                req = requestHandleBlock(request,task);
            }
            return req;
        };

        void (^progressBlock)(float,LWFileDownloadTask *) =^(float progress,LWFileDownloadTask *task) {
            if(updateProgressBlock){
                updateProgressBlock(progress,task);
            }
        };

        //完成
        void (^completeBlock)(NSError *,LWFileDownloadTask *)=^(NSError *error,LWFileDownloadTask *task) {
            if(serialCompleteBlock){
                serialCompleteBlock(error,task);
            }
        };

        //在这里把tsk存入字典队列
        LWFileDownloadTask *tsk = [LWFileDownloadManager
                downloadWithFileName:fileName
                           urlString:urlString
                        requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request) {
                            request = updateRequest(request, tsk);
                            return request;
                        }
                       progressBlock:^(float progress) {
                           progressBlock(progress, tsk);
                       }
                       completeBlock:^(NSError *error){
                           completeBlock(error,tsk);
                           [[LWFileDownloadManager shareManager].taskMap removeObjectForKey:urlString];  //从任务队列删除
                       }];

        //如果队列中没有任务就加入，并开始
        if(![LWFileDownloadManager shareManager].taskMap[urlString]){
            [LWFileDownloadManager shareManager].taskMap[urlString]=tsk;  //加入任务队列
            [tsk start];
        }

    }

    return exsit;
}

//并行下载,串行回调CompleteBlock //DISPATCH_QUEUE_CONCURRENT DISPATCH_QUEUE_SERIAL
+ (LWFileDownloadTask *)downloadWithFileName:(NSString *)fileName urlString:(NSString *)urlString
                                requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *))requestHandleBlock
                               progressBlock:(void (^)(float))updateProgressBlock
                               completeBlock:(void (^)(NSError *))serialCompleteBlock {

    //构造manager
    LWFileDownloadManager *manager = [LWFileDownloadManager shareManager];
    if (!manager.group) {
        manager.group = dispatch_group_create();
    }
    if (!manager.s_queue) {
        manager.s_queue = dispatch_get_main_queue();
//        self.s_queue = dispatch_queue_create("com.koou.com.group.once.queue", DISPATCH_QUEUE_SERIAL);
    }

    //更新request
    NSMutableURLRequest * (^updateRequest)(NSMutableURLRequest *)=^NSMutableURLRequest *(NSMutableURLRequest *request){
        NSMutableURLRequest *req = request;
        if(requestHandleBlock){
            req = requestHandleBlock(request);
        }
        return req;
    };

    //完成
    void (^completeBlock)(NSError *)=^(NSError *error){
        //把block放到group中顺序执行
        dispatch_group_async(manager.group, manager.s_queue, ^{
            if(serialCompleteBlock){
                serialCompleteBlock(error);
            }
        });
    };

    //新建任务
    LWFileDownloadTask *task = [LWFileDownloadTask taskWithURLString:urlString fileName:fileName];
    task.updateRequest = updateRequest;
    task.updateProgessBlock = updateProgressBlock;
    task.completeBlock = completeBlock;
//    [task start];  //开始下载

//    dispatch_group_notify(manager.group, manager.s_queue, ^{});
    return task;
}


#pragma mark - Helper Method

- (NSString *)fileDirectoryPath {

    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    _fileDirectoryPath = [documentsDirectory stringByAppendingPathComponent:_diretoryName ?: @"data"];

    [LWFileDownloadManager createDirectoryIfNotExsitPath:_fileDirectoryPath];   //创建目录

    LWDLLog(@"======fileDirectoryPath:%@",_fileDirectoryPath);
    LWDLLog(@"======App Bundle Path:%@",[[NSBundle mainBundle] bundlePath]);
    LWDLLog(@"======Home Path:%@",NSHomeDirectory());

    return _fileDirectoryPath;
}

//删除指定目录的文件
+ (BOOL)removeFileWithFilePath:(NSString *)filePath {
    //把文件删除
    NSError *err = nil;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
    if(err){
        LWDLLog(@"Error! %@", err);
    }
    return result;
}

//写入数据到指定路径
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath {
    BOOL result = [data writeToFile:filePath atomically:YES];  //写入到文件
    LWDLLog(@"=======file writeToFile:%@",(result ? @"YES" : @"NO"));
    return result;
}

//获取document下的指定path的绝对路径
+ (NSString *)documentDirectoryPath:(NSString *)path {
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:path];

    [LWFileDownloadManager createDirectoryIfNotExsitPath:directoryPath];
    return directoryPath;
}


//创建目录
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path {
    BOOL success = YES;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]){  //如果则创建文件夹
        NSError * error = nil;
        success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success || error) {
            LWDLLog(@"Error! %@", error);
        } else {
            LWDLLog(@"Create fonts directory Success!");
        }
    }
    return success;
}


//是否存在fileName
+ (BOOL)exsitFileWithFileName:(NSString *)fileName {
    NSString *filePath = [[LWFileDownloadManager shareManager].fileDirectoryPath stringByAppendingPathComponent:fileName];
    BOOL exsit = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return exsit;
}

+(NSString *)filePathWithFileName:(NSString *)fileName {
    NSString *filePath = [[LWFileDownloadManager shareManager].fileDirectoryPath stringByAppendingPathComponent:fileName];
    return filePath;
}

@end





#pragma mark - LWFileDownloadTask Concurrence Download

@implementation LWFileDownloadTask


+ (instancetype)taskWithURLString:(NSString *)urlString fileName:(NSString *)fileName {
    LWFileDownloadTask *task = [[LWFileDownloadTask alloc] init];
    task.urlString = urlString;
    task.fileName = fileName;
    return task;
}

#pragma mark -

-(void)start{
    [self downloadCustomFileWithfileName:self.fileName URLString:self.urlString];
}


//下载
- (void)downloadCustomFileWithfileName:(NSString *)fileName URLString:(NSString *)urlString {

    self.fileName = fileName;
    BOOL exsit = [LWFileDownloadManager exsitFileWithFileName:fileName];
    if (exsit) {  //如果已经下载过了
        //更新UI
        if(self.updateProgessBlock){
            self.updateProgessBlock(1.0f);
        }
        if(self.completeBlock){
            NSError *error=[NSError errorWithDomain:@"already exsit or downloaded" code:[LWFileDownloadManager alreadyExsitCode] userInfo:@{@"filename": fileName, @"url": urlString, @"msg": @"已经下载过了"}];
            self.completeBlock(error);
        }
        return;
    }

    //构造NSURLSession
    //urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setValue:@"http://app.wodedata.com" forHTTPHeaderField:@"Referer"];

    if(self.updateRequest){
        request = self.updateRequest(request);
    }

    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:self
                                                            delegateQueue:[NSOperationQueue mainQueue]];

    if(self.curretnDataTask && self.curretnDataTask.state != NSURLSessionTaskStateCompleted){   //取消原来的任务
        [self.curretnDataTask cancel];
    }
    self.curretnDataTask = [defaultSession dataTaskWithRequest:request];
    [self.curretnDataTask resume];

}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    LWDLLog(@"--------%d:%s \n", __LINE__, __func__);
    completionHandler(NSURLSessionResponseAllow);

    self.progress = 0.0f;
    self.downloadSize = [response expectedContentLength];
    self.dataToDownload = [[NSMutableData alloc] init];

//    dispatch_async(dispatch_get_main_queue(), ^{
//        if(self.showProgressBlock){ //显示下载进度提示,开始显示下载进度
//            self.showProgressBlock();
//        }
//    });
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    LWDLLog(@"--------%d:%s \n", __LINE__, __func__);

    [self.dataToDownload appendData:data];
    self.progress = (float) [self.dataToDownload length] / self.downloadSize;
    LWDLLog(@"=======progress:%.4f, dataToDownload:%lli, downloadSize:%lli", self.progress,
            (long long int) self.dataToDownload.length, self.downloadSize);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.updateProgessBlock) {
            self.updateProgessBlock(self.progress >= 1 ? 1 : self.progress);
        }

        if (self.progress < 1) {
            return;
        }

    });
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    LWDLLog(@"--------%d:%s \n", __LINE__, __func__);
    LWDLLog(@"=====completed; error: %@", error);

    BOOL exsit = [LWFileDownloadManager exsitFileWithFileName:self.fileName];
    if (!error && !exsit) {
        //写入文件
        NSString *filePath = [[LWFileDownloadManager shareManager].fileDirectoryPath stringByAppendingPathComponent:self.fileName];
        [LWFileDownloadManager writeData:self.dataToDownload toFilePath:filePath];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        //更新UI
        if (self.completeBlock) {
            self.completeBlock(error);
        }
    });

}

@end




