//
//  File.swift
//
//
//  Created by Pinar Olguc on 29.01.2024.
//

import Foundation
import UIKit
import Gravatar

class DemoUIImageViewExtensionViewController: UIViewController {
    static let imageViewSize: CGSize = .init(width: 300, height: 300)
    
    private lazy var emailInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "pinarolguc@yahoo.com"
        textField.placeholder = "Enter Gravatar email"
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private lazy var activityIndictorSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Show activity indicator")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelOngoingSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Cancel ongoing download upon starting a new one")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var removeCurrentImageSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Remove current image while loading")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var showPlaceholderSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Show placeholder")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var igonreCacheSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Ignore Cache")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var animatedFadeInSwitch: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Enable Fade In Animation")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var fetchAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Fetch Avatar", for: .normal)
        button.addTarget(self, action: #selector(fetchAvatarButtonHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: Self.imageViewSize.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Self.imageViewSize.width).isActive = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailInputField, activityIndictorSwitchWithLabel, cancelOngoingSwitchWithLabel, removeCurrentImageSwitchWithLabel, showPlaceholderSwitchWithLabel, igonreCacheSwitchWithLabel, animatedFadeInSwitch, fetchAvatarButton, avatarImageView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let imageRetriever = GravatarImageRetriever()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        view.backgroundColor = .white
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            view.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10),
            view.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -10)
        ])
    }
    
    @objc private func fetchAvatarButtonHandler() {
        let options = setupOptions()
        if cancelOngoingSwitchWithLabel.switchView.isOn {
            avatarImageView.gravatar.cancelImageDownload()
        }
        let placeholderImage: UIImage? = showPlaceholderSwitchWithLabel.switchView.isOn ? UIImage(named: "placeholder") : nil
        avatarImageView.gravatar.setImage(email: emailInputField.text ?? "",
                                          placeholder: placeholderImage,
                                          options: options) { result in
            switch result {
            case .success:
                print("success!")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupOptions() -> [GravatarImageSettingOption] {
        var options: [GravatarImageSettingOption] = []
        
        if animatedFadeInSwitch.switchView.isOn {
            options.append(.transition(.fade(0.3)))
        }
        else {
            options.append(.transition(.none))
        }
        
        if removeCurrentImageSwitchWithLabel.switchView.isOn {
            options.append(.removeCurrentImageWhileLoading)
        }
        
        if igonreCacheSwitchWithLabel.switchView.isOn {
            options.append(.forceRefresh)
        }
        
        if activityIndictorSwitchWithLabel.switchView.isOn {
            avatarImageView.gravatar.activityIndicatorType = .activity
        }
        else {
            avatarImageView.gravatar.activityIndicatorType = .none
        }
        
        return options
    }
}
