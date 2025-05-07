import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}

extension [Bool] {
    var hasMoreThanOneTrue: Bool {
        count { $0 } > 1
    }
}
