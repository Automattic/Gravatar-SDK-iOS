import SwiftUI

/// Dims the parent and puts a retry button on it.
struct DimmingButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                ZStack {
                    Rectangle()
                        .fill(.black.opacity(0.3))
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                }
            }
        )
        .foregroundColor(Color.white)
    }
}

/// Dims the parent and puts an exclamation mark on it.
struct DimmingErrorButton: View {
    let action: () -> Void

    var body: some View {
        DimmingButton(imageName: "exclamationmark.triangle.fill", action: action)
    }
}

#Preview {
    VStack {
        DimmingErrorButton {}.frame(width: 100, height: 100)
    }
}
