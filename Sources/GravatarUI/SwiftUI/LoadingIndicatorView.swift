import SwiftUI

struct LoadingIndicatorView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.regular)
            Spacer()
        }
        .padding(.top, .DS.Padding.large)
    }
}

#Preview {
    LoadingIndicatorView()
}
