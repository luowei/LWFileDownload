//
//  LWViewController.m
//  libFileDownload
//
//  Created by luowei on 04/25/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import <libFileDownload/libFileDownload-umbrella.h>
#import "LWViewController.h"

@interface LWViewController ()
@property(weak, nonatomic) IBOutlet UIButton *task1Btn;
@property(weak, nonatomic) IBOutlet UIButton *task2Btn;
@property(weak, nonatomic) IBOutlet UIButton *task3Btn;

@property(weak, nonatomic) IBOutlet UIProgressView *progress1Bar;
@property(weak, nonatomic) IBOutlet UIProgressView *progress2Bar;
@property(weak, nonatomic) IBOutlet UIProgressView *progress3Bar;

@end

@implementation LWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    LWFileDownloadManager *manager = [LWFileDownloadManager manager];

    [LWFileDownloadManager downloadFileWithFileName:@"fileName" URLString:@"" showProgressBlock:<#(void (^)())showProgressBlock#> updateProgressBlock:<#(void (^)(float progress))progressBlock#> completeBlock:<#(void (^)())completeBlock#>];

    BOOL exsit = [LWFileDownloadManager exsitFileWithFileName:@"fileName"];
    if (!exsit) {
        [LWFileDownloadManager downloadFileWithFileName:@"fileName"
                                              URLString:@"urlString"
                                     requestHandleBlock: ^NSMutableURLRequest *(NSMutableURLRequest *request){
                                         [request setValue:@"XXXXXXXXXXXXXX" forHTTPHeaderField:@"aaaaaaa"];
                                         return request;
                                     }
                                      showProgressBlock:^{
                                          LWDLLog(@"=====开始下载");

                                      }
                                    updateProgressBlock:^(float progress) {
                                        LWDLLog(@"======下载：%f", progress);

                                    }
                                          completeBlock:^{
                                              LWDLLog(@"======下载完成");
                                          }
        ];
    }

    manager.updateRequest = ^NSMutableURLRequest *(NSMutableURLRequest *request){
        [request setValue:@"XXXXXXXXXXXXXX" forHTTPHeaderField:@"aaaaaaa"];
        return request;
    };



}


- (IBAction)task1BtnAction:(UIButton *)sender {
}

- (IBAction)task2BtnAction:(UIButton *)sender {
}

- (IBAction)task3BtnAction:(UIButton *)sender {
}

- (IBAction)allBtnAction:(UIButton *)sender {
}

@end
