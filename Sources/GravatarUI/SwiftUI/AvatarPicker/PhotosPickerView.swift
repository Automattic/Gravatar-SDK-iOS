import _PhotosUI_SwiftUI
import SwiftUI

@available(iOS 16, *)
struct PhotosPickerView<Label>: View where Label: View {
    @ViewBuilder var label: () -> Label
    @State private var selectedItem: PhotosPickerItem?
    let onImageSelected: (UIImage) -> Void

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            label()
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                // Retrieve the selected image
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data)
                {
                    onImageSelected(image)
                    selectedItem = nil
                }
            }
        }
    }
}

#if swift(>=6.0)
#warning("Revisit @unchecked Sendable on Swift 6 version, PhotosPickerItem should be Sendable by now.")
#endif
@available(iOS 16, *)
extension PhotosPickerItem: @unchecked Sendable {}

#Preview {
    if #available(iOS 16, *) {
        PhotosPickerView {
            Text("Photo Picker")
        } onImageSelected: { _ in
        }
    } else {
        Text("Requires iOS 16")
    }
}
