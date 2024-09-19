import PhotosUI
import SwiftUI

struct SystemImagePickerView<Label, ImageEditor: ImageEditorView>: View where Label: View {
    @ViewBuilder var label: () -> Label
    var customEditor: ImageEditorBlock<ImageEditor>?
    let onImageSelected: (UIImage) -> Void

    var body: some View {
        // NOTE: Here we can choose between legacy and new picker.
        // So far, the new SwiftUI PhotosPicker only supports Photos library, no camera, and no cropping, so we are only using legacy for now.
        // The interface (using a Label property as the element to open the picker) is the same as in the new SwiftUI picker,
        // which will make it easy to change it later on.
        ImagePicker(label: label, onImageSelected: onImageSelected, customEditor: customEditor)
    }
}

private struct ImagePicker<Label, ImageEditor: ImageEditorView>: View where Label: View {
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
    var customEditor: ImageEditorBlock<ImageEditor>?
    @State var imagePickerSelectedItem: ImagePickerItem?

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
            displayImagePicker(for: source)
                .sheet(item: $imagePickerSelectedItem, content: { item in
                    if let customEditor {
                        customEditor(item.image) { editedImage in
                            self.onImageEdited(editedImage)
                        }
                    } else {
                        ImageCropper(inputImage: item.image) { croppedImage in
                            self.onImageEdited(croppedImage)
                        } onCancel: {
                            imagePickerSelectedItem = nil
                        }.ignoresSafeArea()
                    }
                })
        })
    }

    private func onImageEdited(_ image: UIImage) {
        imagePickerSelectedItem = nil
        sourceType = nil
        onImageSelected(image)
    }

    @ViewBuilder
    private func displayImagePicker(for source: SourceType) -> some View {
        switch source {
        case .camera:
            ZStack {
                Color.black.ignoresSafeArea(edges: .all)
                LegacyImagePickerRepresentable(sourceType: source.map()) { item in
                    pickerDidSelectImage(item)
                }
            }
        case .photoLibrary:
            LegacyImagePickerRepresentable(sourceType: source.map()) { item in
                pickerDidSelectImage(item)
            }.ignoresSafeArea()
        }
    }

    private func pickerDidSelectImage(_ item: ImagePickerItem) {
        imagePickerSelectedItem = item
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
            SDKLocalizedString(
                "SystemImagePickerView.Source.PhotoLibrary.title",
                value: "Choose a Photo",
                comment: "An option in a menu that display the user's Photo Library and allow them to choose a photo from it"
            )
        case .camera:
            SDKLocalizedString(
                "SystemImagePickerView.Source.Camera.title",
                value: "Take a Photo",
                comment: "An option in a menu that will display the camera for taking a picture"
            )
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
    let onImageSelected: (ImagePickerItem) -> Void

    @State private var pickedImage: ImagePickerItem? {
        didSet {
            if let pickedImage {
                onImageSelected(pickedImage)
            }
        }
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<LegacyImagePickerRepresentable>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
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
            guard let url = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
            if picker.allowsEditing, let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                parent.pickedImage = .init(image: image, url: url)
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.pickedImage = .init(image: image, url: url)
            }
        }
    }
}

struct ImagePickerItem: Identifiable {
    var id: String {
        url.absoluteString
    }

    let image: UIImage
    let url: URL
}
