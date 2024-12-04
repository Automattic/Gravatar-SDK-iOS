import SwiftUI
import PhotosUI
import GravatarUI

struct ReplaceBackgroundView: View {
    enum Constants {
        static let backgroundPictureCount = 56
    }
    @State private var selectedItem: PhotosPickerItem?
    @State private var croppedImage: UIImage?
    @State private var outputImage: ImagePickerItem?

    @State private var isSharing: Bool = false
    @State var imagePickerSelectedItem: ImagePickerItem?
    @State private var selectedSegment = "Image"
    @State private var selectedColor: Color = Color(uiColor: UIColor(red: 240/255, green: 184/255, blue: 73/255, alpha: 1))
    @State private var selectedImageNumber: Int = 1
    @State private var customBackgroundImage: UIImage?
    var shouldShowTooltip: Bool {
        return customBackgroundImage == nil && attemptSelect0
    }
    @State private var attemptSelect0: Bool = false

    var body: some View {
        ScrollView {
            VStack() {
                if let image = outputImage?.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .background(Color.blue.opacity(0.5))
                        .padding(12)
                }
                else {
                    Spacer()
                        .frame(width: 300, height: 300)
                        .background(Color.gray.opacity(0.5))
                        .padding(12)
                }
                PhotoPickerView(onImageSelected: { image in
                    print("photosPicker first one called")
                    self.croppedImage = image
                }, label: {
                    Text("Select a Photo")
                })

                Divider()
                    .padding(.bottom, 8)
                    .padding(.horizontal, 16)

                Text("Backgrounds").font(.headline)

                Picker("Options", selection: $selectedSegment) {
                    Label("Image", systemImage: "photo.fill").tag("Image")
                    Label("Color", systemImage: "paintbrush.fill").tag("Color")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 8)
                .padding(.horizontal, 16)

                // Content Based on Selection
                if selectedSegment == "Color" {
                    VStack {
                        ColorPicker("Pick a Color", selection: $selectedColor)
                            .padding()
                    }
                } else if selectedSegment == "Image" {
                    VStack {
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 4) {
                                ZStack(alignment: .bottomTrailing) {
                                    Image(uiImage: customBackgroundImage ?? UIImage())
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .padding(4)
                                    
                                        .border(selectedImageNumber == 0 ? Color.blue : Color.clear, width: 3)
                                        .background(Color.gray.opacity(0.2))
                                        .overlay(alignment: .trailing) {
                                            if shouldShowTooltip {
                                                Text("Pick Image👇")
                                                    .foregroundColor(Color(UIColor.label))
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 2)
                                            }
                                        }
                                        .onTapGesture {
                                            if customBackgroundImage != nil {
                                                selectedImageNumber = 0
                                                attemptSelect0 = false
                                            }
                                            else {
                                                attemptSelect0 = true
                                            }
                                        }
                                    
                                    PhotoPickerView(onImageSelected: { image in
                                          print("photosPicker second one called")
                                          customBackgroundImage = image
                                    }, label: {
                                        Image(systemName: "photo.on.rectangle.angled.fill")
                                            .renderingMode(.template)
                                            .tint(.white)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 6)
                                            .background(Color(uiColor: .black.withAlphaComponent(0.4)))
                                            .cornerRadius(2)
                                            .padding(4)
                                            .foregroundColor(Color(.white))
                                    })

                                }

                                ForEach(1...56, id: \.self) { number in
                                    if let image = UIImage(named: "bg-\(number)") {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .padding(4)
                                            .border(selectedImageNumber == number ? Color.blue : Color.clear, width: 3)
                                            .onTapGesture {
                                                selectedImageNumber = number
                                            }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                Spacer()
            }
        }
        .onChange(of: selectedSegment) { _, _ in
            updateOutputImage()
        }
        .onChange(of: selectedColor) { _, _ in
            updateOutputImage()
        }
        .onChange(of: selectedImageNumber) { _, _ in
            updateOutputImage()
        }
        .onChange(of: croppedImage) { _, _ in
            updateOutputImage()
        }
        .onChange(of: customBackgroundImage) { _, _ in
            updateOutputImage()
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
                .disabled(outputImage == nil) // Disable button if no image
            }
        }
        .sheet(isPresented: $isSharing) {
            if let image = outputImage {
                ShareSheet(items: [image])
                    .presentationDetents([.fraction(0.6), .large])
            }
        }
    }
    
  /*  @ViewBuilder
    func photosPicker<Label: View>(photoSelected: @escaping ((UIImage) -> Void), @ViewBuilder label: @Sendable () -> Label) -> some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            label()
        }
        .sheet(item: $imagePickerSelectedItem, content: { item in
            ImageCropperView(image: item.image) { newImage in
                photoSelected(newImage)
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
    }*/

    func updateOutputImage() {
        print("Updating output image...")

        guard let croppedImage else {
            print("Cropped image is nil")
            return
        }

        if selectedSegment == "Color" {
            guard let bgImage = createImage(color: UIColor(selectedColor),
                                            size: .init(width: 600, height: 600)) else { return }
            croppedImage.replaceBackground(with: bgImage) {  image in
                Task { @MainActor in
                    if let image {
                        outputImage = .init(id: UUID().uuidString, image: image)
                        print("Output image updated with color background")
                    }
                }
            }
        } else if selectedSegment == "Image" {
            var bgImage: UIImage?
            if selectedImageNumber == 0 {
                bgImage = customBackgroundImage
            }
            else if let image = UIImage(named: "bg-\(selectedImageNumber)") {
                bgImage = image
            }
            guard let image = bgImage else { return }
            croppedImage.replaceBackground(with: image) {  image in
                Task { @MainActor in
                    if let image {
                        outputImage = .init(id: UUID().uuidString, image: image)
                        print("Output image updated with selected background image")
                    }
                }
            }
        }
    }

    private func createImage(color: UIColor = .blue, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
