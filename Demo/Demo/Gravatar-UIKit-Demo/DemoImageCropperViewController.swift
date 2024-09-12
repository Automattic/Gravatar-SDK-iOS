#if DEBUG

import UIKit
@testable import GravatarUI
import PhotosUI

class DemoImageCropperViewController: UIViewController {
    
    lazy var selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Select Image", for: .normal)
        button.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        return button
    }()
    
    lazy var croppedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.backgroundColor = UIColor.secondarySystemBackground
        return imageView
    }()
    
    lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.label
        return label
    }()
    
    lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [selectImageButton, croppedImageView, sizeLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillProportionally
        stack.alignment = .center
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func selectImage() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images // Only show images in picker
        configuration.selectionLimit = 1 // Limit selection to one image
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension DemoImageCropperViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        // Ensure the user selected an image and that it can be loaded as a UIImage
        guard let result = results.first else { return }
        
        // Load the selected image
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.showCropper(with: image)
                    }
                }
            }
        }
    }
    
    // Show the cropper with the selected image
    func showCropper(with image: UIImage) {
        let cropperVC = ImageCropperViewController.wrappedInNavigationViewController(image: image) { image, _ in
            self.croppedImageView.image = image
            self.sizeLabel.text = "\(image.size.width) x \(image.size.height)"
            self.dismiss(animated: true)
        } onCancel: {
            self.dismiss(animated: true)
        }

        present(cropperVC, animated: true, completion: nil)
    }
}

#endif
