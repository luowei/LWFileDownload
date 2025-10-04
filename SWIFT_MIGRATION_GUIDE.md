# LWFileDownload - Swift Migration Guide

This guide explains the Swift/SwiftUI version of the LWFileDownload library and how it compares to the original Objective-C implementation.

## Overview

The Swift version maintains the same core functionality as the Objective-C version while adding modern Swift features including:

- **Swift Type Safety**: Strong typing and modern Swift patterns
- **SwiftUI Support**: Native SwiftUI views for download progress
- **Combine Framework**: Reactive programming support for iOS 13+
- **ObservableObject**: State management for SwiftUI
- **Swift Package Manager**: Modern dependency management

## File Structure

### Created Files

1. **LWFileDownloadManager.swift** (240 lines)
   - Main singleton manager class
   - File download coordination
   - Helper methods for file operations

2. **LWFileDownloadTask.swift** (179 lines)
   - Individual download task handling
   - URLSession delegate implementation
   - Progress tracking

3. **LWFileDownloadViewModel.swift** (154 lines)
   - ObservableObject for SwiftUI integration
   - Single and multiple download view models
   - Combine-based state management

4. **LWFileDownloadView.swift** (180 lines)
   - SwiftUI views for download progress
   - Single file download view
   - Multiple downloads management view

5. **LWFileDownloadExamples.swift** (267 lines)
   - Comprehensive usage examples
   - Both UIKit and SwiftUI examples
   - Common use cases and patterns

6. **Package.swift** (root directory)
   - Swift Package Manager support
   - Modern dependency management

## API Comparison

### Objective-C to Swift API Mapping

#### Singleton Access
```objective-c
// Objective-C
[LWFileDownloadManager shareManager]
```

```swift
// Swift
LWFileDownloadManager.shared
```

#### File Download
```objective-c
// Objective-C
[LWFileDownloadManager downloadFileWithFileName:@"file.pdf"
                                      urlString:@"https://example.com/file.pdf"
                                   requestBlock:^NSMutableURLRequest *(NSMutableURLRequest *request, LWFileDownloadTask *task) {
                                       return request;
                                   }
                                  progressBlock:^(float progress, LWFileDownloadTask *task) {
                                      NSLog(@"Progress: %.2f", progress);
                                  }
                                  completeBlock:^(NSError *error, LWFileDownloadTask *task) {
                                      NSLog(@"Complete");
                                  }];
```

```swift
// Swift
LWFileDownloadManager.downloadFile(
    withFileName: "file.pdf",
    urlString: "https://example.com/file.pdf",
    requestBlock: { request, task in
        return request
    },
    progressBlock: { progress, task in
        print("Progress: \(progress)")
    },
    completeBlock: { error, task in
        print("Complete")
    }
)
```

#### File Existence Check
```objective-c
// Objective-C
BOOL exists = [LWFileDownloadManager exsitFileWithFileName:@"file.pdf"];
```

```swift
// Swift
let exists = LWFileDownloadManager.fileExists(withFileName: "file.pdf")
```

#### Get File Path
```objective-c
// Objective-C
NSString *path = [LWFileDownloadManager filePathWithFileName:@"file.pdf"];
```

```swift
// Swift
let path = LWFileDownloadManager.filePath(withFileName: "file.pdf")
```

## SwiftUI Usage

### Single Download View

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LWFileDownloadViewModel(
        fileName: "example.pdf",
        urlString: "https://example.com/example.pdf"
    )

    var body: some View {
        VStack {
            Text("Download Manager")
                .font(.title)

            LWFileDownloadProgressView(viewModel: viewModel)
                .padding()
        }
    }
}
```

### Multiple Downloads View

```swift
import SwiftUI

struct DownloadsView: View {
    @StateObject private var viewModel = LWMultipleDownloadsViewModel()

    var body: some View {
        VStack {
            Button("Add Downloads") {
                _ = viewModel.addDownload(fileName: "file1.pdf", urlString: "https://example.com/file1.pdf")
                _ = viewModel.addDownload(fileName: "file2.pdf", urlString: "https://example.com/file2.pdf")
            }

            LWMultipleDownloadsView(viewModel: viewModel)
        }
    }
}
```

## UIKit with Combine

```swift
import UIKit
import Combine

class ViewController: UIViewController {
    private var viewModel: LWFileDownloadViewModel?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = LWFileDownloadViewModel(
            fileName: "example.pdf",
            urlString: "https://example.com/example.pdf"
        )

        // Observe progress
        viewModel?.$progress
            .sink { progress in
                print("Progress: \(progress)")
            }
            .store(in: &cancellables)

        // Start download
        viewModel?.startDownload()
    }
}
```

## Key Improvements

### 1. Type Safety
- Strong typing throughout
- Compile-time error checking
- No implicit conversions

### 2. Memory Management
- Automatic Reference Counting (ARC)
- Weak references to prevent retain cycles
- No manual memory management

### 3. Modern Swift Features
- Closures instead of blocks
- Optional chaining
- Guard statements
- Swift error handling

### 4. SwiftUI Integration
- Declarative UI
- Automatic view updates
- State management with @Published
- Combine framework integration

### 5. Async/Await Ready
- Architecture allows easy migration to async/await
- URLSession supports both completion handlers and async/await

## Migration Checklist

If migrating from Objective-C to Swift:

- [ ] Replace Objective-C imports with Swift imports
- [ ] Update singleton access pattern
- [ ] Replace blocks with closures
- [ ] Update error handling (NSError to Error)
- [ ] Consider SwiftUI for new UI components
- [ ] Use Combine for reactive programming
- [ ] Update CocoaPods or switch to SPM

## Compatibility

- **Minimum iOS Version**: iOS 13.0 (for SwiftUI/Combine)
- **Minimum iOS Version** (Core): iOS 8.0 (without SwiftUI)
- **Swift Version**: 5.3+
- **Xcode**: 12.0+

## Installation

### CocoaPods
```ruby
pod 'LWFileDownload'
```

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/luowei/LWFileDownload.git", from: "1.0.0")
]
```

## Notes

- The Swift version is fully compatible with the Objective-C version
- Both can coexist in the same project during migration
- @objc annotations allow Objective-C interoperability
- All public APIs are marked with @objc for backward compatibility

## Support

For issues, questions, or contributions, please visit:
https://github.com/luowei/LWFileDownload

## License

MIT License - Same as original Objective-C version
