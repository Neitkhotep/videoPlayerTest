//
//  GetVideoScreenViewController.swift
//  testVideo
//
//  Created by Ksenia on 05.04.2021.
//

import Foundation
import UIKit

protocol GetVideoScreenViewOutput: class {
    var onButtonNameChanged: (String) -> () { get }
}

protocol GetVideoScreenViewInput {
    func tryFetch()
    var onButtonTapped: () -> () { get set }
}

final class GetVideoScreenViewController: UIViewController, GetVideoScreenViewOutput {
    private enum Attributes {
        
        static var buttonAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 25)
        ]
    }
    
    private let presenter: GetVideoScreenViewInput
    
    lazy var onButtonNameChanged: (String) -> () = { [weak self] title in
        self?.button.setAttributedTitle(NSAttributedString(string: title,
                                                     attributes: Attributes.buttonAttributes), for: .normal)
    }
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system,
                              primaryAction: UIAction(handler: { [weak self] action in
                                self?.presenter.onButtonTapped()
                              }))
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        return button
    }()
    
    init(_ presenter: GetVideoScreenViewInput) {
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

        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.tryFetch()
    }
    
    private func setupViews() {
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }
}
