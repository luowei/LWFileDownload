//
//  LWViewController.m
//  libFileDownload
//
//  Created by luowei on 04/25/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import "LWViewController.h"

@interface LWViewController ()
@property (weak, nonatomic) IBOutlet UIButton *task1Btn;
@property (weak, nonatomic) IBOutlet UIButton *task2Btn;
@property (weak, nonatomic) IBOutlet UIButton *task3Btn;

@property (weak, nonatomic) IBOutlet UIProgressView *progress1Bar;
@property (weak, nonatomic) IBOutlet UIProgressView *progress2Bar;
@property (weak, nonatomic) IBOutlet UIProgressView *progress3Bar;

@end

@implementation LWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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