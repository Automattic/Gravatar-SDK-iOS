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
        ImagePicker(label: label, onImageSelected: onImageSelected)
    }
}

private struct ImagePicker<Label>: View where Label: View {
    enum SourceType: CaseIterable, Identifiable {
        case photoLibrary
        case camera

        var id: Int {
            self.hashValue
        }
    }

    @State var isPresented = false
    @State private var sourceType: SourceType?

    @ViewBuilder var label: () -> Label
    let onImageSelected: (UIImage) -> Void

    var body: some View {
        VStack {
            Menu {
                ForEach(SourceType.allCases) { source in
                    Button {
                        sourceType = source
                        isPresented = true
                    } label: {
                        SwiftUI.Label(source.localizedTitle, systemImage: source.iconName)
                    }
                }
            } label: {
                label()
            }
        }
        .sheet(item: $sourceType, content: { source in
            // This allows to present different kind of pickers for different sources.
            switch source {
            case .camera:
                ZStack {
                    Color.black.ignoresSafeArea(edges: .all)
                    LegacyImagePickerRepresentable(sourceType: source.map()) { image in
                        onImageSelected(image)
                    }
                }
            case .photoLibrary:
                LegacyImagePickerRepresentable(sourceType: source.map()) { image in
                    onImageSelected(image)
                }.ignoresSafeArea()
            }
        })
    }
}

extension ImagePicker.SourceType {
    var iconName: String {
        switch self {
        case .camera:
            "camera"
        case .photoLibrary:
            "photo.on.rectangle.angled"
        }
    }

    var localizedTitle: String {
        switch self {
        case .photoLibrary:
            "Chose a Photo"
        case .camera:
            "Take Photo"
        }
    }

    func map() -> UIImagePickerController.SourceType {
        switch self {
        case .photoLibrary: .photoLibrary
        case .camera: .camera
        }
    }
}

struct LegacyImagePickerRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode

    var sourceType: UIImagePickerController.SourceType
    let onImageSelected: (UIImage) -> Void

    @State private var selectedUIImage: UIImage? {
        didSet {
            if let selectedUIImage {
                onImageSelected(selectedUIImage)
            }
        }
    }

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
