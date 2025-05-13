import Combine
import CoreFoundation

@MainActor
class DismissDetectingModel: ObservableObject {
    @Published var hasBeenDraggedDown = false

    private var initialViewPosition: CGPoint = .zero
    private var lastPosition: CGPoint = .zero
    var viewPosition: CGPoint = .zero {
        didSet {
            viewPositionUpdated()
        }
    }

    private func viewPositionUpdated() {
        let newValue = viewPosition
        if initialViewPosition.y == 0 {
            // store the initial position
            initialViewPosition = newValue
        }
        if hasBeenDraggedDown, abs(newValue.y - initialViewPosition.y) < 5, newValue.y <= lastPosition.y {
            // the sheet is back up
            setHasBeenDraggedDown(false)
        }
        if (newValue.y - initialViewPosition.y) > 20 {
            // the sheet is dragged down
            setHasBeenDraggedDown(true)
        }
        lastPosition = newValue
    }

    // Resets the internal state. Call it on sheet display, size class change etc.
    func reset() {
        initialViewPosition = .zero
        lastPosition = .zero
    }

    private func setHasBeenDraggedDown(_ value: Bool) {
        // Avoid unnecessary updates.
        if hasBeenDraggedDown != value {
            hasBeenDraggedDown = value
        }
    }
}
