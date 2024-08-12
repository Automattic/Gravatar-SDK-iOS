import SwiftUI

struct ToastContainerView: View {
    @ObservedObject var toastManager: ToastManager

    var body: some View {
        VStack {
            Spacer()
            ForEach(toastManager.toasts) { toast in
                Toast(toast: toast) { toast in
                    toastManager.removeToast(toast.id)
                }
                .frame(width: .infinity)
            }
        }
        .frame(idealWidth: .infinity)
        .animation(.spring(), value: toastManager.toasts)
        .edgesIgnoringSafeArea(.bottom)
        .padding(.bottom, .DS.Padding.half)
    }
}

#Preview {
    VStack {
        var toastManager = ToastManager()
        ToastContainerView(toastManager: toastManager)
            .frame(width: .infinity)
            .padding(.horizontal, .DS.Padding.medium)
        Button {
            toastManager.showToast("Hi! This is a toast! You can show multiple toasts at a time!")
        } label: {
            Text("Show toast!")
        }
    }
}