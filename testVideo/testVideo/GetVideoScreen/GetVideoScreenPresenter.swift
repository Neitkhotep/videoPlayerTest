//
//  GetVideoScreenPresenter.swift
//  testVideo
//
//  Created by Ksenia on 05.04.2021.
//

import Foundation

final class GetVideoScreenPresenter: GetVideoScreenViewOutput {
    enum State {
        case play
        case download
        case progress(persents: Double)
    }
    
    lazy var onButtonTapped: () -> () = { [weak self] in
        self?.fetch()
    }
    
    private let videoURL: URL
    
    private var state: State = .download {
        didSet {
            let buttonName: String
            
            switch state {
            case .play: buttonName = "Play"
            case .download: buttonName = "Download"
            case .progress(let progress): buttonName = "Progress: \(progress)"
            }
            
            view?.onButtonNameChanged(buttonName)
        }
    }
    
    private var videoProvider: VideoProviderProtocol
    private let router: Router
    weak var view: GetVideoScreenViewInput?
    
    init(router: Router, videoURL: URL, videoProvider: VideoProviderProtocol = VideoProvider()) {
        self.videoProvider = videoProvider
        self.videoURL = videoURL
        self.router = router
        self.videoProvider.onStateChanged = { [weak self] state in
           
            switch state {
            case .downloaded: self?.state = .play
            case .download: self?.state = .download
            case .downloading(let progress):  self?.state = .progress(persents: progress)
            }
        }
    }
    
    func tryFetch() {
        state = videoProvider.isLocalAvailable() ? .play : .download
    }
    
    func fetch() {
        videoProvider.fetchVideo(url: videoURL)
    }
    
    private func handleTap() {
        switch state {
        case .play:
            router.showPlayerScreen()
        case .download:
            fetch()
        case .progress:
            break
        }
    }
}
