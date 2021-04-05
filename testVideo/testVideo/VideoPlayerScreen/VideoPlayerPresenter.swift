//
//  VideoPlayerPresenter.swift
//  testVideo
//
//  Created by Ksenia on 05.04.2021.
//

import Foundation

final class VideoPlayerPresenter: VideoPlayerInput {
    var fileURL: URL? {
        return localURL()
    }
    
    private func localURL() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = paths.first
        return documents?.appendingPathComponent("test.mp4")
    }
}
