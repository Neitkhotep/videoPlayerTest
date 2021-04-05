//
//  VideoPlayerViewController.swift
//  testVideo
//
//  Created by Ksenia on 05.04.2021.
//

import Foundation
import AVKit
import UIKit

protocol VideoPlayerInput {
    var fileURL: URL? { get }
}

final class VideoPlayerViewController: UIViewController {
    private let playerLayer = AVPlayerLayer()
    private let presenter: VideoPlayerInput
    private var player: AVPlayer?
    
    init(_ presenter: VideoPlayerInput) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
        
      
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setup() {
        view.layer.addSublayer(playerLayer)
        playerLayer.frame = CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 200)
        
        guard let contentUrl = presenter.fileURL else { return }
        player = AVPlayer(url: contentUrl)
        
        playerLayer.player = player
        player?.play()
    }
    
    private func setupViews() {
        
    }
}
