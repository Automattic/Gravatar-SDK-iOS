import Combine
import SwiftUI

enum Orientation {
    case landscape
    case portrait
    case unknown
}

@propertyWrapper
struct DeviceOrientation: DynamicProperty {
    @StateObject private var manager = DeviceOrientationManager()

    var wrappedValue: Orientation {
        manager.orientation
    }
}

private class DeviceOrientationManager: ObservableObject {
    @Published var orientation: Orientation = .unknown

    private var cancellables: Set<AnyCancellable> = []

    @MainActor
    init() {
        orientation = UIDevice.current.orientation.map()

        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.orientation = UIDevice.current.orientation.map()
            }
            .store(in: &cancellables)
    }
}

extension UIDeviceOrientation {
    fileprivate func map() -> Orientation {
        switch self {
        case .portrait, .portraitUpsideDown:
            .portrait
        case .landscapeLeft, .landscapeRight:
            .landscape
        default:
            .unknown
        }
    }
}
