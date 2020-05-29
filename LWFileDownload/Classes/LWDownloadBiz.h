//
// Created by Luo Wei on 2020/5/29.
//

#import <Foundation/Foundation.h>


@interface LWDownloadBiz : NSObject
+ (instancetype)share;

- (NSString *)dbPathWithZipFileName:(NSString *)dbFileName dbURLString:(NSString *)dbURLString;
- (NSString *)dbPathWithDBFileName:(NSString *)dbFileName dbURLString:(NSString *)dbURLString;

-(BOOL)downloadDBFileWithDBFileName:(NSString *)dbFileName dbURLString:(NSString *)dbURLString;

@end