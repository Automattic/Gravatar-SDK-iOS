import SwiftUI
import PhotosUI
import GravatarUI

struct ReplaceBackgroundView: View {
    enum Constants {
        static let backgroundPictureCount = 56
    }
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isSharing: Bool = false
    @State var imagePickerSelectedItem: ImagePickerItem?

    var body: some View {
        ScrollView {
            VStack() {
                VStack {
                    Image(uiImage: selectedImage ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }
                .background(Color.gray.opacity(0.5))
                .padding(12)

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Select a Photo", image: "image")
                }
                .sheet(item: $imagePickerSelectedItem, content: { item in
                    ImageCropperView(image: item.image) { croppedImage in
                        self.selectedImage = croppedImage
                        imagePickerSelectedItem = nil
                    } onCancel: {
                        imagePickerSelectedItem = nil
                    }
                })
                .onChange(of: selectedItem) { oldItem, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            imagePickerSelectedItem = .init(id: newItem?.itemIdentifier ?? UUID().uuidString, image: uiImage)
                        }
                    }
                }
                Spacer()
            }
        }
        .navigationTitle("Replace Background")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isSharing = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                }
                .disabled(selectedImage == nil) // Disable button if no image
            }
        }
        .sheet(isPresented: $isSharing) {
            if let image = selectedImage {
                ShareSheet(items: [image])
                    .presentationDetents([.fraction(0.6), .large])
            }
        }
    }
}

#Preview {
    ReplaceBackgroundView()
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ImagePickerItem: Identifiable, Sendable {
    let id: String
    let image: UIImage
}
