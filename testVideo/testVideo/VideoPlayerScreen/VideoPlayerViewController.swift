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
    func stop()
    func play(start: CMTime, pause: CMTime, duration: CMTime)
}

final class VideoPlayerViewController: UIViewController, VideoPlayerInputOutput {

    private let playerLayer = AVPlayerLayer()
    private lazy var pauseLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.4).cgColor
        return layer
    }()
    
    private let presenter: VideoPlayerInput
    private var player: AVPlayer?
    private var durationTimer: Timer?
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
    
    func stop() {
        durationTimer?.invalidate()
        pauseTimer?.invalidate()
        player?.pause()
    }
    
    func play(start: CMTime, pause: CMTime, duration: CMTime) {
        player?.seek(to: start)
       
        pauseCount = Int(pause.seconds)
        durationCount = Int(duration.seconds)
        
        pauseTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(updatePause),
                                          userInfo: nil, repeats: true)
    }
  
    private func resumePlay() {
        pauseLayer.removeFromSuperlayer()
        durationTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(updateDuration),
                                             userInfo: nil, repeats: true)
        player?.play()
    }
    
    func played() {
        durationTimer?.invalidate()
        view.layer.addSublayer(pauseLayer)
        player?.pause()
        presenter.playNext()
    }
    
    @objc func updateDuration() {
        if(durationCount > 0) {
            durationCount = durationCount - 1
            timerLabel.text = "Play: -\(durationCount)"
        } else {
            timerLabel.text = "Play: 0"
            durationTimer?.invalidate()
            played()
        }
    }
    
    @objc func updatePause() {
        if(pauseCount > 0) {
            pauseCount = pauseCount - 1
            pauseLabel.text = "Pause: -\(pauseCount)"
        } else {
            pauseLabel.text = "Pause: 0"
            pauseTimer?.invalidate()
            resumePlay()
        }
    }
    
    private func setup() {
        view.layer.addSublayer(playerLayer)
        playerLayer.frame = CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 200)
        
        guard let contentUrl = presenter.fileURL else { return }
        player = AVPlayer(url: contentUrl)
        
        playerLayer.player = player
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [previousButton, nextButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = 50.0
        
        view.addSubview(timerLabel)
        view.addSubview(pauseLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pauseLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            pauseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: pauseLabel.topAnchor, constant: 40)
            ])
    }
}
