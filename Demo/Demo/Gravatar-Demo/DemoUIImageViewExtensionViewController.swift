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

    private lazy var imageDefaultButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Default Image: (Backend driven)", for: .normal)
        button.addTarget(self, action: #selector(selectImageDefault), for: .touchUpInside)
        return button
    }()

    private lazy var cancelOngoingButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelOngoingButtonHandler), for: .touchUpInside)
        return button
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
        let stack = UIStackView(arrangedSubviews: [
            emailInputField,
            activityIndictorSwitchWithLabel,
            removeCurrentImageSwitchWithLabel,
            showPlaceholderSwitchWithLabel,
            igonreCacheSwitchWithLabel,
            animatedFadeInSwitch,
            imageDefaultButton,
            fetchAvatarButton,
            cancelOngoingButton,
            avatarImageView
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let imageRetriever = ImageService()
    
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

    private var preferredDefaultImage: DefaultImageOption? = nil

    @objc private func selectImageDefault() {
        let controller = UIAlertController(title: "Default Image", message: nil, preferredStyle: .actionSheet)

        DefaultImageOption.allCases.forEach { option in
            controller.addAction(UIAlertAction(title: "\(option)", style: .default) { [weak self] action in
                self?.preferredDefaultImage = option
                self?.imageDefaultButton.setTitle("Default Image: \(option)", for: .normal)
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(controller, animated: true)
    }

    @objc private func fetchAvatarButtonHandler() {
        let options = setupOptions()
        let placeholderImage: UIImage? = showPlaceholderSwitchWithLabel.isOn ? UIImage(named: "placeholder") : nil
        avatarImageView.gravatar.setImage(email: emailInputField.text ?? "",
                                          placeholder: placeholderImage,
                                          defaultImageOption: preferredDefaultImage,
                                          options: options) { result in
            switch result {
            case .success(let result):
                print("success!")
                print("result url: \(result.sourceURL)")
                print("retrived Image point size: \(result.image.size)")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func cancelOngoingButtonHandler() {
        avatarImageView.gravatar.cancelImageDownload()
    }
    
    private func setupOptions() -> [ImageSettingOption] {
        var options: [ImageSettingOption] = []
        
        if animatedFadeInSwitch.isOn {
            options.append(.transition(.fade(0.3)))
        }
        else {
            options.append(.transition(.none))
        }
        
        if removeCurrentImageSwitchWithLabel.isOn {
            options.append(.removeCurrentImageWhileLoading)
        }
        
        if igonreCacheSwitchWithLabel.isOn {
            options.append(.forceRefresh)
        }
        
        if activityIndictorSwitchWithLabel.isOn {
            avatarImageView.gravatar.activityIndicatorType = .activity
        }
        else {
            avatarImageView.gravatar.activityIndicatorType = .none
        }

        return options
    }
}
