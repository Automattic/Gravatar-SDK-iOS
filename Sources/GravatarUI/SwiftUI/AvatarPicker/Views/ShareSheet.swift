import SwiftUI

/// Use `ShareLink` after iOS 16+.
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var activities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        controller.excludedActivityTypes = [.print,
                                            .postToWeibo,
                                            .postToTencentWeibo,
                                            .addToReadingList,
                                            .postToVimeo,
                                            .openInIBooks]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No need to update dynamically
    }
}
