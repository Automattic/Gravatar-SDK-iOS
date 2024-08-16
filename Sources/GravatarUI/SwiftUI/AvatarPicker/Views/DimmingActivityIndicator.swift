import SwiftUI

struct DimmingActivityIndicator: View {
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.3))
            ProgressView().tint(.white)
        }
    }
}

#Preview {
    DimmingActivityIndicator()
        .frame(width: 80, height: 80)
}
