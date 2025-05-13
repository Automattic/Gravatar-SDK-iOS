import Combine
import CoreFoundation

@MainActor
class DismissDetectingModel: ObservableObject {
    @Published var hasBeenDraggedDown = false

    var initialViewPosition: CGPoint = .zero
    var lastPosition: CGPoint = .zero
    var viewPosition: CGPoint = .zero {
        didSet {
            viewPositionUpdated()
        }
    }

    private func viewPositionUpdated() {
        let newValue = viewPosition
        if initialViewPosition.y == 0 {
            initialViewPosition = newValue
        }
        if hasBeenDraggedDown, abs(newValue.y - initialViewPosition.y) < 5, newValue.y <= lastPosition.y {
            setHasBeenDraggedDown(false)
        }
        if (newValue.y - initialViewPosition.y) > 20 {
            setHasBeenDraggedDown(true)
        }
        lastPosition = newValue
    }

    private func setHasBeenDraggedDown(_ value: Bool) {
        if hasBeenDraggedDown != value {
            hasBeenDraggedDown = value
        }
    }
}
