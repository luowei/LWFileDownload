//
// Created by Luo Wei on 2017/11/25.
// Copyright (c) 2017 wodedata. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define LWDLLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define LWDLLog(format, ...)
#endif

@interface LWFileDownloadManager : NSObject

@property(nonatomic) float progress;
@property(nonatomic) long long int downloadSize;
@property(nonatomic, strong) NSMutableData *dataToDownload;

@property(nonatomic, strong) NSURLSessionDataTask *curretnDataTask;

+ (instancetype)shareInstance;

//创建目录
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path;

//获取document下的指定path的绝对路径
+ (NSString *)documentDirectoryPath:(NSString *)path;

//写入数据到指定路径
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath;

//是否存在fileName
+ (BOOL)exsitFileWithFileName:(NSString *)fileName;

+(NSString *)filePathWithFileName:(NSString *)fileName;

+ (void)downloadFileWithFileName:(NSString *)fileName URLString:(NSString *)urlString
               showProgressBlock:(void (^)())showProgressBlock
             updateProgressBlock:(void (^)(float progress))progressBlock
                   completeBlock:(void (^)())completeBlock;

@end