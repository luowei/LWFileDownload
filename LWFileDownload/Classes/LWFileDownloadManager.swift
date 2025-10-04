//
// Created by Luo Wei on 2017/11/25.
// Copyright (c) 2017 wodedata. All rights reserved.
// Swift version created 2025
//

import Foundation

#if DEBUG
func LWDLLog(_ format: String, _ args: CVarArg...) {
    NSLog(format, args)
}
#else
func LWDLLog(_ format: String, _ args: CVarArg...) {}
#endif

/// Main file download manager class - Singleton pattern
@objc public class LWFileDownloadManager: NSObject {

    // MARK: - Properties

    public let group: DispatchGroup
    public let serialQueue: DispatchQueue

    private var taskMap: [String: LWFileDownloadTask] = [:]
    private var directoryName: String = "data"
    private var _fileDirectoryPath: String?

    // MARK: - Singleton

    @objc public static let shared = LWFileDownloadManager()

    private override init() {
        self.group = DispatchGroup()
        self.serialQueue = DispatchQueue.main
        super.init()
    }

    @objc public static var alreadyExistCode: Int {
        return 300
    }

    // MARK: - Public API

    /// Get file path for a given fileName and download URL
    /// - Parameters:
    ///   - fileName: The name of the file
    ///   - urlString: The download URL string
    ///   - requestBlock: Optional block to modify the URLRequest
    ///   - progressBlock: Progress update callback
    ///   - completeBlock: Completion callback
    /// - Returns: The file path (either from documents directory or bundle)
    @objc public static func filePath(
        withFileName fileName: String,
        downloadURLString urlString: String,
        requestBlock: ((URLRequest, LWFileDownloadTask) -> URLRequest)? = nil,
        progressBlock: ((Float, LWFileDownloadTask) -> Void)? = nil,
        completeBlock: ((Error?, LWFileDownloadTask) -> Void)? = nil
    ) -> String {

        var filePath = LWFileDownloadManager.filePath(withFileName: fileName)
        let exists = LWFileDownloadManager.downloadFile(
            withFileName: fileName,
            urlString: urlString,
            requestBlock: requestBlock,
            progressBlock: progressBlock,
            completeBlock: completeBlock
        )

        if !exists {
            // Get from bundle if not in documents
            filePath = Bundle(for: self).resourcePath?.appending("/\(fileName)") ?? filePath
        }

        return filePath
    }

    /// Download file if it doesn't exist
    /// - Parameters:
    ///   - fileName: The name of the file
    ///   - urlString: The download URL string
    ///   - requestBlock: Optional block to modify the URLRequest
    ///   - progressBlock: Progress update callback
    ///   - completeBlock: Completion callback
    /// - Returns: true if file already exists, false if download was initiated
    @objc @discardableResult
    public static func downloadFile(
        withFileName fileName: String,
        urlString: String,
        requestBlock: ((URLRequest, LWFileDownloadTask) -> URLRequest)? = nil,
        progressBlock: ((Float, LWFileDownloadTask) -> Void)? = nil,
        completeBlock: ((Error?, LWFileDownloadTask) -> Void)? = nil
    ) -> Bool {

        let exists = LWFileDownloadManager.fileExists(withFileName: fileName)
        if exists {
            return true
        }

        // Create task with closures that capture the task itself
        var task: LWFileDownloadTask!

        let updateRequestBlock: ((URLRequest) -> URLRequest) = { request in
            if let requestBlock = requestBlock {
                return requestBlock(request, task)
            }
            return request
        }

        let updateProgressBlock: ((Float) -> Void) = { progress in
            progressBlock?(progress, task)
        }

        let completeBlockWrapper: ((Error?) -> Void) = { error in
            completeBlock?(error, task)
            LWFileDownloadManager.shared.taskMap.removeValue(forKey: urlString)
        }

        task = LWFileDownloadManager.download(
            withFileName: fileName,
            urlString: urlString,
            requestBlock: updateRequestBlock,
            progressBlock: updateProgressBlock,
            completeBlock: completeBlockWrapper
        )

        // Add to task queue if not already present
        if LWFileDownloadManager.shared.taskMap[urlString] == nil {
            LWFileDownloadManager.shared.taskMap[urlString] = task
            task.start()
        }

        return false
    }

    // MARK: - Private Methods

    private static func download(
        withFileName fileName: String,
        urlString: String,
        requestBlock: ((URLRequest) -> URLRequest)? = nil,
        progressBlock: ((Float) -> Void)? = nil,
        completeBlock: ((Error?) -> Void)? = nil
    ) -> LWFileDownloadTask {

        let manager = LWFileDownloadManager.shared

        let completeBlockWrapper: ((Error?) -> Void) = { error in
            manager.group.async(queue: manager.serialQueue) {
                completeBlock?(error)
            }
        }

        let task = LWFileDownloadTask(urlString: urlString, fileName: fileName)
        task.updateRequestBlock = requestBlock
        task.updateProgressBlock = progressBlock
        task.completeBlock = completeBlockWrapper

        return task
    }

    // MARK: - Helper Methods

    public var fileDirectoryPath: String {
        if let path = _fileDirectoryPath {
            return path
        }

        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = (documentsDirectory as NSString).appendingPathComponent(directoryName)
        _fileDirectoryPath = path

        LWFileDownloadManager.createDirectory(ifNotExistsAtPath: path)

        return path
    }

    /// Create directory if it doesn't exist
    @objc @discardableResult
    public static func createDirectory(ifNotExistsAtPath path: String) -> Bool {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                LWDLLog("Create directory Success!")
                return true
            } catch {
                LWDLLog("Error! %@", error.localizedDescription)
                return false
            }
        }
        return true
    }

    /// Get document directory path for a given path
    @objc public static func documentDirectoryPath(_ path: String) -> String {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let directoryPath = (documentsDirectory as NSString).appendingPathComponent(path)

        createDirectory(ifNotExistsAtPath: directoryPath)
        return directoryPath
    }

    /// Write data to file path
    @objc @discardableResult
    public static func write(data: Data, toFilePath filePath: String) -> Bool {
        do {
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            LWDLLog("=======file writeToFile: YES")
            return true
        } catch {
            LWDLLog("=======file writeToFile: NO - %@", error.localizedDescription)
            return false
        }
    }

    /// Check if file exists with fileName
    @objc public static func fileExists(withFileName fileName: String) -> Bool {
        let filePath = (LWFileDownloadManager.shared.fileDirectoryPath as NSString).appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: filePath)
    }

    /// Get file path for fileName
    @objc public static func filePath(withFileName fileName: String) -> String {
        return (LWFileDownloadManager.shared.fileDirectoryPath as NSString).appendingPathComponent(fileName)
    }

    /// Remove file at path
    @objc @discardableResult
    public static func removeFile(atPath filePath: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        } catch {
            LWDLLog("Error! %@", error.localizedDescription)
            return false
        }
    }
}
