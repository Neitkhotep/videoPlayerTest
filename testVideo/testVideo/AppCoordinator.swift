//
//  AppCoordinator.swift
//  testVideo
//
//  Created by Ksenia on 05.04.2021.
//

import Foundation
import UIKit

protocol Router {
    func showPlayerScreen()
}

final class AppCoordinator: Router {
    // MARK: Private Properties
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    init(window: UIWindow, navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.window = window
        window.rootViewController = navigationController
    }
    
    func start() {
        showInitialScreen()
    }
    
    private func showInitialScreen() {
        if let url = URL(string:"https://m4pmedia.com/t7/video11.mp4") {
            let presenter = GetVideoScreenPresenter(router: self, videoURL: url)
            let vc = GetVideoScreenViewController(presenter)
            presenter.view = vc
            navigationController.setViewControllers([vc], animated: false)
        }
    }
    
    func showPlayerScreen() {
        
    }
}
