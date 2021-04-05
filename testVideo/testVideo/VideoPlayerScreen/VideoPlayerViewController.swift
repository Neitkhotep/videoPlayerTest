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
    func start()
    func playPrevious()
    func playNext()
}

protocol VideoPlayerInputOutput: class {
    func timerLabelChanged(_ text: String)
    func play(start: CMTime, pause: CMTime, duration: CMTime)
}

final class VideoPlayerViewController: UIViewController, VideoPlayerInputOutput {

    private let playerLayer = AVPlayerLayer()
    private let presenter: VideoPlayerInput
    private var player: AVPlayer?
    private var timer: Timer?
    private var pauseTimer: Timer?
    private var pauseCount: Int = 0
    private var durationCount: Int = 0
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system,
                              primaryAction: UIAction(handler: { [weak self] action in
                                self?.presenter.playNext()
                              }))
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.setTitle("Next", for: .normal)
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton(type: .system,
                              primaryAction: UIAction(handler: { [weak self] action in
                                self?.presenter.playPrevious()
                              }))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.setTitle("Previous", for: .normal)
        return button
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pauseLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.start()
    }
    
    func timerLabelChanged(_ text: String) {
        timerLabel.text = text
    }
    
    func play(start: CMTime, pause: CMTime, duration: CMTime) {
        player?.seek(to: start)
       
        pauseCount = Int(pause.seconds)
        durationCount = Int(pause.seconds)
        
        pauseTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(updatePause),
                                          userInfo: nil, repeats: true)
    }
  
    private func resumePlay(for duration: Int) {
        timer = Timer(fireAt: Date() + TimeInterval(Int(duration)),
                      interval: 0,  target: self,
                           selector: #selector(played),
                           userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        player?.play()
    }
    
    @objc
    func played() {
        timer?.invalidate()
        player?.pause()
        presenter.playNext()
    }
    
    @objc func updatePause() {
        if(pauseCount > 0) {
            pauseCount = pauseCount - 1
            pauseLabel.text = "Pause: -\(pauseCount)"
        } else {
            pauseLabel.text = "Pause: 0"
            pauseTimer?.invalidate()
            resumePlay(for: durationCount)
        }
    }
    
    private func setup() {
        view.layer.addSublayer(playerLayer)
        playerLayer.frame = CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 200)
        
        guard let contentUrl = presenter.fileURL else { return }
        player = AVPlayer(url: contentUrl)
        
        playerLayer.player = player
       
        player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1, preferredTimescale: 600), queue: DispatchQueue.main, using: { [weak self] time in
            self?.timerLabel.text = "Play: \(Int(time.seconds))"
        })
    }
    
    private func setupViews() {
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(timerLabel)
        view.addSubview(pauseLabel)

        NSLayoutConstraint.activate([
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pauseLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            pauseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }
}
