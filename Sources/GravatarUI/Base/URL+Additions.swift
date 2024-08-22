import Foundation

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
