import SwiftUI

struct ImageCropper: UIViewControllerRepresentable, ImageEditorView {
    let inputImage: UIImage
    var editingDidFinish: (UIImage) -> Void
    var onCancel: () -> Void

    typealias UIViewControllerType = UINavigationController

    init(inputImage: UIImage, editingDidFinish: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self.inputImage = inputImage
        self.editingDidFinish = editingDidFinish
        self.onCancel = onCancel
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImageCropper>) -> UINavigationController {
        ImageCropperViewController.wrappedInNavigationViewController(
            image: inputImage,
            onCompletion: editingDidFinish,
            onCancel: onCancel
        )
    }

    func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: UIViewControllerRepresentableContext<ImageCropper>
    ) {}
}
