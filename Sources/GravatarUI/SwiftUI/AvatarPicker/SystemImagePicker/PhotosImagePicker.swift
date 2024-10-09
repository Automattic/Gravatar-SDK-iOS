import PhotosUI
import SwiftUI

struct PhotosImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (ImagePickerItem) -> Void
    let onCancel: () -> Void

    @State private var pickedImage: ImagePickerItem? {
        didSet {
            if let pickedImage {
                onImageSelected(pickedImage)
            }
        }
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotosImagePicker

        init(_ parent: PhotosImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard
                let result = results.first,
                result.itemProvider.canLoadObject(ofClass: UIImage.self)
            else {
                parent.onCancel()
                return
            }

            Task {
                let image = await result.itemProvider.loadUIImage()
                let imageItem = ImagePickerItem(id: UUID().uuidString, image: image)
                parent.pickedImage = imageItem
            }
        }
    }
}

extension NSItemProvider {
    fileprivate func loadUIImage() async -> UIImage {
        await withCheckedContinuation { continuation in
            loadObject(ofClass: UIImage.self) { itemReading, _ in
                guard let image = itemReading as? UIImage else {
                    return
                }

                continuation.resume(returning: image)
            }
        }
    }
}
