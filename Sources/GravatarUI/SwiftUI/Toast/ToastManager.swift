import SwiftUI

@MainActor
class ToastManager: ObservableObject {
    @Published var toasts: [ToastItem] = []

    func showToast(_ message: String, type: ToastType = .info) {
        let toast = ToastItem(message: message, type: type)
        toasts.append(toast)
        DispatchQueue.main.asyncAfter(deadline: .now() + calculateToastDuration(for: message)) {
            self.removeToast(toast.id)
        }
    }

    func removeToast(_ toastID: UUID) {
        withAnimation {
            toasts.removeAll { $0.id == toastID }
        }
    }

    private func calculateToastDuration(for message: String) -> TimeInterval {
        let baseTime: TimeInterval = 2.0
        let timePerCharacter: TimeInterval = 0.03
        return baseTime + timePerCharacter * Double(message.count)
    }
}

enum ToastType: Int {
    case info
    case error
}

struct ToastItem: Identifiable, Equatable {
    let id: UUID = .init()
    let message: String
    let type: ToastType
}
