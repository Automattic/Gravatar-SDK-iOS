//
//  File.swift
//
//
//  Created by Pinar Olguc on 29.01.2024.
//

import Foundation
import UIKit
import GravatarUI

class DemoUIImageViewExtensionViewController: BaseFormViewController {
    static let imageViewSize: CGSize = .init(width: 300, height: 300)

    let emailField = TextFormField(placeholder: "Enter Gravatar email", keyboardType: .emailAddress)
    let activityIndicatorSwitch = SwitchField(title: "Show activity indicator")
    let removeCurrentImageSwitch = SwitchField(title: "Remove current image while loading")
    let showPlaceholderSwitch = SwitchField(title: "Show placeholder")
    let igonreCacheSwitch = SwitchField(title: "Ignore cache")
    let animatedFadeInSwitch = SwitchField(title: "Enable Fade In Animation")

    lazy var imageDefaultButtonField = ButtonLabelField(
        title: "Default Avatar:",
        subtitle: "Backend driven",
        buttonTitle: "Select"
    ) { [weak self] _ in
        self?.selectImageDefault()
    }

    lazy var cancelOngoingButtonField = ButtonField(title: "Cancel") { [weak self] _ in
        self?.cancelOngoingButtonHandler()
    }

    lazy var fetchAvatarButtonField = ButtonField(title: "Fetch avatar", isActionButton: true) { [weak self] _ in
        self?.fetchAvatarButtonHandler()
    }

    let avatarImageField = ImageFormField(size: imageViewSize)

    override var form: [FormField] {
        [
            emailField,
            activityIndicatorSwitch,
            removeCurrentImageSwitch,
            showPlaceholderSwitch,
            igonreCacheSwitch,
            animatedFadeInSwitch,
            imageDefaultButtonField,
            cancelOngoingButtonField,
            fetchAvatarButtonField,
            avatarImageField
        ]
    }

    private let imageRetriever = ImageDownloadService()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private var preferredDefaultAvatar: DefaultAvatarOption? = nil

    @objc private func selectImageDefault() {
        let controller = UIAlertController(title: "Default Avatar", message: nil, preferredStyle: .actionSheet)

        DefaultAvatarOption.allCases.forEach { option in
            controller.addAction(UIAlertAction(title: "\(option)", style: .default) { [weak self] action in
                self?.preferredDefaultAvatar = option
                self?.imageDefaultButtonField.subtitle = "\(option)"
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(controller, animated: true)
    }
    var task: Task<Void, Never>?

    @objc private func fetchAvatarButtonHandler() {
        let options = setupOptions()
        let placeholderImage: UIImage? = showPlaceholderSwitch.isOn ? UIImage(named: "placeholder") : nil
        task = Task {
            do {
                guard let result = try await avatarImageField.imageView?.gravatar.setImage(
                    avatarID: .email(emailField.text),
                    placeholder: placeholderImage,
                    defaultAvatarOption: preferredDefaultAvatar,
                    options: options
                ) else {
                    return print("Image view not found")
                }
                print("success!")
                print("result url: \(result.sourceURL)")
                print("retrived Image point size: \(result.image.size)")
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func cancelOngoingButtonHandler() {
        task?.cancel()
    }
    
    private func setupOptions() -> [ImageSettingOption] {
        var options: [ImageSettingOption] = []
        
        if animatedFadeInSwitch.isOn {
            options.append(.transition(.fade(0.3)))
        }
        else {
            options.append(.transition(.none))
        }
        
        if removeCurrentImageSwitch.isOn {
            options.append(.removeCurrentImageWhileLoading)
        }
        
        if igonreCacheSwitch.isOn {
            options.append(.forceRefresh)
        }
        
        if activityIndicatorSwitch.isOn {
            avatarImageField.imageView?.gravatar.activityIndicatorType = .activity
        }
        else {
            avatarImageField.imageView?.gravatar.activityIndicatorType = .none
        }

        return options
    }
}
