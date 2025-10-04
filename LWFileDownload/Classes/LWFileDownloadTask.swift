//
// Created by Luo Wei on 2017/11/25.
// Copyright (c) 2017 wodedata. All rights reserved.
// Swift version created 2025
//

import Foundation

/// File download task class that handles individual file downloads
@objc public class LWFileDownloadTask: NSObject {

    // MARK: - Properties

    @objc public var urlString: String
    @objc public var fileName: String

    @objc public var progress: Float = 0.0
    @objc public var downloadSize: Int64 = 0

    private var dataToDownload: Data = Data()
    private var currentDataTask: URLSessionDataTask?
    private var session: URLSession?

    // MARK: - Callbacks

    public var showProgressBlock: (() -> Void)?
    public var updateProgressBlock: ((Float) -> Void)?
    public var completeBlock: ((Error?) -> Void)?
    public var updateRequestBlock: ((URLRequest) -> URLRequest)?

    // MARK: - Initialization

    @objc public init(urlString: String, fileName: String) {
        self.urlString = urlString
        self.fileName = fileName
        super.init()
    }

    // MARK: - Public Methods

    @objc public func start() {
        downloadFile(withFileName: fileName, urlString: urlString)
    }

    @objc public func cancel() {
        currentDataTask?.cancel()
    }

    // MARK: - Private Methods

    private func downloadFile(withFileName fileName: String, urlString: String) {
        self.fileName = fileName

        // Check if file already exists
        if LWFileDownloadManager.fileExists(withFileName: fileName) {
            // Update progress
            updateProgressBlock?(1.0)

            // Call completion with "already exists" error
            let error = NSError(
                domain: "already exsit or downloaded",
                code: LWFileDownloadManager.alreadyExistCode,
                userInfo: [
                    "filename": fileName,
                    "url": urlString,
                    "msg": "已经下载过了"
                ]
            )
            completeBlock?(error)
            return
        }

        // Create URL and request
        guard let url = URL(string: urlString) else {
            let error = NSError(
                domain: "Invalid URL",
                code: -1,
                userInfo: ["url": urlString]
            )
            completeBlock?(error)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("http://app.wodedata.com", forHTTPHeaderField: "Referer")

        // Allow request modification
        if let updateRequestBlock = updateRequestBlock {
            request = updateRequestBlock(request)
        }

        // Create URLSession
        let configuration = URLSessionConfiguration.default
        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: .main
        )
        self.session = session

        // Cancel previous task if needed
        if let currentTask = currentDataTask,
           currentTask.state != .completed {
            currentTask.cancel()
        }

        // Start download
        currentDataTask = session.dataTask(with: request)
        currentDataTask?.resume()
    }
}

// MARK: - URLSessionDataDelegate

extension LWFileDownloadTask: URLSessionDataDelegate {

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        LWDLLog("--------%d:%s", #line, #function)
        completionHandler(.allow)

        progress = 0.0
        downloadSize = response.expectedContentLength
        dataToDownload = Data()
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        LWDLLog("--------%d:%s", #line, #function)

        dataToDownload.append(data)
        progress = Float(dataToDownload.count) / Float(downloadSize)

        LWDLLog(
            "=======progress:%.4f, dataToDownload:%lld, downloadSize:%lld",
            progress,
            Int64(dataToDownload.count),
            downloadSize
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if let updateProgressBlock = self.updateProgressBlock {
                let progressValue = self.progress >= 1.0 ? 1.0 : self.progress
                updateProgressBlock(progressValue)
            }
        }
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        LWDLLog("--------%d:%s", #line, #function)
        LWDLLog("=====completed; error: %@", error?.localizedDescription ?? "nil")

        let exists = LWFileDownloadManager.fileExists(withFileName: fileName)

        if error == nil && !exists {
            // Write file to disk
            let filePath = LWFileDownloadManager.filePath(withFileName: fileName)
            LWFileDownloadManager.write(data: dataToDownload, toFilePath: filePath)
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.completeBlock?(error)
        }
    }
}
