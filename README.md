# LWFileDownload

[![CI Status](https://img.shields.io/travis/luowei/libFileDownload.svg?style=flat)](https://travis-ci.org/luowei/libFileDownload)
[![Version](https://img.shields.io/cocoapods/v/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)
[![License](https://img.shields.io/cocoapods/l/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)
[![Platform](https://img.shields.io/cocoapods/p/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)

[中文文档](README_ZH.md)

A lightweight, efficient file download manager for iOS with support for concurrent downloads, progress tracking, and custom request handling.

## Features

- **Concurrent Downloads**: Download multiple files simultaneously with parallel processing
- **Progress Tracking**: Real-time download progress updates with percentage and byte count
- **Custom Request Headers**: Modify HTTP headers before download starts
- **Automatic File Management**: Smart file existence checking and directory management
- **Serial Completion Callbacks**: Completion blocks executed in order on main queue
- **Task Management**: Built-in download task tracking and management
- **Thread-Safe**: Designed for concurrent operations with dispatch groups
- **Memory Efficient**: Handles large file downloads with streaming data
- **Flexible Storage**: Customizable file storage location in Documents directory

## Requirements

- iOS 8.0+
- Xcode 9.0+
- Objective-C

## Installation

### CocoaPods

LWFileDownload is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'LWFileDownload'
```

Then run:
```bash
pod install
```

### Carthage

```ruby
github "luowei/LWFileDownload"
```

Then run:
```bash
carthage update
```

## Usage

### Basic Download Example

```objective-c
#import <LWFileDownload/LWFileDownloadManager.h>

// Simple download with progress tracking
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
                                      }
                                  }];
```

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

## Debug Logging

Debug logging is enabled in DEBUG builds. To see detailed download logs:

```objective-c
// In DEBUG builds, logs are automatically printed
// Example output:
// Download progress: 0.45
// Download completed
```

## Thread Safety

LWFileDownload uses dispatch groups and queues to ensure thread-safe operations:
- Downloads execute in parallel on background threads
- Progress callbacks are dispatched to the main queue
- Completion blocks execute serially in order
- File operations are synchronized

## Best Practices

1. **Always check file existence** before downloading to avoid unnecessary network requests
2. **Use the shared manager** (`shareManager`) for consistent file management
3. **Update UI on main thread** when handling progress callbacks
4. **Handle errors** in completion blocks appropriately
5. **Use unique filenames** to avoid conflicts between downloads
6. **Clean up old files** periodically to manage storage

## Author

luowei, luowei@wodedata.com

## License

LWFileDownload is available under the MIT license. See the LICENSE file for more info.
