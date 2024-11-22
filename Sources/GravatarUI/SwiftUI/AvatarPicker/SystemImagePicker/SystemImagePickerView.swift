import ImagePlayground
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
        case playground

        static var allCases: [SourceType] {
            var cases: [SourceType] = [.camera, .photoLibrary]
            if #available(iOS 18.2, *) {
                if EnvironmentValues().supportsImagePlayground {
                    cases.append(.playground)
                }
            }
            return cases
        }

        var id: Int {
            self.hashValue
        }
    }

    @State private var sourceType: SourceType?

    @ViewBuilder var label: () -> Label
    let onImageSelected: (UIImage) -> Void
    var customEditor: ImageEditorBlock<ImageEditor>?
    @State var imagePickerSelectedItem: ImagePickerItem?
    @State var playgroundSelectedItem: ImagePickerItem?

    var body: some View {
        VStack {
            Menu {
                ForEach(SourceType.allCases) { source in
                    Button {
                        sourceType = source
                    } label: {
                        SwiftUI.Label(source.localizedTitle, systemImage: source.iconName)
                    }
                }
            } label: {
                label()
            }
        }
        .imagePlaygroundSheetIfAvailable(
            isPresented: Binding(
                get: { sourceType == .playground },
                set: { if !$0 { sourceType = nil } }
            ),
            sourceImage: nil,
            onCompletion: { url in
                if let image = UIImage(contentsOfFile: url.relativePath) {
                    playgroundSelectedItem = ImagePickerItem(id: url.absoluteString, image: image)
                }
            },
            onCancellation: {}
        )
        .sheet(item: $playgroundSelectedItem, content: { item in
            imageEditor(with: item)
        })
        .sheet(
            item: Binding(
                get: { sourceType != .playground ? sourceType : nil },
                set: { sourceType = $0 }
            ),
            content: { source in
                // This allows to present different kind of pickers for different sources.
                displayImagePicker(for: source)
                    .sheet(item: $imagePickerSelectedItem, content: { item in
                        imageEditor(with: item)
                    })
            }
        )
    }

    @ViewBuilder
    func imageEditor(with item: ImagePickerItem) -> some View {
        if let customEditor {
            customEditor(item.image) { editedImage in
                self.onImageEdited(editedImage)
            }
        } else {
            ImageCropper(inputImage: item.image) { croppedImage in
                Task {
                    await self.onImageEdited(croppedImage)
                }
            } onCancel: {
                imagePickerSelectedItem = nil
                playgroundSelectedItem = nil
            }.ignoresSafeArea()
        }
    }

    private func onImageEdited(_ image: UIImage) {
        imagePickerSelectedItem = nil
        playgroundSelectedItem = nil
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
        case .playground:
            EmptyView()
        }
    }

    private func pickerDidSelectImage(_ item: ImagePickerItem) {
        Task {
            await UIApplication.shared.dismissKeyboard()
        }
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
        case .playground:
            "apple.image.playground"
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
        case .playground:
            SDKLocalizedString(
                "SystemImagePickerView.Source.Playground.title",
                value: "Playground",
                comment: "An option to show the image playground"
            )
        }
    }
}

struct ImagePickerItem: Identifiable, Sendable {
    let id: String
    let image: UIImage
}
