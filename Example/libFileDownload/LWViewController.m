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



//    [LWFileDownloadManager downloadFileWithFileName:@"fileName" URLString:@"" showProgressBlock:<#(void (^)())showProgressBlock#> updateProgressBlock:<#(void (^)(float progress))progressBlock#> completeBlock:<#(void (^)())completeBlock#>];


//    LWDLLog(@"======开始");
//    for(int i = 0;i<100;i++){
//        [self serialHandle:i];
//    }


}

//并行下载，串行更新
- (void)downloadFileName:(NSString *)fileName
               urlString:(NSString *)urlString
      updateProgressBlock:(void (^)(float))updateProgressBlock
      serialCompleteBlock:(void (^)())serialCompleteBlock{

//    BOOL exsit = [LWFileDownloadManager exsitFileWithFileName:fileName];
//    if (!exsit) {
//    }

    [LWFileDownloadManager downloadFileWithFileName:fileName
                                          URLString:urlString
                                 requestHandleBlock:^NSMutableURLRequest *(NSMutableURLRequest *request) {
                                     [request setValue:@"XXXXXXXXXXXXXX" forHTTPHeaderField:@"aaaaaaa"];
                                     return request;
                                 }
                                updateProgressBlock:^(float progress) {
                                    LWDLLog(@"======下载：%f", progress);
                                    if(updateProgressBlock){
                                        updateProgressBlock(progress);
                                    }

                                }
                                serialCompleteBlock:^{
                                    LWDLLog(@"======下载完成");
                                    if(serialCompleteBlock){
                                        serialCompleteBlock();
                                    }
                                }
    ];
}


- (IBAction)task1BtnAction:(UIButton *)sender {
    NSString *url = @"https://images.unsplash.com/photo-1556086448-532556fb7631?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&dl=matthew-lejune-1536837-unsplash.jpg";
    [self downloadFileName:@"aaaaa" urlString:url updateProgressBlock:^(float d) {
        self.progress1Bar.progress = d;
    } serialCompleteBlock:^{

    }];
}

- (IBAction)task2BtnAction:(UIButton *)sender {
    NSString *url = @"https://images.unsplash.com/photo-1556086448-532556fb7631?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&dl=matthew-lejune-1536837-unsplash.jpg";
    [self downloadFileName:@"bbbbb" urlString:url updateProgressBlock:^(float d) {
        self.progress2Bar.progress = d;
    } serialCompleteBlock:^{

    }];
}

- (IBAction)task3BtnAction:(UIButton *)sender {
    NSString *url = @"https://images.unsplash.com/photo-1556015522-8b9b1d56d015?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&dl=joel-fulgencio-1534589-unsplash.jpg";
    [self downloadFileName:@"ccccc" urlString:url updateProgressBlock:^(float d) {
        self.progress3Bar.progress = d;
    } serialCompleteBlock:^{

    }];
}

- (IBAction)allBtnAction:(UIButton *)sender {

    NSArray *list = @[
            @"https://images.unsplash.com/photo-1556086448-532556fb7631?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&dl=matthew-lejune-1536837-unsplash.jpg",
            @"https://images.unsplash.com/photo-1556079337-a837a2d11f04?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&dl=todd-kent-1536627-unsplash.jpg",
            @"https://images.unsplash.com/photo-1556015522-8b9b1d56d015?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&dl=joel-fulgencio-1534589-unsplash.jpg",
            @"https://images.unsplash.com/photo-1522165078649-823cf4dbaf46?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&dl=venveo-609390-unsplash.jpg",
            @"https://images.unsplash.com/photo-1527192491265-7e15c55b1ed2?ixlib=rb-1.2.1&q=85&fm=jpg&crop=entropy&cs=srgb&dl=shridhar-gupta-678685-unsplash.jpg",
            ];

    for(int i=0;i<3;i++){
        NSString *fileName = [NSString stringWithFormat:@"aaaaaa_%d",i];
//        [self downloadFileName:fileName urlString:list[i] updateProgressBlock:];
        [self downloadFileName:fileName urlString:list[i] updateProgressBlock:^(float progress) {
            if(i==0){
                self.progress1Bar.progress = progress;
            }else if(i==1){
                self.progress2Bar.progress = progress;
            }else if(i==2){
                self.progress3Bar.progress = progress;
            }

        } serialCompleteBlock:^{

        }];
    }

}




- (void)serialHandle:(NSInteger)idx {
    LWFileDownloadManager *manager = [LWFileDownloadManager shareManager];
    if (!manager.group) {
        manager.group = dispatch_group_create();
    }
    if (!manager.s_queue) {
        manager.s_queue = dispatch_get_main_queue();
//        self.s_queue = dispatch_queue_create("com.koou.com.group.once.queue", DISPATCH_QUEUE_SERIAL);
    }


    dispatch_block_t block = ^{
        LWDLLog(@"======serialCompleteBlock:%d",idx);
    };

    //模拟异步的网络请求
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep((arc4random() % 50) / 100.0f);

        //把block放到group中顺序执行
        dispatch_group_async(manager.group, manager.s_queue, ^{
            block();
        });

    });


}



@end
