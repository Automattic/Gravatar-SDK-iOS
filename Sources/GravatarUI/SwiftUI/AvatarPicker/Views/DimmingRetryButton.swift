import SwiftUI

/// Dims the parent and puts a retry button on it.
struct DimmingRetryButton: View {
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                ZStack {
                    Rectangle()
                        .fill(.black.opacity(0.3))
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 25, height: 25)
                }
            }
        )
        .foregroundColor(Color.white)
    }
}

#Preview {
    DimmingRetryButton {}
}
