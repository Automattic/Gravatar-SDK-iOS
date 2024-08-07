import PhotosUI
import SwiftUI

struct SystemImagePickerView<Label>: View where Label: View {
    @ViewBuilder var label: () -> Label

    let onImageSelected: (UIImage) -> Void

    var body: some View {
        // NOTE: Here we can choose between legacy and new picker.
        // So far, the new SwiftUI PhotosPicker only supports Photos library, no camera, and no cropping, so we are only using legacy for now.
        // The interface (using a Label property as the element to open the picker) is the same as in the new SwiftUI picker,
        // which will make it easy to change it later on.
        LegacyImagePicker(label: label, onImageSelected: onImageSelected)
    }
}

/// UIImagePickerController SwiftUI Representable wrapper.
struct LegacyImagePicker<Label>: View where Label: View {
    @State var isPresented = false
    @ViewBuilder var label: () -> Label
    let onImageSelected: (UIImage) -> Void

    var body: some View {
        VStack {
            Button(action: {
                isPresented.toggle()
            }, label: {
                label()
            })
        }
        .sheet(isPresented: $isPresented, content: {
            LegacyImagePickerRepresentable { image in
                onImageSelected(image)
            }.ignoresSafeArea()
        })
    }
}

struct LegacyImagePickerRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode

    let onImageSelected: (UIImage) -> Void

    @State private var selectedUIImage: UIImage? {
        didSet {
            if let selectedUIImage {
                onImageSelected(selectedUIImage)
            }
        }
    }

    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeUIViewController(context: UIViewControllerRepresentableContext<LegacyImagePickerRepresentable>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<LegacyImagePickerRepresentable>
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: LegacyImagePickerRepresentable

        init(_ parent: LegacyImagePickerRepresentable) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                parent.selectedUIImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
