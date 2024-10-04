import Foundation

extension Int {
    package var is4XX: Bool {
        self >= 400 && self < 500
    }
}
