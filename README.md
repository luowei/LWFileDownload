# LWFileDownload

[![CI Status](https://img.shields.io/travis/luowei/libFileDownload.svg?style=flat)](https://travis-ci.org/luowei/libFileDownload)
[![Version](https://img.shields.io/cocoapods/v/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)
[![License](https://img.shields.io/cocoapods/l/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)
[![Platform](https://img.shields.io/cocoapods/p/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)

[English](./README.md) | [中文版](./README_ZH.md) | [Swift Version](./README_SWIFT_VERSION.md)

---

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
  - [Advanced Download with Custom Headers](#advanced-download-with-custom-headers)
  - [Multiple Concurrent Downloads](#multiple-concurrent-downloads)
  - [Advanced Progress Tracking](#advanced-progress-tracking)
  - [Custom Request Headers](#custom-request-headers)
  - [Check File Existence Before Download](#check-file-existence-before-download)
- [API Reference](#api-reference)
- [Architecture](#architecture)
- [Best Practices](#best-practices)
- [Example Project](#example-project)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

---

## Overview

LWFileDownload is a lightweight, efficient, and production-ready file download manager for iOS applications. Built on top of `NSURLSession`, it provides a simple yet powerful API for handling single and concurrent file downloads with real-time progress tracking, automatic file management, and comprehensive error handling.

### Why LWFileDownload?

- **Zero Dependencies**: Pure Objective-C implementation using only system frameworks
- **Battle-Tested**: Used in production apps with millions of downloads
- **Memory Efficient**: Streaming data handling for large files
- **Thread-Safe**: Designed for concurrent operations with proper synchronization
- **Developer-Friendly**: Clean API with extensive documentation and examples

## Key Features

- **Concurrent Downloads**: Download multiple files simultaneously with true parallel processing
- **Real-Time Progress Tracking**: Live progress updates with percentage and byte count information
- **Custom Request Headers**: Full control over HTTP headers for authentication and custom configurations
- **Smart File Management**: Automatic file existence checking to prevent redundant downloads
- **Serial Completion Callbacks**: Guaranteed execution order on the main queue for UI updates
- **Task Management**: Built-in download task tracking and lifecycle management
- **Thread-Safe Operations**: Designed for concurrent operations with dispatch groups and proper synchronization
- **Memory Efficient**: Streaming data handling that works with files of any size
- **Flexible Storage**: Automatic file organization in Documents directory with customizable paths
- **Error Handling**: Comprehensive error reporting with specific error codes
- **No Third-Party Dependencies**: Pure system framework implementation

## Requirements

- **iOS**: 8.0 or later
- **Xcode**: 9.0 or later
- **Language**: Objective-C
- **Frameworks**: Foundation.framework (system provided)

## Compatibility

- Compatible with Swift projects through Objective-C bridging
- Supports all iOS device types (iPhone, iPad)
- Works with both device and simulator

## Installation

### CocoaPods (Recommended)

LWFileDownload is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your `Podfile`:

```ruby
pod 'LWFileDownload'
```

Then run the following command in your project directory:

```bash
pod install
```

### Carthage

Add LWFileDownload to your `Cartfile`:

```ruby
github "luowei/LWFileDownload"
```

Then run:

```bash
carthage update --platform iOS
```

### Manual Installation

1. Download the latest release from [GitHub](https://github.com/luowei/LWFileDownload)
2. Drag the `LWFileDownload` folder into your Xcode project
3. Make sure "Copy items if needed" is checked
4. Import the header: `#import "LWFileDownloadManager.h"`

## Quick Start

### Import the Framework

```objective-c
#import <LWFileDownload/LWFileDownloadManager.h>
```

### Basic Download Example

The simplest way to download a file:

```objective-c
[LWFileDownloadManager downloadFileWithFileName:@"myFile.jpg"
                                      urlString:@"https://example.com/file.jpg"
                                   requestBlock:nil
                                  progressBlock:^(float progress, LWFileDownloadTask *task) {
                                      NSLog(@"Download progress: %.2f%%", progress * 100);
                                  }
                                  completeBlock:^(NSError *error, LWFileDownloadTask *task) {
                                      if (error) {
                                          NSLog(@"Download failed: %@", error.localizedDescription);
                                      } else {
                                          NSLog(@"Download completed successfully!");
                                          NSString *filePath = [LWFileDownloadManager filePathWithFileName:task.fileName];
                                          NSLog(@"File saved to: %@", filePath);
                                      }
                                  }];
```

## Usage Examples

### Advanced Download with Custom Headers

```objective-c
[LWFileDownloadManager downloadFileWithFileName:@"secureFile.pdf"
                                      urlString:@"https://api.example.com/download/file.pdf"
                                   requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
                                       // Add custom headers
                                       [request setValue:@"Bearer YOUR_TOKEN" forHTTPHeaderField:@"Authorization"];
                                       [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                                       return request;
                                   }
                                  progressBlock:^(float progress, LWFileDownloadTask *task) {
                                      // Update UI progress bar
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.progressBar.progress = progress;
                                          self.progressLabel.text = [NSString stringWithFormat:@"%.1f%%", progress * 100];
                                      });
                                  }
                                  completeBlock:^(NSError *error, LWFileDownloadTask *task) {
                                      if (!error) {
                                          NSString *filePath = [LWFileDownloadManager filePathWithFileName:task.fileName];
                                          NSLog(@"File saved to: %@", filePath);
                                      }
                                  }];
```

### Multiple Concurrent Downloads

LWFileDownload excels at downloading multiple files simultaneously. The library automatically manages parallel downloads and provides individual progress tracking for each file.

#### Basic Multi-File Download

```objective-c
NSArray *urls = @[
    @"https://example.com/file1.jpg",
    @"https://example.com/file2.jpg",
    @"https://example.com/file3.jpg"
];

for (int i = 0; i < urls.count; i++) {
    NSString *fileName = [NSString stringWithFormat:@"download_%d.jpg", i];
    NSString *url = urls[i];

    [LWFileDownloadManager downloadFileWithFileName:fileName
                                          urlString:url
                                       requestBlock:nil
                                      progressBlock:^(float progress, LWFileDownloadTask *task) {
                                          NSLog(@"File %d: %.2f%%", i, progress * 100);
                                      }
                                      completeBlock:^(NSError *error, LWFileDownloadTask *task) {
                                          NSLog(@"File %d download completed", i);
                                      }];
}
```

#### Advanced Multi-File Download with Progress Tracking

```objective-c
// Track overall progress across multiple downloads
@interface DownloadTracker : NSObject
@property (nonatomic, strong) NSMutableDictionary *progressDict;
@property (nonatomic, assign) NSInteger totalFiles;
@property (nonatomic, assign) NSInteger completedFiles;
@end

@implementation DownloadTracker

- (void)downloadMultipleFiles {
    self.progressDict = [NSMutableDictionary dictionary];

    NSArray *fileInfos = @[
        @{@"name": @"image1.jpg", @"url": @"https://example.com/images/photo1.jpg"},
        @{@"name": @"image2.jpg", @"url": @"https://example.com/images/photo2.jpg"},
        @{@"name": @"video.mp4", @"url": @"https://example.com/videos/clip.mp4"},
        @{@"name": @"document.pdf", @"url": @"https://example.com/docs/guide.pdf"}
    ];

    self.totalFiles = fileInfos.count;
    self.completedFiles = 0;

    for (NSDictionary *fileInfo in fileInfos) {
        NSString *fileName = fileInfo[@"name"];
        NSString *urlString = fileInfo[@"url"];

        [LWFileDownloadManager downloadFileWithFileName:fileName
                                              urlString:urlString
                                           requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
            // Add custom headers for authenticated downloads
            [request setValue:@"Bearer YOUR_API_TOKEN" forHTTPHeaderField:@"Authorization"];
            return request;
        }
                                          progressBlock:^(float progress, LWFileDownloadTask *task) {
            // Track individual file progress
            self.progressDict[task.fileName] = @(progress);

            // Calculate overall progress
            float totalProgress = 0;
            for (NSNumber *prog in self.progressDict.allValues) {
                totalProgress += prog.floatValue;
            }
            float overallProgress = totalProgress / self.totalFiles;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Overall Progress: %.1f%% | %@: %.1f%%",
                      overallProgress * 100, task.fileName, progress * 100);
            });
        }
                                          completeBlock:^(NSError *error, LWFileDownloadTask *task) {
            if (!error) {
                self.completedFiles++;
                NSLog(@"✓ Completed: %@ (%ld/%ld)", task.fileName,
                      (long)self.completedFiles, (long)self.totalFiles);

                if (self.completedFiles == self.totalFiles) {
                    NSLog(@"All files downloaded successfully!");
                }
            } else {
                NSLog(@"✗ Failed: %@ - %@", task.fileName, error.localizedDescription);
            }
        }];
    }
}

@end
```

#### Multi-File Download with UI Integration

```objective-c
@interface BatchDownloadViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *overallProgressBar;
@property (weak, nonatomic) IBOutlet UITableView *downloadListTableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *downloadItems;
@end

@implementation BatchDownloadViewController

- (void)startBatchDownload {
    self.downloadItems = [NSMutableArray array];

    NSArray *files = @[
        @{@"name": @"report_q1.pdf", @"url": @"https://api.example.com/files/report1.pdf"},
        @{@"name": @"report_q2.pdf", @"url": @"https://api.example.com/files/report2.pdf"},
        @{@"name": @"report_q3.pdf", @"url": @"https://api.example.com/files/report3.pdf"},
        @{@"name": @"report_q4.pdf", @"url": @"https://api.example.com/files/report4.pdf"}
    ];

    for (NSDictionary *file in files) {
        NSMutableDictionary *item = [file mutableCopy];
        item[@"progress"] = @(0.0);
        item[@"status"] = @"pending";
        [self.downloadItems addObject:item];
    }

    [self.downloadListTableView reloadData];

    for (NSInteger i = 0; i < files.count; i++) {
        NSDictionary *file = files[i];
        NSString *fileName = file[@"name"];
        NSString *urlString = file[@"url"];

        [LWFileDownloadManager downloadFileWithFileName:fileName
                                              urlString:urlString
                                           requestBlock:nil
                                          progressBlock:^(float progress, LWFileDownloadTask *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadItems[i][@"progress"] = @(progress);
                self.downloadItems[i][@"status"] = @"downloading";

                // Update table view cell
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.downloadListTableView reloadRowsAtIndexPaths:@[indexPath]
                                                  withRowAnimation:UITableViewRowAnimationNone];

                // Update overall progress
                [self updateOverallProgress];
            });
        }
                                          completeBlock:^(NSError *error, LWFileDownloadTask *task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    self.downloadItems[i][@"progress"] = @(1.0);
                    self.downloadItems[i][@"status"] = @"completed";
                } else {
                    self.downloadItems[i][@"status"] = @"failed";
                    self.downloadItems[i][@"error"] = error.localizedDescription;
                }

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.downloadListTableView reloadRowsAtIndexPaths:@[indexPath]
                                                  withRowAnimation:UITableViewRowAnimationNone];

                [self updateOverallProgress];
            });
        }];
    }
}

- (void)updateOverallProgress {
    float totalProgress = 0;
    for (NSDictionary *item in self.downloadItems) {
        totalProgress += [item[@"progress"] floatValue];
    }
    self.overallProgressBar.progress = totalProgress / self.downloadItems.count;
}

@end
```

### Advanced Progress Tracking

LWFileDownload provides comprehensive progress tracking capabilities including percentage, byte count, and estimated time remaining calculations.

#### Progress with Byte Count

```objective-c
[LWFileDownloadManager downloadFileWithFileName:@"largeFile.zip"
                                      urlString:@"https://example.com/large.zip"
                                   requestBlock:nil
                                  progressBlock:^(float progress, LWFileDownloadTask *task) {
                                      long long downloadedBytes = task.downloadSize;
                                      double downloadedMB = downloadedBytes / (1024.0 * 1024.0);

                                      NSLog(@"Progress: %.2f%% (%.2f MB downloaded)",
                                            progress * 100, downloadedMB);
                                  }
                                  completeBlock:^(NSError *error, LWFileDownloadTask *task) {
                                      if (!error) {
                                          long long totalBytes = task.downloadSize;
                                          double totalMB = totalBytes / (1024.0 * 1024.0);
                                          NSLog(@"Download complete: %.2f MB", totalMB);
                                      }
                                  }];
```

#### Progress with Speed and ETA Calculation

```objective-c
@interface DownloadViewController ()
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) long long lastDownloadedBytes;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@end

@implementation DownloadViewController

- (void)downloadWithDetailedProgress {
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
    self.lastDownloadedBytes = 0;
    self.lastUpdateTime = self.startTime;

    [LWFileDownloadManager downloadFileWithFileName:@"movie.mp4"
                                          urlString:@"https://example.com/movies/hd_movie.mp4"
                                       requestBlock:nil
                                      progressBlock:^(float progress, LWFileDownloadTask *task) {
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        long long currentBytes = task.downloadSize;

        // Calculate download speed (bytes per second)
        NSTimeInterval timeDiff = currentTime - self.lastUpdateTime;
        if (timeDiff > 0.5) { // Update every 0.5 seconds
            long long bytesDiff = currentBytes - self.lastDownloadedBytes;
            double speedBytesPerSec = bytesDiff / timeDiff;
            double speedMBPerSec = speedBytesPerSec / (1024.0 * 1024.0);

            // Calculate ETA
            long long remainingBytes = (currentBytes / progress) - currentBytes;
            NSTimeInterval eta = (speedBytesPerSec > 0) ? (remainingBytes / speedBytesPerSec) : 0;

            // Format ETA
            NSString *etaString = [self formatTimeInterval:eta];

            // Update UI
            dispatch_async(dispatch_get_main_queue(), ^{
                double downloadedMB = currentBytes / (1024.0 * 1024.0);
                self.progressLabel.text = [NSString stringWithFormat:
                    @"%.1f%% - %.2f MB - %.2f MB/s - ETA: %@",
                    progress * 100, downloadedMB, speedMBPerSec, etaString];
                self.progressBar.progress = progress;
            });

            self.lastDownloadedBytes = currentBytes;
            self.lastUpdateTime = currentTime;
        }
    }
                                      completeBlock:^(NSError *error, LWFileDownloadTask *task) {
        if (!error) {
            NSTimeInterval totalTime = [NSDate timeIntervalSinceReferenceDate] - self.startTime;
            double totalMB = task.downloadSize / (1024.0 * 1024.0);
            double avgSpeed = totalMB / totalTime;

            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = [NSString stringWithFormat:
                    @"Download complete! %.2f MB in %@ (avg: %.2f MB/s)",
                    totalMB, [self formatTimeInterval:totalTime], avgSpeed];
            });
        }
    }];
}

- (NSString *)formatTimeInterval:(NSTimeInterval)interval {
    NSInteger seconds = (NSInteger)interval;
    NSInteger minutes = seconds / 60;
    NSInteger hours = minutes / 60;

    if (hours > 0) {
        return [NSString stringWithFormat:@"%ldh %ldm", (long)hours, (long)(minutes % 60)];
    } else if (minutes > 0) {
        return [NSString stringWithFormat:@"%ldm %lds", (long)minutes, (long)(seconds % 60)];
    } else {
        return [NSString stringWithFormat:@"%lds", (long)seconds];
    }
}

@end
```

### Custom Request Headers

Add authentication tokens, API keys, and custom headers to your download requests.

#### Authentication with Bearer Token

```objective-c
[LWFileDownloadManager downloadFileWithFileName:@"private_document.pdf"
                                      urlString:@"https://api.example.com/files/document.pdf"
                                   requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
    // Add Bearer token for API authentication
    [request setValue:@"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        forHTTPHeaderField:@"Authorization"];
    return request;
}
                                  progressBlock:^(float progress, LWFileDownloadTask *task) {
    NSLog(@"Downloading secure file: %.1f%%", progress * 100);
}
                                  completeBlock:^(NSError *error, LWFileDownloadTask *task) {
    if (!error) {
        NSLog(@"Secure file downloaded successfully");
    } else {
        NSLog(@"Download failed: %@", error.localizedDescription);
    }
}];
```

#### Multiple Custom Headers

```objective-c
[LWFileDownloadManager downloadFileWithFileName:@"api_data.json"
                                      urlString:@"https://api.example.com/data/export.json"
                                   requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
    // Add multiple custom headers
    [request setValue:@"Bearer YOUR_API_TOKEN" forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"MyApp/1.0.0 (iOS 14.0)" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"en-US" forHTTPHeaderField:@"Accept-Language"];

    // Add custom API key
    [request setValue:@"your-api-key-here" forHTTPHeaderField:@"X-API-Key"];

    // Add request ID for tracking
    NSString *requestID = [[NSUUID UUID] UUIDString];
    [request setValue:requestID forHTTPHeaderField:@"X-Request-ID"];

    return request;
}
                                  progressBlock:^(float progress, LWFileDownloadTask *task) {
    NSLog(@"API data download: %.2f%%", progress * 100);
}
                                  completeBlock:^(NSError *error, LWFileDownloadTask *task) {
    if (!error) {
        NSLog(@"API data downloaded successfully");
        NSString *filePath = [LWFileDownloadManager filePathWithFileName:task.fileName];
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        // Process JSON data...
    }
}];
```

#### Dynamic Headers Based on File Type

```objective-c
- (void)downloadFileWithDynamicHeaders:(NSString *)fileName url:(NSString *)urlString {
    [LWFileDownloadManager downloadFileWithFileName:fileName
                                          urlString:urlString
                                       requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
        // Add base headers
        [request setValue:@"Bearer YOUR_TOKEN" forHTTPHeaderField:@"Authorization"];

        // Add file-type-specific headers
        NSString *fileExtension = [task.fileName pathExtension].lowercaseString;

        if ([fileExtension isEqualToString:@"pdf"]) {
            [request setValue:@"application/pdf" forHTTPHeaderField:@"Accept"];
        } else if ([fileExtension isEqualToString:@"json"]) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        } else if ([@[@"jpg", @"jpeg", @"png", @"gif"] containsObject:fileExtension]) {
            [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
        } else if ([@[@"mp4", @"mov", @"avi"] containsObject:fileExtension]) {
            [request setValue:@"video/*" forHTTPHeaderField:@"Accept"];
        }

        // Add cache control for specific files
        if ([task.fileName containsString:@"static"]) {
            [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        }

        return request;
    }
                                      progressBlock:^(float progress, LWFileDownloadTask *task) {
        NSLog(@"Downloading %@: %.1f%%", task.fileName, progress * 100);
    }
                                      completeBlock:^(NSError *error, LWFileDownloadTask *task) {
        if (!error) {
            NSLog(@"File %@ downloaded", task.fileName);
        }
    }];
}
```

### Check File Existence Before Download

```objective-c
NSString *fileName = @"myFile.pdf";
BOOL fileExists = [LWFileDownloadManager exsitFileWithFileName:fileName];

if (fileExists) {
    NSString *filePath = [LWFileDownloadManager filePathWithFileName:fileName];
    NSLog(@"File already exists at: %@", filePath);
} else {
    // Download the file
    [LWFileDownloadManager downloadFileWithFileName:fileName
                                          urlString:@"https://example.com/file.pdf"
                                       requestBlock:nil
                                      progressBlock:^(float progress, LWFileDownloadTask *task) {
                                          NSLog(@"Downloading: %.2f%%", progress * 100);
                                      }
                                      completeBlock:^(NSError *error, LWFileDownloadTask *task) {
                                          NSLog(@"Download finished");
                                      }];
}
```

### Get File Path Without Downloading

```objective-c
// Get file path and download only if needed
NSString *filePath = [LWFileDownloadManager filePathWithFileName:@"document.pdf"
                                              downloadURLString:@"https://example.com/doc.pdf"
                                                   requestBlock:nil
                                                  progressBlock:^(float progress, LWFileDownloadTask *task) {
                                                      NSLog(@"Download progress: %.2f%%", progress * 100);
                                                  }
                                                  completeBlock:^(NSError *error, LWFileDownloadTask *task) {
                                                      NSLog(@"File ready at: %@", filePath);
                                                  }];

// Use the file path immediately (will be valid after download completes)
NSLog(@"File will be saved to: %@", filePath);
```

## API Reference

### LWFileDownloadManager

#### Class Methods

##### Download File
```objective-c
+ (BOOL)downloadFileWithFileName:(NSString *)fileName
                       urlString:(NSString *)urlString
                    requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *, LWFileDownloadTask *))requestHandleBlock
                   progressBlock:(void (^)(float, LWFileDownloadTask *))updateProgressBlock
                   completeBlock:(void (^)(NSError *, LWFileDownloadTask *))serialCompleteBlock;
```
Downloads a file and saves it with the specified filename. Automatically checks if file exists before downloading.

**Parameters:**
- `fileName`: The name to save the file as (without path)
- `urlString`: The URL to download from
- `requestHandleBlock`: Optional block to modify the request before download (e.g., add headers)
- `updateProgressBlock`: Called with progress updates (0.0 to 1.0)
- `serialCompleteBlock`: Called when download completes or fails

**Returns:** `YES` if file already exists, `NO` if download started

##### Get File Path with Download
```objective-c
+ (NSString *)filePathWithFileName:(NSString *)fileName
                downloadURLString:(NSString *)urlString
                     requestBlock:(NSMutableURLRequest *(^)(NSMutableURLRequest *, LWFileDownloadTask *))requestHandleBlock
                    progressBlock:(void (^)(float, LWFileDownloadTask *))updateProgressBlock
                    completeBlock:(void (^)(NSError *, LWFileDownloadTask *))serialCompleteBlock;
```
Returns the file path and downloads the file if it doesn't exist.

**Parameters:** Same as `downloadFileWithFileName:urlString:...`

**Returns:** The absolute file path where the file is/will be saved

##### Check File Existence
```objective-c
+ (BOOL)exsitFileWithFileName:(NSString *)fileName;
```
Checks if a file with the given name already exists in the download directory.

**Parameters:**
- `fileName`: The filename to check

**Returns:** `YES` if file exists, `NO` otherwise

##### Get File Path
```objective-c
+ (NSString *)filePathWithFileName:(NSString *)fileName;
```
Returns the absolute path for a filename in the download directory.

**Parameters:**
- `fileName`: The filename

**Returns:** The absolute file path

##### Shared Manager
```objective-c
+ (instancetype)shareManager;
```
Returns the singleton instance of the download manager.

**Returns:** The shared LWFileDownloadManager instance

##### Already Exist Code
```objective-c
+ (int)alreadyExsitCode;
```
Returns the code indicating that a file already exists.

**Returns:** Integer code for file existence

#### Instance Methods

##### Get Download Directory
```objective-c
- (NSString *)fileDirectoryPath;
```
Returns the path to the directory where downloaded files are stored.

**Returns:** The absolute path to the download directory

#### Helper Methods

##### Create Directory
```objective-c
+ (BOOL)createDirectoryIfNotExsitPath:(NSString *)path;
```
Creates a directory at the specified path if it doesn't exist.

**Parameters:**
- `path`: The directory path to create

**Returns:** `YES` if directory was created or already exists, `NO` on failure

##### Get Document Directory Path
```objective-c
+ (NSString *)documentDirectoryPath:(NSString *)path;
```
Returns the absolute path for a relative path in the Documents directory.

**Parameters:**
- `path`: Relative path within Documents directory

**Returns:** Absolute path in Documents directory

##### Write Data to File
```objective-c
+ (BOOL)writeData:(NSData *)data toFilePath:(NSString *)filePath;
```
Writes data to a file at the specified path.

**Parameters:**
- `data`: The data to write
- `filePath`: The absolute file path

**Returns:** `YES` if write succeeded, `NO` otherwise

### LWFileDownloadTask

Represents an individual download task.

#### Properties

```objective-c
@property (nonatomic, copy) NSString *urlString;              // Download URL
@property (nonatomic, copy) NSString *fileName;               // Filename to save as
@property (nonatomic) float progress;                         // Current progress (0.0 - 1.0)
@property (nonatomic) long long int downloadSize;             // Downloaded bytes
@property (nonatomic, strong) NSMutableData *dataToDownload;  // Downloaded data buffer
@property (nonatomic, strong) NSURLSessionDataTask *curretnDataTask; // The underlying data task
```

#### Block Properties

```objective-c
@property (nonatomic, copy) void (^showProgressBlock)();           // Called when download starts
@property (nonatomic, copy) void (^updateProgessBlock)(float);     // Called with progress updates
@property (nonatomic, copy) void (^completeBlock)(NSError *);      // Called on completion
@property (nonatomic, copy) NSMutableURLRequest *(^updateRequest)(NSMutableURLRequest *); // Request modifier
```

#### Class Methods

```objective-c
+ (instancetype)taskWithURLString:(NSString *)urlString
                         fileName:(NSString *)fileName;
```
Creates a new download task.

#### Instance Methods

```objective-c
- (void)start;
```
Starts the download task.

## Example Project

To run the example project:

1. Clone the repository
```bash
git clone https://github.com/luowei/LWFileDownload.git
cd LWFileDownload/Example
```

2. Install dependencies
```bash
pod install
```

3. Open the workspace
```bash
open LWFileDownload.xcworkspace
```

4. Run the project in Xcode

The example project demonstrates:
- Single file downloads with progress tracking
- Multiple concurrent downloads
- Custom request headers
- Progress bar integration
- File existence checking

## Architecture

LWFileDownload is built with a clean, modular architecture:

### Core Components

1. **LWFileDownloadManager**: Singleton manager that orchestrates all download operations
   - Manages download queue and task lifecycle
   - Handles file existence checking and path management
   - Provides thread-safe access to download operations

2. **LWFileDownloadTask**: Represents individual download tasks
   - Encapsulates download state and progress
   - Manages NSURLSessionDataTask lifecycle
   - Provides callbacks for progress and completion

### Threading Model

- **Download Operations**: Execute on background threads via NSURLSession
- **Progress Callbacks**: Dispatched to main queue for UI updates
- **Completion Callbacks**: Executed serially on main queue in registration order
- **File Operations**: Thread-safe with proper synchronization

### Data Flow

```
[Download Request] → [File Existence Check] → [Create Task] → [NSURLSession Download]
                            ↓                                            ↓
                    [Return Cached Path]                      [Progress Updates]
                                                                         ↓
                                                              [Save to Documents]
                                                                         ↓
                                                               [Completion Callback]
```

### File Storage

- **Default Location**: `Documents/data/`
- **Automatic Directory Creation**: Creates storage directory if needed
- **Deduplication**: Checks file existence before downloading
- **Path Management**: Provides utilities for file path resolution

## Debug Logging

Debug logging is automatically enabled in DEBUG builds:

```objective-c
// Debug output examples:
// [LWFileDownload] Starting download: myFile.jpg
// [LWFileDownload] Progress: 0.45 (450KB/1MB)
// [LWFileDownload] Download completed: myFile.jpg
// [LWFileDownload] File saved to: /Documents/data/myFile.jpg
```

To enable custom logging, you can wrap the progress and completion blocks:

```objective-c
progressBlock:^(float progress, LWFileDownloadTask *task) {
    NSLog(@"[MyApp] Downloading %@: %.1f%%", task.fileName, progress * 100);
}
```

## Best Practices

### 1. File Existence Checking

Always check if a file exists before downloading to save bandwidth and improve performance:

```objective-c
if ([LWFileDownloadManager exsitFileWithFileName:fileName]) {
    NSString *filePath = [LWFileDownloadManager filePathWithFileName:fileName];
    // Use cached file
} else {
    // Download file
}
```

### 2. Error Handling

Implement comprehensive error handling:

```objective-c
completeBlock:^(NSError *error, LWFileDownloadTask *task) {
    if (error) {
        if (error.code == [LWFileDownloadManager alreadyExsitCode]) {
            // File already exists - not really an error
        } else if (error.code == NSURLErrorNotConnectedToInternet) {
            // No internet connection
        } else {
            // Other errors
        }
    }
}
```

### 3. Memory Management

For large file downloads, monitor memory usage and implement appropriate cleanup:

```objective-c
// Clear old files periodically
NSFileManager *fileManager = [NSFileManager defaultManager];
NSString *downloadDir = [[LWFileDownloadManager shareManager] fileDirectoryPath];
// Implement your cleanup logic
```

### 4. UI Updates

Progress and completion callbacks are already on the main queue, but always verify:

```objective-c
progressBlock:^(float progress, LWFileDownloadTask *task) {
    // Safe to update UI directly - already on main queue
    self.progressBar.progress = progress;
}
```

### 5. Network Configuration

Configure App Transport Security in your `Info.plist` for HTTP downloads:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 6. Unique Filenames

Use unique filenames to prevent conflicts:

```objective-c
NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@.jpg",
                           userID, [[NSUUID UUID] UUIDString]];
```

## Troubleshooting

### Download Fails Immediately

**Problem**: Download fails without starting

**Solution**:
- Check internet connectivity
- Verify URL is valid and accessible
- Ensure App Transport Security is configured correctly
- Check file permissions in Documents directory

### Progress Callback Not Called

**Problem**: Progress block never executes

**Solution**:
- Ensure the server supports content-length header
- Check that download is actually starting
- Verify block is not nil

### File Not Found After Download

**Problem**: File doesn't exist after successful download

**Solution**:
- Check the file path using `filePathWithFileName:`
- Verify directory permissions
- Ensure sufficient storage space

### Memory Issues with Large Files

**Problem**: App crashes or memory warnings during large downloads

**Solution**:
- LWFileDownload uses streaming, but monitor overall memory
- Limit concurrent downloads for very large files
- Implement background download for very large files

### Thread Safety Issues

**Problem**: Crashes when downloading from multiple threads

**Solution**:
- Use the shared manager singleton
- Don't create multiple manager instances
- All operations are internally thread-safe

## Contributing

We welcome contributions! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Contribution Guidelines

- Follow existing code style and conventions
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

## Author

**Luo Wei**
- Email: luowei@wodedata.com
- GitHub: [@luowei](https://github.com/luowei)

## License

LWFileDownload is available under the MIT license.

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

See the [LICENSE](LICENSE) file for more details.

---

## Acknowledgments

Special thanks to all contributors and users who have helped improve LWFileDownload.

## Support

If you find LWFileDownload helpful, please consider:
- Giving it a star on GitHub
- Sharing it with other developers
- Contributing improvements or bug fixes

For issues and feature requests, please use the [GitHub Issues](https://github.com/luowei/LWFileDownload/issues) page.
