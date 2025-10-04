# LWFileDownload Swift版本使用指南

## 概述

LWFileDownload_swift 是 LWFileDownload 的 Swift 实现版本，提供了强大的文件下载管理功能，支持单文件和多文件下载。

## 安装

### CocoaPods

在你的 Podfile 中添加：

```ruby
pod 'LWFileDownload_swift'
```

然后运行：

```bash
pod install
```

## 系统要求

- iOS 10.0+
- Swift 5.0+

## 主要功能

### 1. 文件下载管理

LWFileDownloadManager 提供了完整的文件下载管理功能。

```swift
import LWFileDownload_swift

// 创建下载管理器
let downloadManager = LWFileDownloadManager.shared

// 开始下载
let task = downloadManager.download(url: "https://example.com/file.zip") { progress in
    print("下载进度: \(progress * 100)%")
} completion: { result in
    switch result {
    case .success(let fileURL):
        print("下载完成: \(fileURL)")
    case .failure(let error):
        print("下载失败: \(error)")
    }
}
```

### 2. 下载任务控制

```swift
import LWFileDownload_swift

// 暂停下载
task.pause()

// 恢复下载
task.resume()

// 取消下载
task.cancel()

// 获取下载状态
let state = task.state
```

### 3. 下载视图（LWFileDownloadView）

提供了开箱即用的下载进度视图组件。

```swift
import LWFileDownload_swift

let downloadView = LWFileDownloadView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
downloadView.downloadURL = "https://example.com/file.zip"
self.view.addSubview(downloadView)

// 开始下载
downloadView.startDownload()
```

### 4. 下载视图模型（LWFileDownloadViewModel）

使用 MVVM 模式的下载视图模型。

```swift
import LWFileDownload_swift

let viewModel = LWFileDownloadViewModel(url: "https://example.com/file.zip")

// 观察下载进度
viewModel.onProgressUpdate = { progress in
    print("进度: \(progress)")
}

// 观察下载状态
viewModel.onStateChange = { state in
    print("状态: \(state)")
}

// 开始下载
viewModel.startDownload()
```

## 高级功能

### 多文件下载

```swift
import LWFileDownload_swift

let urls = [
    "https://example.com/file1.zip",
    "https://example.com/file2.zip",
    "https://example.com/file3.zip"
]

let manager = LWFileDownloadManager.shared
for url in urls {
    manager.download(url: url) { progress in
        print("\(url) - 进度: \(progress)")
    } completion: { result in
        print("\(url) - 结果: \(result)")
    }
}
```

### 自定义下载路径

```swift
import LWFileDownload_swift

let task = LWFileDownloadManager.shared.download(
    url: "https://example.com/file.zip",
    destinationPath: "/path/to/save/file.zip"
) { progress in
    print("进度: \(progress)")
} completion: { result in
    print("完成: \(result)")
}
```

## 示例代码

更多使用示例请参考 `LWFileDownloadExamples.swift` 文件。

## 注意事项

1. **网络权限**：确保在 Info.plist 中配置了网络访问权限
2. **后台下载**：支持后台下载，需要在 App Capabilities 中启用 Background Modes
3. **存储空间**：下载前请检查设备存储空间
4. **线程安全**：所有下载操作都是线程安全的

## Objective-C 版本

如果你的项目使用 Objective-C，请使用原版 LWFileDownload：

```ruby
pod 'LWFileDownload'
```

## 许可证

LWFileDownload_swift 使用 MIT 许可证。详见 LICENSE 文件。
