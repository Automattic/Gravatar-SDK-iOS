import SwiftUI

@MainActor
struct SegmentationView: View {
    let options = SegmentationOption.makeSegmentationOptions()

    // Track which type is selected
    @State private var selectedOption: SegmentationOption?
    @State private(set) var segmentationType: SegmentationType

    @ObservedObject var viewModel: PersonSegmentationModel
    // @State var imageMap: [SegmentationType: UIImage] = [:]
    @State private var localImage: SegmentationResult?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    let inputImage: UIImage
    let inputImageID: String
    let onDone: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: .DS.Padding.single) {
                // 2) "Segmented" image display area
                //    We'll show a checkerboard background behind the final image
                ZStack(alignment: .bottom) {
                    // Checkerboard background
                    if let tilesImage = UIImage(named: "checkerboard16x16") {
                        Image(uiImage: tilesImage)
                            .resizable(resizingMode: .tile)
                        // .ignoresSafeArea()
                        // .clipped()
                    }
                    if let localImage {
                        Image(uiImage: localImage.resultImage)
                            .resizable(resizingMode: .stretch)
                            .scaledToFit()
                        // .ignoresSafeArea()
                        // .clipped()
                    }
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }

                    // The actual "foreground" image
                    /*  if let selectedOption, let icon = selectedOption.icon {
                         // Here we switch images based on the selection
                         // For a real segmentation preview, you'd do your processing
                         // and display the segmented result. We'll do an SFSymbol for demo:
                         Image(uiImage: icon)
                             .resizable()
                             .scaledToFit()
                             .padding(40)
                     } else {
                             Text("No Image")
                     }*/
                }

                .frame(maxWidth: 400, maxHeight: 400)
                .border(Color.gray.opacity(0.4), width: 1)
                .padding(.horizontal, .DS.Padding.single)

                // Spacer()
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                }
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: .DS.Padding.split) {
                        ForEach(options.indices, id: \.self) { i in
                            OptionButton(
                                option: options[i],
                                isSelected: options[i] == selectedOption
                            ) {
                                selectedOption = options[i]
                                generateImage(for: options[i].type)
                            }
                            // Only insert a divider if this is NOT the last item
                            if i < options.count - 1 {
                                Divider()
                                    // By default, Divider is 1 point wide in an HStack
                                    .frame(height: 1) // Adjust to taste
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .onAppear {
                        selectedOption = options.first(where: { $0.type == segmentationType })
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("Cutout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.currentSegmentationResult = localImage
                        onDone()
                    }
                }
            }
        }
        .onAppear {
            let key = SegmentationResultKey(imageKey: inputImageID, segmentationType: segmentationType)
            if let segmentedImage = viewModel.segmentedImageMap[key] {
                self.localImage = segmentedImage
            } else {
                generateImage(for: segmentationType)
            }
        }
    }

    @MainActor
    func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }

    func generateImage(for segmentationType: SegmentationType) {
        let key = SegmentationResultKey(imageKey: inputImageID, segmentationType: segmentationType)
        if let segmentedImage = viewModel.segmentedImageMap[key] {
            self.localImage = segmentedImage
            errorMessage = nil
        } else {
            Task {
                do {
                    self.isLoading = true
                    let result = try await viewModel.runSegmentationRequestOnImage(inputImage, for: segmentationType, cacheKey: inputImageID)
                    self.localImage = result
                    errorMessage = nil
                    self.isLoading = false
                } catch let error as SegmentationError {
                    self.isLoading = false
                    errorMessage = error.localizedMessage
                    self.localImage = nil
                } catch {
                    self.isLoading = false
                    self.localImage = nil
                    errorMessage = SDKLocalizedString(
                        "Oops! Something went wrong while removing the background of this image.",
                        comment: "Error message to show if removing the background of an image fails."
                    )
                }
            }
        }
    }
}

/// A custom button style showing an icon + label,
/// highlighted if `isSelected` is true.
struct OptionButton: View {
    let option: SegmentationOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 4) {
                if let icon = option.icon {
                    Image(uiImage: icon.withRenderingMode(.alwaysTemplate))
                        .imageScale(.large)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.title)
                            .font(.callout.weight(.semibold))
                        Text(option.description)
                            .font(.caption)
                    }
                    .padding(.horizontal, .DS.Padding.single)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(isSelected ? .white : .primary)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(uiColor: .secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SegmentationView(
        segmentationType: .people,
        viewModel: PersonSegmentationModel(),
        inputImage: UIImage(),
        inputImageID: UUID().uuidString,
        onDone: { print("Done") },
        onCancel: { print("Cancel") }
    )
}
