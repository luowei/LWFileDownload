//
// Created by Luo Wei on 2017/11/25.
// Copyright (c) 2017 wodedata. All rights reserved.
// Swift/SwiftUI version created 2025
//

import Foundation
import Combine

/// ObservableObject wrapper for file download with SwiftUI support
@available(iOS 13.0, *)
public class LWFileDownloadViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published public var progress: Float = 0.0
    @Published public var isDownloading: Bool = false
    @Published public var downloadError: Error?
    @Published public var isComplete: Bool = false

    // MARK: - Private Properties

    private var task: LWFileDownloadTask?
    public let fileName: String
    public let urlString: String

    // MARK: - Initialization

    public init(fileName: String, urlString: String) {
        self.fileName = fileName
        self.urlString = urlString
    }

    // MARK: - Public Methods

    /// Start downloading the file
    public func startDownload() {
        guard !isDownloading else { return }

        isDownloading = true
        isComplete = false
        downloadError = nil
        progress = 0.0

        LWFileDownloadManager.downloadFile(
            withFileName: fileName,
            urlString: urlString,
            requestBlock: nil,
            progressBlock: { [weak self] progress, _ in
                DispatchQueue.main.async {
                    self?.progress = progress
                }
            },
            completeBlock: { [weak self] error, _ in
                DispatchQueue.main.async {
                    self?.isDownloading = false
                    self?.downloadError = error

                    // Check if it's the "already exists" error (code 300)
                    if let nsError = error as NSError?,
                       nsError.code == LWFileDownloadManager.alreadyExistCode {
                        self?.isComplete = true
                        self?.downloadError = nil
                    } else if error == nil {
                        self?.isComplete = true
                    }
                }
            }
        )
    }

    /// Cancel the download
    public func cancelDownload() {
        task?.cancel()
        isDownloading = false
    }

    /// Check if file exists
    public func fileExists() -> Bool {
        return LWFileDownloadManager.fileExists(withFileName: fileName)
    }

    /// Get file path
    public func filePath() -> String {
        return LWFileDownloadManager.filePath(withFileName: fileName)
    }
}

// MARK: - Multiple Downloads Manager

@available(iOS 13.0, *)
public class LWMultipleDownloadsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published public var downloads: [String: LWFileDownloadViewModel] = [:]
    @Published public var overallProgress: Float = 0.0

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Methods

    /// Add a download to track
    public func addDownload(fileName: String, urlString: String) -> LWFileDownloadViewModel {
        if let existing = downloads[urlString] {
            return existing
        }

        let viewModel = LWFileDownloadViewModel(fileName: fileName, urlString: urlString)
        downloads[urlString] = viewModel

        // Observe progress changes
        viewModel.$progress
            .sink { [weak self] _ in
                self?.updateOverallProgress()
            }
            .store(in: &cancellables)

        return viewModel
    }

    /// Start all downloads
    public func startAll() {
        for download in downloads.values {
            download.startDownload()
        }
    }

    /// Cancel all downloads
    public func cancelAll() {
        for download in downloads.values {
            download.cancelDownload()
        }
    }

    /// Remove completed downloads
    public func removeCompleted() {
        downloads = downloads.filter { !$0.value.isComplete }
    }

    // MARK: - Private Methods

    private func updateOverallProgress() {
        guard !downloads.isEmpty else {
            overallProgress = 0.0
            return
        }

        let totalProgress = downloads.values.reduce(0.0) { $0 + $1.progress }
        overallProgress = totalProgress / Float(downloads.count)
    }
}
