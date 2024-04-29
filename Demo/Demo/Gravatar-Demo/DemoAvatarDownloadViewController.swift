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

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Email", "Hash"])
        control.addTarget(self, action: #selector(chooseFetchType(_:)), for: .valueChanged)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private lazy var emailInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Gravatar email"
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private let hashInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter a valid Gravatar hash"
        textField.keyboardType = .asciiCapable
        textField.autocapitalizationType = .none
        textField.textAlignment = .center
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

    private lazy var forceDefaultAvatarSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Force default avatar")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var imageDefaultButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Default Avatar Option: (Backend driven)", for: .normal)
        button.addTarget(self, action: #selector(selectImageDefault), for: .touchUpInside)
        return button
    }()

    private lazy var customAvatarDefaultInputField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Set custom avatar default URL"
        textField.keyboardType = .URL
        textField.delegate = self
        return textField
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
            segmentedControl,
            emailInputField,
            preferredAvatarLengthInputField,
            gravatarRatingInputField,
            igonreCacheSwitchWithLabel,
            forceDefaultAvatarSwitchWithLabel,
            imageDefaultButton,
            customAvatarDefaultInputField,
            fetchAvatarButton,
            avatarImageView
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

    private let imageRetriever = Gravatar.AvatarService()

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
    
    private var preferredRating: Rating? {
        if let ratingStr = gravatarRatingInputField.text,
           !ratingStr.isEmpty
        {
            return Rating(rawValue: ratingStr)
        }
        return nil
    }

    private var preferredDefaultAvatar: DefaultAvatarOption? = nil

    @objc private func selectImageDefault() {
        let controller = UIAlertController(title: "Default Avatar Option", message: nil, preferredStyle: .actionSheet)

        DefaultAvatarOption.allCases.forEach { option in
            controller.addAction(UIAlertAction(title: "\(option)", style: .default) { [weak self] action in
                self?.preferredDefaultAvatar = option
                self?.imageDefaultButton.setTitle("Default Avatar Option: \(option)", for: .normal)
                self?.customAvatarDefaultInputField.text = ""
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
            forceDefaultAvatar: forceDefaultAvatarSwitchWithLabel.isOn,
            defaultAvatarOption: preferredDefaultAvatar
        )

        avatarImageView.image = nil // Setting to nil to make the effect of `forceRefresh more visible
        
        let identifier: AvatarIdentifier
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let email = emailInputField.text, email.isEmpty == false else { return }
            identifier = .email(email)
        } else {
            guard let hash = hashInputField.text, hash.isEmpty == false else { return }
            identifier = .hashID(hash)
        }
        
        Task {
            do {
                let result = try await imageRetriever.fetch(with: identifier, options: options)
                avatarImageView.image = result.image
            } catch {
                print(error)
            }
        }
    }
    
    private enum FetchType: Int {
        case email = 0
        case hash
    }
    
    @objc private func chooseFetchType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setFetchType(.email)
        case 1:
            setFetchType(.hash)
        default:
            setFetchType(.email)
        }
    }
    
    private func setFetchType(_ type: FetchType) {
        switch type {
        case .email:
            if let index = stackView.arrangedSubviews.firstIndex(of: hashInputField) {
                stackView.removeArrangedSubview(hashInputField)
                hashInputField.removeFromSuperview()
                stackView.insertArrangedSubview(emailInputField, at: index)
            }
        case .hash:
            if let index = stackView.arrangedSubviews.firstIndex(of: emailInputField) {
                stackView.removeArrangedSubview(emailInputField)
                emailInputField.removeFromSuperview()
                stackView.insertArrangedSubview(hashInputField, at: index)
            }
        }
    }
}

extension DemoAvatarDownloadViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let url = URL(string: textField.text ?? "") else {
            textField.text = nil
            return
        }

        imageDefaultButton.setTitle("Default Avatar Option: Custom URL", for: .normal)
        preferredDefaultAvatar = .customURL(url)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
