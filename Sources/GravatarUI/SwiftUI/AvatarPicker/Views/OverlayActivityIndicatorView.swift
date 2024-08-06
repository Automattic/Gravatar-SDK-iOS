import SwiftUI

struct OverlayActivityIndicatorView: View {
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.3))
            ProgressView().tint(.white)
        }
    }
}

#Preview {
    OverlayActivityIndicatorView()
        .frame(width: 80, height: 80)
}
