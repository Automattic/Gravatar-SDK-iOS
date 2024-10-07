import PhotosUI
import SwiftUI

struct SystemImagePickerView<Label, ImageEditor: ImageEditorView>: View where Label: View {
    @ViewBuilder var label: () -> Label
    var customEditor: ImageEditorBlock<ImageEditor>?
    let onImageSelected: (UIImage) -> Void

    var body: some View {
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
                CameraImagePicker { item in
                    pickerDidSelectImage(item)
                }
            }
        case .photoLibrary:
            PhotosImagePicker { item in
                pickerDidSelectImage(item)
            } onCancel: {
                sourceType = nil
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

struct ImagePickerItem: Identifiable, Sendable {
    let id: String
    let image: UIImage
}
