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
        ImagePicker() {
            label()
        } onImageSelected: { image in
            onImageSelected(image)
        } customCropper: { image, croppingDidFinish in
            TestCropper(inputImage: image, croppingDidFinish: croppingDidFinish)
        }
    }
}

private struct ImagePicker<Label, ImageCropper: ImageCropperView>: View where Label: View {
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
    var customCropper: ((UIImage, _ croppingDidFinish: @escaping (UIImage) -> Void) -> ImageCropper)?
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
            displayPickerOrCamera(source)
                .sheet(item: $imagePickerSelectedItem, content: { item in
                    if let customCropper {
                        customCropper(item.image) { croppedImage in
                            imagePickerSelectedItem = nil
                            onImageSelected(croppedImage)
                        }
                    }
                })
        })
    }
    
    @ViewBuilder
    private func displayPickerOrCamera(_ source: SourceType) -> some View {
        switch source {
        case .camera:
            ZStack {
                Color.black.ignoresSafeArea(edges: .all)
                LegacyImagePickerRepresentable(sourceType: source.map(), useBuiltInCropper: customCropper == nil) { item in
                    pickerDidSelectImage(item)
                }
            }
        case .photoLibrary:
            LegacyImagePickerRepresentable(sourceType: source.map(), useBuiltInCropper: customCropper == nil) { item in
                pickerDidSelectImage(item)
            }.ignoresSafeArea()
        }
    }
    
    private func pickerDidSelectImage(_ item: ImagePickerItem) {
        if customCropper != nil {
            imagePickerSelectedItem = item
        }
        else {
            onImageSelected(item.image)
        }
    }
}

protocol ImageCropperView: View {
    var inputImage: UIImage { get }
    var croppingDidFinish: ((UIImage) -> Void) { get set }
}

struct TestCropper: View, ImageCropperView {
    var inputImage: UIImage
    var croppingDidFinish: ((UIImage) -> Void)
    
    init(inputImage: UIImage, croppingDidFinish: @escaping (UIImage) -> Void) {
        self.inputImage = inputImage
        self.croppingDidFinish = croppingDidFinish
    }
    
    var body: some View {
        Button(action: cropImage) {
            Text("Crop Image")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
    
    private func cropImage() {
        croppingDidFinish(inputImage)
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
    var useBuiltInCropper: Bool
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
        imagePicker.allowsEditing = useBuiltInCropper
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
            }
            else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.pickedImage = .init(image: image, url: url)
            }

            parent.presentationMode.wrappedValue.dismiss()
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
