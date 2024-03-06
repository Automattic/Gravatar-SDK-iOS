//
//  DemoAvatarDownloadViewController.swift
//  Gravatar-Demo
//
//  Created by Pinar Olguc on 24.01.2024.
//

import UIKit
import Gravatar

class DemoAvatarDownloadViewController: UIViewController {
    static let imageViewSize: CGFloat = 300

    private lazy var emailInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Gravatar email"
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private lazy var preferredAvatarLengthInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Preferred avatar length (optional)"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var gravatarRatingInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Gravatar rating (optional). [g|pg|r|x]"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var igonreCacheSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Ignore Cache")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var forceDefaultImageSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Force default image")
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
        imageView.heightAnchor.constraint(equalToConstant: Self.imageViewSize).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Self.imageViewSize).isActive = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            emailInputField,
            preferredAvatarLengthInputField,
            gravatarRatingInputField,
            igonreCacheSwitchWithLabel,
            forceDefaultImageSwitchWithLabel,
            imageDefaultButton,
            fetchAvatarButton,
            avatarImageView
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

//    private let imageRetriever = GravatarImageRetriever()
    private let imageRetriever = Gravatar.ImageService()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        view.backgroundColor = .white
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            view.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            view.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ])
    }
    
    private var preferredSize: CGFloat {
        if let preferredLenghtStr = preferredAvatarLengthInputField.text,
           !preferredLenghtStr.isEmpty,
           let preferredSize = Float(preferredLenghtStr)
        {
            return CGFloat(preferredSize)
        }
        return Self.imageViewSize
    }
    
    private var preferredRating: ImageRating? {
        if let ratingStr = gravatarRatingInputField.text,
           !ratingStr.isEmpty
        {
            return ImageRating(rawValue: ratingStr)
        }
        return nil
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
        
        let options: ImageDownloadOptions = .init(
            preferredSize: .points(preferredSize),
            rating: preferredRating,
            forceRefresh: igonreCacheSwitchWithLabel.isOn,
            forceDefaultImage: forceDefaultImageSwitchWithLabel.isOn,
            defaultImage: preferredDefaultImage
        )

        avatarImageView.image = nil // Setting to nil to make the effect of `forceRefresh more visible
        
        imageRetriever.fetchImage(with: emailInputField.text ?? "",
                                      options: options) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    self?.avatarImageView.image = value.image
                    print("Source URL: \(value.sourceURL)")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

