//
//  VideoProvider.swift
//  testVideo
//
//  Created by Ksenia on 05.04.2021.
//

import Foundation
import AVFoundation

enum VideoProviderState {
    case download
    case downloading(progress: Double)
    case downloaded
}

protocol VideoProviderProtocol {
    func fetchVideo(url: URL)
    func isLocalAvailable() -> Bool
    var onStateChanged: ((VideoProviderState) -> ())? { get set }
}

final class VideoProvider: NSObject, VideoProviderProtocol {
    var onStateChanged: ((VideoProviderState) -> ())?
    
    private let fileName: String
    
    private var state: VideoProviderState = .download
    private var assetDownloadURLSession: URLSession!
    
    private lazy var videoData = Data()
    
    init(fileName: String = "test.mp4") {
        self.fileName = fileName
        
        super.init()
        
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
        self.assetDownloadURLSession = URLSession.init(configuration: backgroundConfiguration,
                                                       delegate: self,
                                                       delegateQueue: OperationQueue.main)
    }
    
    func fetchVideo(url: URL) {
        let task = assetDownloadURLSession.dataTask(with: url)
        self.onStateChanged?(.downloading(progress: 0))
        task.resume()
    }
    
    func isLocalAvailable() -> Bool {
        guard let _ = fetchLocal(withName: "test.mp4") else { return false }
        return true
    }
    
    private func clean(_ fileURL: URL?) {
        guard let fileURL = fileURL else { return }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error {
                print("Failed to delete file with error: \(error)")
            }
        }
    }
    
    private func fetchLocal(withName name: String) -> Data? {
        
        guard let local = localURL() else { return nil }
        do {
            let data = try Data.init(contentsOf: local)
            return data
        }  catch let error {
            print("Failed to find file with error: \(error)")
            return nil
        }
    }
    
    private func localURL() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = paths.first
        return documents?.appendingPathComponent("test.mp4")
    }
    
    private func saveMediaDataToLocalFile() {
        guard let fileURL = localURL() else { return }
        
        clean(fileURL)
        
        do {
            try videoData.write(to: fileURL)
            self.onStateChanged?(.downloaded)
        } catch let error {
            print("Failed to save file with error: \(error)")
        }
    }
}

extension VideoProvider: URLSessionDataDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.videoData.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Failed to download media file with error: \(error)")
        } else {
            saveMediaDataToLocalFile()
        }
    }
}
