//
//  VideoPlayerPresenter.swift
//  testVideo
//
//  Created by Ksenia on 05.04.2021.
//

import Foundation
import AVKit
final class VideoPlayerPresenter: VideoPlayerInput {
    struct Module {
        let start: CMTime
        let pause: CMTime
        let duration: CMTime
    }
    
    weak var view: VideoPlayerInputOutput?
    
    private var modules: [Module] = [
        Module(start: CMTime(seconds: 0, preferredTimescale: 600),
               pause: CMTime(seconds: 5, preferredTimescale: 600),
               duration: CMTime(seconds: 10, preferredTimescale: 600)),
        Module(start: CMTime(seconds: 10, preferredTimescale: 600),
               pause: CMTime(seconds: 5, preferredTimescale: 600),
               duration: CMTime(seconds: 10, preferredTimescale: 600)),
        Module(start: CMTime(seconds: 0, preferredTimescale: 600),
               pause: CMTime(seconds: 5, preferredTimescale: 600),
               duration: CMTime(seconds: 5, preferredTimescale: 600)),
        Module(start: CMTime(seconds: 25, preferredTimescale: 600),
               pause: CMTime(seconds: 5, preferredTimescale: 600),
               duration: CMTime(seconds: 5, preferredTimescale: 600))
    ]
    
    private var currentModuleIndex: Int = 0
    
    var fileURL: URL? {
        return localURL()
    }
    
    func start() {
        playCurrent()
    }
    
    func playPrevious() {
        guard currentModuleIndex > 1 else { return }
        currentModuleIndex = currentModuleIndex - 1
        playCurrent()
    }
    
    func playNext() {
        guard currentModuleIndex < modules.count - 1 else { return }
        currentModuleIndex = currentModuleIndex + 1
        playCurrent()
    }
    
    private func playCurrent() {
        let currentModule = modules[currentModuleIndex]
        view?.play(start: currentModule.start,
                   pause: currentModule.pause,
                   duration: currentModule.duration)
    }
    
    private func localURL() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = paths.first
        return documents?.appendingPathComponent("test.mp4")
    }
}
