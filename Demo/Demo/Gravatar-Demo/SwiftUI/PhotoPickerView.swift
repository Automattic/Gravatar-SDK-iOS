import SwiftUI
import PhotosUI
import GravatarUI

struct PhotoPickerView<Label: View>: View {
    let onImageSelected: (UIImage) -> Void
    @ViewBuilder let label: () -> Label

    @State private var photosPickerItem: PhotosPickerItem?
    @State private var imagePickerItem: ImagePickerItem?

    var body: some View {
        PhotosPicker(
            selection: $photosPickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            label()
        }
        .sheet(item: $imagePickerItem) { item in
            ImageCropperView(image: item.image) { croppedImage in
                onImageSelected(croppedImage)
                imagePickerItem = nil
            } onCancel: {
                imagePickerItem = nil
            }
        }
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    imagePickerItem = .init(id: newItem?.itemIdentifier ?? UUID().uuidString, image: uiImage)
                }
            }
        }
    }
}

#Preview {
    PhotoPickerView { _ in
    } label: {
        Text("Select image")
    }

}
