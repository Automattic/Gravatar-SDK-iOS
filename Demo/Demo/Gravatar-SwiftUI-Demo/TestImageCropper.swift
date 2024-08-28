import SwiftUI
import GravatarUI

struct TestImageCropper: View, ImageEditorView {
    var inputImage: UIImage
    var editingDidFinish: ((UIImage) -> Void)
    
    init(inputImage: UIImage, editingDidFinish: @escaping (UIImage) -> Void) {
        self.inputImage = inputImage
        self.editingDidFinish = editingDidFinish
    }
    
    var body: some View {
        Text("This is a dummy image cropper for solely test purposes. It doesn't do anything. It just passes the image as it is when the button is tapped.")
            .padding()
        Image(uiImage: inputImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
        Button(action: cropImage) {
            Text("Crop Image")
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
    
    private func cropImage() {
        editingDidFinish(inputImage)
    }
}

#Preview {
    TestImageCropper(inputImage: UIImage()) { _ in }
}

