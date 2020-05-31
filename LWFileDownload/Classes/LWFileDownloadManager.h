//
// Created by Luo Wei on 2017/11/25.
// Copyright (c) 2017 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LWFileDownloadTask;

#ifdef DEBUG
#define LWDLLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define LWDLLog(format, ...)
#endif

@interface LWFileDownloadManager : NSObject


@property(nonatomic, strong) dispatch_group_t group;
@property(nonatomic, strong) dispatch_queue_main_t s_queue;
//@property(nonatomic) BOOL serialDownload;

@property(nonatomic, strong) NSMutableDictionary *taskMap;

-(NSString *)fileDirectoryPath;

+ (instancetype)shareManager;

+(int)alreadyExsitCode;

//根据文件名与下载地址，获得路径
+ (NSString *)filePathWithFileName:(NSString *)fileName downloadURLString:(NSString *)urlString
                      requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *,LWFileDownloadTask *))requestHandleBlock
                     progressBlock:(void (^)(float,LWFileDownloadTask *))updateProgressBlock
                     completeBlock:(void (^)(NSError *,LWFileDownloadTask *))serialCompleteBlock;

//判断是存已存在，如果不存在就下载
+ (BOOL)downloadFileWithFileName:(NSString *)fileName urlString:(NSString *)urlString
                          requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *,LWFileDownloadTask *))requestHandleBlock
                         progressBlock:(void (^)(float,LWFileDownloadTask *))updateProgressBlock
                         completeBlock:(void (^)(NSError *,LWFileDownloadTask *))serialCompleteBlock;


#pragma mark - Helper Method

//创建目录
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path;

//获取document下的指定path的绝对路径
+ (NSString *)documentDirectoryPath:(NSString *)path;

//写入数据到指定路径
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath;

//是否存在fileName
+ (BOOL)exsitFileWithFileName:(NSString *)fileName;

+(NSString *)filePathWithFileName:(NSString *)fileName;

@end


@interface LWFileDownloadTask : NSObject<NSURLSessionDataDelegate>

@property(nonatomic, copy) NSString *urlString;
@property(nonatomic, copy) NSString *fileName;

@property(nonatomic, copy) void (^showProgressBlock)(); //显示进度条表示真实开始下截
@property(nonatomic, copy) void (^updateProgessBlock)(float);  //更新下载进度及进度条
@property(nonatomic, copy) void (^completeBlock)(NSError *); //完成下载


@property(nonatomic) float progress;
@property(nonatomic) long long int downloadSize;
@property(nonatomic, strong) NSMutableData *dataToDownload;

@property(nonatomic, strong) NSURLSessionDataTask *curretnDataTask;

@property(nonatomic, copy) NSMutableURLRequest * (^updateRequest)(NSMutableURLRequest *);

+ (instancetype)taskWithURLString:(NSString *)urlString fileName:(NSString *)fileName;
//+ (instancetype)taskWithURLString:(NSString *)urlString fileName:(NSString *)fileName
//              UpdateProgressBlock:(void (^)(float progress))progressBlock
//                    completeBlock:(void (^)())completeBlock;

-(void)start;

@end