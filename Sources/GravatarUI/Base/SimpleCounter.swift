import Foundation

@MainActor
enum SimpleCounter {
    private(set) static var current: UInt = 0
    static func next() -> UInt {
        current += 1
        return current
    }
}
