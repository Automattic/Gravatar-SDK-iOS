import SwiftUI

@MainActor
class ToastManager: ObservableObject {
    @Published var toasts: [ToastItem] = []

    func showToast(_ message: String, type: ToastType = .info, stackingBehavior: ToastStackingBehavior = .avoidStackingWithSameMessage) {
        let toast = ToastItem(message: message, type: type, stackingBehavior: stackingBehavior)
        dismissExistingIfNeeded(upcomingToast: toast)
        toasts.append(toast)
        DispatchQueue.main.asyncAfter(deadline: .now() + calculateToastDuration(for: message)) {
            self.removeToast(toast.id)
        }
    }

    func dismissExistingIfNeeded(upcomingToast: ToastItem) {
        toasts.filter { item in
            switch upcomingToast.stackingBehavior {
            case .avoidStackingWithSameMessage:
                upcomingToast.message == item.message
            case .alwaysStack:
                false
            }
        }.forEach { element in
            removeToast(element.id)
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

enum ToastStackingBehavior: Equatable {
    /// Dismiss the toast with the same message before showing the new one.
    case avoidStackingWithSameMessage
    /// Stack the message without dismissing the existing ones.
    case alwaysStack
}

struct ToastItem: Identifiable, Equatable {
    let id: UUID = .init()
    let message: String
    let type: ToastType
    let stackingBehavior: ToastStackingBehavior
}
