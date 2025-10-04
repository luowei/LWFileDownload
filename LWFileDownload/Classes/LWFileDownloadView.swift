//
// Created by Luo Wei on 2017/11/25.
// Copyright (c) 2017 wodedata. All rights reserved.
// Swift/SwiftUI version created 2025
//

#if canImport(SwiftUI)
import SwiftUI

/// SwiftUI view for displaying file download progress
@available(iOS 13.0, *)
public struct LWFileDownloadProgressView: View {

    @ObservedObject var viewModel: LWFileDownloadViewModel

    public init(viewModel: LWFileDownloadViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(viewModel.fileName)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                if viewModel.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if viewModel.downloadError != nil {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                }
            }

            if viewModel.isDownloading {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle())

                Text("\(Int(viewModel.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let error = viewModel.downloadError {
                Text("Error: \(error.localizedDescription)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .lineLimit(2)
            }

            HStack {
                if !viewModel.isDownloading && !viewModel.isComplete {
                    Button(action: {
                        viewModel.startDownload()
                    }) {
                        Label("Download", systemImage: "arrow.down.circle")
                    }
                    .buttonStyle(.bordered)
                }

                if viewModel.isDownloading {
                    Button(action: {
                        viewModel.cancelDownload()
                    }) {
                        Label("Cancel", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

/// SwiftUI view for displaying multiple file downloads
@available(iOS 13.0, *)
public struct LWMultipleDownloadsView: View {

    @ObservedObject var viewModel: LWMultipleDownloadsViewModel

    public init(viewModel: LWMultipleDownloadsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Overall progress
            if !viewModel.downloads.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("Overall Progress")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(viewModel.overallProgress * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    ProgressView(value: viewModel.overallProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            // Control buttons
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.startAll()
                }) {
                    Label("Start All", systemImage: "play.fill")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.downloads.isEmpty)

                Button(action: {
                    viewModel.cancelAll()
                }) {
                    Label("Cancel All", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(viewModel.downloads.isEmpty)

                Button(action: {
                    viewModel.removeCompleted()
                }) {
                    Label("Clear Completed", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                .disabled(viewModel.downloads.isEmpty)
            }

            // Individual downloads
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.downloads.values.enumerated()), id: \.offset) { _, download in
                        LWFileDownloadProgressView(viewModel: download)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview Providers

@available(iOS 13.0, *)
struct LWFileDownloadProgressView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LWFileDownloadViewModel(
            fileName: "example.pdf",
            urlString: "https://example.com/file.pdf"
        )
        return LWFileDownloadProgressView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}

@available(iOS 13.0, *)
struct LWMultipleDownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LWMultipleDownloadsViewModel()
        _ = viewModel.addDownload(fileName: "file1.pdf", urlString: "https://example.com/file1.pdf")
        _ = viewModel.addDownload(fileName: "file2.pdf", urlString: "https://example.com/file2.pdf")

        return LWMultipleDownloadsView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
#endif
