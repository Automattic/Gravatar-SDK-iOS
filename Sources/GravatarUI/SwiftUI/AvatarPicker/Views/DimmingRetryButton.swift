import SwiftUI

/// Dims the parent and puts a retry button on it.
struct DimmingRetryButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }, label: {
            ZStack {
                Rectangle()
                    .fill(.black.opacity(0.3))
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
            }
        })
        .frame(width: .infinity, height: .infinity)
        .foregroundColor(Color.white)
    }
}

#Preview {
    DimmingRetryButton {}
}
