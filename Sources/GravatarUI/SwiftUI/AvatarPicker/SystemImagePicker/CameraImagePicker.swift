import PhotosUI
import SwiftUI

struct CameraImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (ImagePickerItem) -> Void

    @State private var pickedImage: ImagePickerItem? {
        didSet {
            if let pickedImage {
                onImageSelected(pickedImage)
            }
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        // Forcefully use UIImagePickerController for device camera only
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        // Use custom image cropper
        imagePicker.allowsEditing = false

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraImagePicker

        init(_ parent: CameraImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.pickedImage = .init(id: UUID().uuidString, image: image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
