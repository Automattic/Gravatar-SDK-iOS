import SwiftUI

/// If a custom editor exists then shows it, otherwise shows the default image cropper.
struct CustomizableImageEditor<ImageEditor: ImageEditorView>: View {
    let item: ImagePickerItem
    let customEditor: ImageEditorBlock<ImageEditor>?
    let onEditComplete: (UIImage) -> Void
    let onCancel: (() -> Void)?

    var body: some View {
        if let customEditor {
            customEditor(item.image) { editedImage in
                Task { @MainActor in
                    onEditComplete(editedImage)
                }
            }
        } else {
            ImageCropper(inputImage: item.image) { croppedImage in
                Task { @MainActor in
                    onEditComplete(croppedImage)
                }
            } onCancel: {
                onCancel?()
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    if let image = UIImage(systemName: "person") {
        CustomizableImageEditor<NoCustomEditor>(
            item: .init(id: "", image: image),
            customEditor: nil
        ) { _ in
        }
        onCancel: {}
    }
}
