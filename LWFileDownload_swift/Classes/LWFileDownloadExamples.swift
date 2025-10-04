//
// LWFileDownloadExamples.swift
// Usage examples for LWFileDownload Swift version
//
// Created 2025
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/*
 MARK: - Basic Usage Examples

 This file contains example code demonstrating how to use the LWFileDownload library
 in Swift and SwiftUI applications.
 */

// MARK: - Example 1: Simple File Download

class SimpleDownloadExample {

    func downloadFile() {
        let fileName = "example.pdf"
        let urlString = "https://example.com/files/example.pdf"

        LWFileDownloadManager.downloadFile(
            withFileName: fileName,
            urlString: urlString,
            progressBlock: { progress, task in
                print("Download progress: \(Int(progress * 100))%")
            },
            completeBlock: { error, task in
                if let error = error as NSError? {
                    if error.code == LWFileDownloadManager.alreadyExistCode {
                        print("File already exists!")
                    } else {
                        print("Download error: \(error.localizedDescription)")
                    }
                } else {
                    print("Download completed successfully!")
                    let filePath = LWFileDownloadManager.filePath(withFileName: fileName)
                    print("File saved to: \(filePath)")
                }
            }
        )
    }
}

// MARK: - Example 2: Download with Custom Request Headers

class CustomRequestExample {

    func downloadWithCustomHeaders() {
        let fileName = "protected.pdf"
        let urlString = "https://example.com/protected/file.pdf"

        LWFileDownloadManager.downloadFile(
            withFileName: fileName,
            urlString: urlString,
            requestBlock: { request, task in
                var modifiedRequest = request
                modifiedRequest.setValue("Bearer YOUR_TOKEN", forHTTPHeaderField: "Authorization")
                modifiedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                return modifiedRequest
            },
            progressBlock: { progress, task in
                print("Progress: \(progress)")
            },
            completeBlock: { error, task in
                if error == nil {
                    print("Download complete!")
                }
            }
        )
    }
}

// MARK: - Example 3: Check File Existence

class FileExistenceExample {

    func checkAndDownload() {
        let fileName = "data.json"

        if LWFileDownloadManager.fileExists(withFileName: fileName) {
            let filePath = LWFileDownloadManager.filePath(withFileName: fileName)
            print("File exists at: \(filePath)")
            // Use the file
        } else {
            print("File doesn't exist, starting download...")
            // Download the file
        }
    }
}

// MARK: - Example 4: Helper Methods

class HelperMethodsExample {

    func useHelperMethods() {
        // Create custom directory
        let customPath = LWFileDownloadManager.documentDirectoryPath("MyDownloads")
        print("Custom directory: \(customPath)")

        // Write data to file
        let data = "Hello, World!".data(using: .utf8)!
        let filePath = LWFileDownloadManager.filePath(withFileName: "test.txt")
        LWFileDownloadManager.write(data: data, toFilePath: filePath)

        // Remove file
        LWFileDownloadManager.removeFile(atPath: filePath)
    }
}

// MARK: - Example 5: SwiftUI Integration

#if canImport(SwiftUI)
@available(iOS 13.0, *)
struct SingleDownloadExampleView: View {

    @StateObject private var viewModel = LWFileDownloadViewModel(
        fileName: "example.pdf",
        urlString: "https://example.com/files/example.pdf"
    )

    var body: some View {
        VStack {
            Text("File Download Example")
                .font(.title)

            LWFileDownloadProgressView(viewModel: viewModel)
                .padding()
        }
    }
}

@available(iOS 13.0, *)
struct MultipleDownloadsExampleView: View {

    @StateObject private var viewModel = LWMultipleDownloadsViewModel()

    var body: some View {
        VStack {
            Text("Multiple Downloads")
                .font(.title)

            Button("Add Sample Downloads") {
                _ = viewModel.addDownload(
                    fileName: "file1.pdf",
                    urlString: "https://example.com/file1.pdf"
                )
                _ = viewModel.addDownload(
                    fileName: "file2.pdf",
                    urlString: "https://example.com/file2.pdf"
                )
                _ = viewModel.addDownload(
                    fileName: "file3.pdf",
                    urlString: "https://example.com/file3.pdf"
                )
            }
            .padding()

            LWMultipleDownloadsView(viewModel: viewModel)
        }
    }
}
#endif

// MARK: - Example 6: Multiple Sequential Downloads

class MultipleDownloadsExample {

    func downloadMultipleFiles() {
        let files = [
            ("file1.pdf", "https://example.com/file1.pdf"),
            ("file2.pdf", "https://example.com/file2.pdf"),
            ("file3.pdf", "https://example.com/file3.pdf")
        ]

        for (fileName, urlString) in files {
            LWFileDownloadManager.downloadFile(
                withFileName: fileName,
                urlString: urlString,
                progressBlock: { progress, task in
                    print("\(fileName): \(Int(progress * 100))%")
                },
                completeBlock: { error, task in
                    if error == nil {
                        print("\(fileName) downloaded successfully")
                    }
                }
            )
        }
    }
}

// MARK: - Example 7: UIKit Integration with Combine

#if canImport(UIKit) && canImport(Combine)
import UIKit
import Combine

@available(iOS 13.0, *)
class DownloadViewController: UIViewController {

    private var viewModel: LWFileDownloadViewModel?
    private var cancellables = Set<AnyCancellable>()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        viewModel = LWFileDownloadViewModel(
            fileName: "example.pdf",
            urlString: "https://example.com/example.pdf"
        )

        // Observe progress changes
        viewModel?.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressView.progress = progress
                self?.statusLabel.text = "Progress: \(Int(progress * 100))%"
            }
            .store(in: &cancellables)

        // Observe completion
        viewModel?.$isComplete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isComplete in
                if isComplete {
                    self?.statusLabel.text = "Download Complete!"
                }
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .white

        progressView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center

        view.addSubview(progressView)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 200),

            statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    func startDownload() {
        viewModel?.startDownload()
    }
}
#endif
