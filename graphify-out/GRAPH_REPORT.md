# Graph Report - /Users/luowei/projects/libs/LWFileDownload  (2026-05-04)

## Corpus Check
- Corpus is ~9,976 words - fits in a single context window. You may not need a graph.

## Summary
- 104 nodes · 118 edges · 8 communities detected
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]

## God Nodes (most connected - your core abstractions)
1. `LWFileDownloadManager` - 24 edges
2. `LWFileDownloadViewModel` - 9 edges
3. `LWViewController` - 8 edges
4. `LWFileDownloadTask` - 8 edges
5. `LWAppDelegate` - 7 edges
6. `LWMultipleDownloadsViewModel` - 7 edges
7. `LWFileDownloadTask` - 7 edges
8. `LWDLLog()` - 5 edges
9. `DownloadViewController` - 5 edges
10. `LWFileDownloadProgressView` - 3 edges

## Surprising Connections (you probably didn't know these)
- `LWFileDownloadManager` --inherits--> `NSObject`  [EXTRACTED]
  LWFileDownload/Classes/LWFileDownloadManager.m →   _Bridges community 0 → community 4_
- `LWFileDownloadProgressView` --inherits--> `View`  [EXTRACTED]
  LWFileDownload_swift/Classes/LWFileDownloadView.swift →   _Bridges community 1 → community 6_

## Communities (13 total, 0 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.11
Nodes (15): LWDLLog(), LWFileDownloadManager, -alreadyExsitCode, -createDirectoryIfNotExsitPath, -documentDirectoryPath, -downloadFileWithFileNameurlStringrequestBlockprogressBlockcompleteBlock, -downloadWithFileNameurlStringrequestBlockprogressBlockcompleteBlock, -exsitFileWithFileName (+7 more)

### Community 1 - "Community 1"
Cohesion: 0.13
Nodes (10): CustomRequestExample, DownloadViewController, FileExistenceExample, HelperMethodsExample, MultipleDownloadsExample, MultipleDownloadsExampleView, SimpleDownloadExample, SingleDownloadExampleView (+2 more)

### Community 2 - "Community 2"
Cohesion: 0.2
Nodes (3): LWFileDownloadViewModel, LWMultipleDownloadsViewModel, ObservableObject

### Community 3 - "Community 3"
Cohesion: 0.22
Nodes (8): LWViewController, -allBtnAction, -downloadFileNameurlStringupdateProgressBlockserialCompleteBlock, -serialHandle, -task1BtnAction, -task2BtnAction, -task3BtnAction, -viewDidLoad

### Community 4 - "Community 4"
Cohesion: 0.31
Nodes (3): LWFileDownloadTask, NSObject, URLSessionDataDelegate

### Community 5 - "Community 5"
Cohesion: 0.25
Nodes (7): LWAppDelegate, -applicationDidBecomeActive, -applicationDidEnterBackground, -applicationdidFinishLaunchingWithOptions, -applicationWillEnterForeground, -applicationWillResignActive, -applicationWillTerminate

### Community 6 - "Community 6"
Cohesion: 0.29
Nodes (5): LWFileDownloadProgressView, LWFileDownloadProgressView_Previews, LWMultipleDownloadsView, LWMultipleDownloadsView_Previews, PreviewProvider

### Community 7 - "Community 7"
Cohesion: 0.25
Nodes (7): LWFileDownloadTask, -downloadCustomFileWithfileNameURLString, -start, -taskWithURLStringfileName, -URLSessiondataTaskdidReceiveData, -URLSessiondataTaskdidReceiveResponsecompletionHandler, -URLSessiontaskdidCompleteWithError

## Knowledge Gaps
- **31 isolated node(s):** `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive`, `-applicationDidEnterBackground`, `-applicationWillEnterForeground`, `-applicationDidBecomeActive` (+26 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `LWFileDownloadManager` connect `Community 0` to `Community 4`, `Community 7`?**
  _High betweenness centrality (0.127) - this node is a cross-community bridge._
- **Why does `LWFileDownloadViewModel` connect `Community 2` to `Community 1`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **What connects `-applicationdidFinishLaunchingWithOptions`, `-applicationWillResignActive`, `-applicationDidEnterBackground` to the rest of the system?**
  _31 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.11 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._