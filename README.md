# libFileDownload

[![CI Status](https://img.shields.io/travis/luowei/libFileDownload.svg?style=flat)](https://travis-ci.org/luowei/libFileDownload)
[![Version](https://img.shields.io/cocoapods/v/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)
[![License](https://img.shields.io/cocoapods/l/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)
[![Platform](https://img.shields.io/cocoapods/p/libFileDownload.svg?style=flat)](https://cocoapods.org/pods/libFileDownload)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```Objective-C
NSString *fileDirectoryPath=[LWFileDownloadManager shareManager].fileDirectoryPath;

BOOL exsitFile = [LWFileDownloadManager exsitFileWithFileName:bundleFileName];

BOOL exsitZip = [LWFileDownloadManager downloadFileWithFileName:zipName urlString:urlString
                                                  requestBlock:updateRequest
                                                 progressBlock:progressBlock
                                                 completeBlock:completeBlock];
```

## Requirements

## Installation

libFileDownload is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'libFileDownload'
```

**Carthage**
```ruby
github "luowei/libFileDownload"
```

## Author

luowei, luowei@wodedata.com

## License

libFileDownload is available under the MIT license. See the LICENSE file for more info.
