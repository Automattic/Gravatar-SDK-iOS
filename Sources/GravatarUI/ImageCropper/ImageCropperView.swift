import SwiftUI

public struct ImageCropperView: UIViewControllerRepresentable {
    let image: UIImage
    var onCompletion: ((UIImage) -> Void)?
    var onCancel: (() -> Void)?

    public init(image: UIImage, onCompletion: ((UIImage) -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self.image = image
        self.onCompletion = onCompletion
        self.onCancel = onCancel
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = ImageCropperViewController(image: image)
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.onCompletion = onCompletion
        viewController.onCancel = onCancel
        return navigationController
    }

    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No need to update the view controller as it handles its own state
    }
}
