# LWFileDownload

[![CI Status](https://img.shields.io/travis/luowei/libFileDownload.svg?style=flat)](https://travis-ci.org/luowei/libFileDownload)
[![Version](https://img.shields.io/cocoapods/v/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)
[![License](https://img.shields.io/cocoapods/l/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)
[![Platform](https://img.shields.io/cocoapods/p/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)

## 简介

LWFileDownload 是一个功能强大且易用的 iOS 文件下载管理器，支持单文件和多文件并行下载。该库基于 NSURLSession 实现，提供了完善的下载进度回调、错误处理和文件管理功能。

### 主要特性

- ✅ 支持单文件下载
- ✅ 支持多文件并行下载
- ✅ 自动检测文件是否已下载，避免重复下载
- ✅ 实时下载进度回调
- ✅ 支持自定义请求头（Request Headers）
- ✅ 串行回调处理，保证线程安全
- ✅ 自动文件路径管理
- ✅ 简洁易用的 API 设计
- ✅ 支持 iOS 8.0+

## 安装

### CocoaPods

LWFileDownload 可通过 [CocoaPods](https://cocoapods.org) 安装。只需在你的 `Podfile` 文件中添加以下内容：

```ruby
pod 'LWFileDownload'
```

然后运行：

```bash
pod install
```

### Carthage

也支持通过 Carthage 安装：

```ruby
github "luowei/LWFileDownload"
```

## 使用示例

### 1. 基本使用 - 单文件下载

```objective-c
#import <LWFileDownload/LWFileDownloadManager.h>

// 文件名和下载地址
NSString *fileName = @"myfile.jpg";
NSString *urlString = @"https://example.com/myfile.jpg";

// 开始下载
BOOL isAlreadyExist = [LWFileDownloadManager downloadFileWithFileName:fileName
                                                             urlString:urlString
                                                          requestBlock:nil
                                                         progressBlock:^(float progress, LWFileDownloadTask *task) {
    // 下载进度回调（主线程）
    NSLog(@"下载进度: %.2f%%", progress * 100);
}
                                                         completeBlock:^(NSError *error, LWFileDownloadTask *task) {
    // 下载完成回调（主线程）
    if (error) {
        if (error.code == [LWFileDownloadManager alreadyExsitCode]) {
            NSLog(@"文件已存在，无需重复下载");
        } else {
            NSLog(@"下载失败: %@", error.localizedDescription);
        }
    } else {
        NSLog(@"下载成功！");
    }
}];

if (isAlreadyExist) {
    NSLog(@"文件已存在于本地");
}
```

### 2. 自定义请求头

```objective-c
// 下载文件并自定义请求头
[LWFileDownloadManager downloadFileWithFileName:fileName
                                       urlString:urlString
                                    requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
    // 自定义请求头
    [request setValue:@"your-token" forHTTPHeaderField:@"Authorization"];
    [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    return request;
}
                                   progressBlock:^(float progress, LWFileDownloadTask *task) {
    // 更新下载进度
    NSLog(@"正在下载 %@: %.2f%%", task.fileName, progress * 100);
}
                                   completeBlock:^(NSError *error, LWFileDownloadTask *task) {
    // 下载完成
    if (!error) {
        NSLog(@"文件 %@ 下载完成", task.fileName);
    }
}];
```

### 3. 多文件并行下载

```objective-c
// 定义要下载的文件列表
NSArray *fileUrls = @[
    @"https://example.com/image1.jpg",
    @"https://example.com/image2.jpg",
    @"https://example.com/image3.jpg",
    @"https://example.com/video.mp4",
    @"https://example.com/document.pdf"
];

// 并行下载多个文件
for (int i = 0; i < fileUrls.count; i++) {
    NSString *fileName = [NSString stringWithFormat:@"file_%d.dat", i];
    NSString *urlString = fileUrls[i];

    [LWFileDownloadManager downloadFileWithFileName:fileName
                                          urlString:urlString
                                       requestBlock:nil
                                      progressBlock:^(float progress, LWFileDownloadTask *task) {
        // 每个文件的下载进度
        NSLog(@"文件 %d: %.2f%%", i, progress * 100);
    }
                                      completeBlock:^(NSError *error, LWFileDownloadTask *task) {
        // 每个文件下载完成的回调
        if (!error) {
            NSLog(@"文件 %d 下载完成", i);
        }
    }];
}
```

### 4. 获取文件路径

```objective-c
// 获取下载文件的存储目录
NSString *fileDirectoryPath = [LWFileDownloadManager shareManager].fileDirectoryPath;
NSLog(@"文件存储目录: %@", fileDirectoryPath);

// 检查文件是否已存在
NSString *fileName = @"myfile.jpg";
BOOL fileExists = [LWFileDownloadManager exsitFileWithFileName:fileName];
if (fileExists) {
    NSLog(@"文件已存在");

    // 获取文件的完整路径
    NSString *filePath = [LWFileDownloadManager filePathWithFileName:fileName];
    NSLog(@"文件路径: %@", filePath);
}
```

### 5. 获取文件路径（带自动下载）

```objective-c
// 如果文件不存在则自动下载，返回文件路径
NSString *filePath = [LWFileDownloadManager filePathWithFileName:@"config.json"
                                                downloadURLString:@"https://example.com/config.json"
                                                     requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
    // 可选：自定义请求
    return request;
}
                                                    progressBlock:^(float progress, LWFileDownloadTask *task) {
    // 下载进度
    NSLog(@"下载进度: %.2f%%", progress * 100);
}
                                                    completeBlock:^(NSError *error, LWFileDownloadTask *task) {
    // 下载完成
    if (!error) {
        NSLog(@"文件下载成功");
    }
}];

// 使用文件路径
NSLog(@"文件路径: %@", filePath);
```

### 6. 完整示例 - 带 UI 更新

```objective-c
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@end

@implementation ViewController

- (IBAction)downloadButtonTapped:(id)sender {
    NSString *fileName = @"large_file.zip";
    NSString *urlString = @"https://example.com/large_file.zip";

    // 禁用下载按钮
    self.downloadButton.enabled = NO;
    self.statusLabel.text = @"开始下载...";

    [LWFileDownloadManager downloadFileWithFileName:fileName
                                          urlString:urlString
                                       requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
        // 添加自定义请求头
        [request setValue:@"MyApp/1.0" forHTTPHeaderField:@"User-Agent"];
        return request;
    }
                                      progressBlock:^(float progress, LWFileDownloadTask *task) {
        // 更新进度条（已在主线程）
        self.progressBar.progress = progress;
        self.statusLabel.text = [NSString stringWithFormat:@"下载中: %.1f%%", progress * 100];
    }
                                      completeBlock:^(NSError *error, LWFileDownloadTask *task) {
        // 下载完成处理（已在主线程）
        self.downloadButton.enabled = YES;

        if (error) {
            if (error.code == [LWFileDownloadManager alreadyExsitCode]) {
                self.statusLabel.text = @"文件已存在";
                self.progressBar.progress = 1.0;
            } else {
                self.statusLabel.text = [NSString stringWithFormat:@"下载失败: %@", error.localizedDescription];
                self.progressBar.progress = 0.0;
            }
        } else {
            self.statusLabel.text = @"下载完成！";
            self.progressBar.progress = 1.0;

            // 获取文件路径并使用
            NSString *filePath = [LWFileDownloadManager filePathWithFileName:fileName];
            NSLog(@"文件已保存到: %@", filePath);
        }
    }];
}

@end
```

## API 文档

### LWFileDownloadManager 类方法

#### 获取单例

```objective-c
+ (instancetype)shareManager;
```

#### 下载文件

```objective-c
+ (BOOL)downloadFileWithFileName:(NSString *)fileName
                       urlString:(NSString *)urlString
                    requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *, LWFileDownloadTask *))requestHandleBlock
                   progressBlock:(void (^)(float, LWFileDownloadTask *))updateProgressBlock
                   completeBlock:(void (^)(NSError *, LWFileDownloadTask *))serialCompleteBlock;
```

**参数说明：**
- `fileName`: 要保存的文件名
- `urlString`: 下载地址
- `requestHandleBlock`: 请求自定义回调（可选，用于添加请求头等）
- `updateProgressBlock`: 进度更新回调（主线程）
- `serialCompleteBlock`: 下载完成回调（主线程）

**返回值：** `YES` 表示文件已存在，`NO` 表示开始下载

#### 获取文件路径（带自动下载）

```objective-c
+ (NSString *)filePathWithFileName:(NSString *)fileName
                 downloadURLString:(NSString *)urlString
                      requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *, LWFileDownloadTask *))requestHandleBlock
                     progressBlock:(void (^)(float, LWFileDownloadTask *))updateProgressBlock
                     completeBlock:(void (^)(NSError *, LWFileDownloadTask *))serialCompleteBlock;
```

如果文件不存在，会自动开始下载。立即返回文件路径（可能是本地沙盒路径或 Bundle 路径）。

#### 辅助方法

```objective-c
// 检查文件是否存在
+ (BOOL)exsitFileWithFileName:(NSString *)fileName;

// 获取文件路径
+ (NSString *)filePathWithFileName:(NSString *)fileName;

// 获取 Document 目录下的路径
+ (NSString *)documentDirectoryPath:(NSString *)path;

// 写入数据到文件
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath;

// 创建目录
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path;

// 获取"已存在"错误码
+ (int)alreadyExsitCode;  // 返回 300
```

### LWFileDownloadTask 类

下载任务对象，包含下载相关信息：

**属性：**
- `urlString`: 下载地址
- `fileName`: 文件名
- `progress`: 当前下载进度（0.0 - 1.0）
- `downloadSize`: 文件总大小（字节）

## 工作原理

1. **单例管理器**: 使用单例模式管理所有下载任务
2. **自动去重**: 下载前会检查文件是否已存在，避免重复下载
3. **任务队列**: 使用字典管理所有活跃的下载任务，防止同一 URL 重复下载
4. **并行下载**: 基于 NSURLSession 实现真正的并行下载
5. **串行回调**: 使用 GCD 的 dispatch_group 确保回调按顺序在主线程执行
6. **自动文件管理**: 下载完成后自动保存到 Documents/data 目录

## 文件存储

- 默认存储路径：`Documents/data/`
- 可通过 `[LWFileDownloadManager shareManager].fileDirectoryPath` 获取
- 文件会自动保存，无需手动管理

## 注意事项

1. **线程安全**: 进度回调和完成回调都在主线程执行，可以直接更新 UI
2. **错误处理**:
   - 错误码 300 表示文件已存在
   - 其他错误码表示网络或系统错误
3. **内存管理**: 大文件下载时会占用相应内存，下载完成后会自动释放
4. **网络权限**: 需要在 Info.plist 中配置网络访问权限（App Transport Security）

## 示例项目

要运行示例项目，请按以下步骤操作：

1. 克隆仓库
```bash
git clone https://github.com/luowei/LWFileDownload.git
cd LWFileDownload
```

2. 安装依赖
```bash
cd Example
pod install
```

3. 打开项目
```bash
open LWFileDownload.xcworkspace
```

示例项目演示了：
- 单文件下载
- 多文件并行下载
- 实时进度显示
- 错误处理

## 系统要求

- iOS 8.0+
- Xcode 8.0+
- Objective-C

## 依赖

无第三方依赖，仅使用系统框架：
- Foundation.framework

## 作者

**罗威（Luo Wei）**
- Email: luowei@wodedata.com
- GitHub: [@luowei](https://github.com/luowei)

## 许可证

LWFileDownload 基于 MIT 许可证开源。详情请参阅 [LICENSE](LICENSE) 文件。

```
MIT License

Copyright (c) 2017-2025 Luo Wei

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 更新日志

### 1.0.0
- 初始版本发布
- 支持单文件和多文件下载
- 提供进度回调和完成回调
- 自动文件管理和去重

---

**如果觉得这个库对你有帮助，请给个 Star ⭐️ 支持一下！**
