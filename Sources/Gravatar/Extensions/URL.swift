import Foundation

extension URL {
    @available(swift, deprecated: 16.0, message: "Use URL.appending(path:) instead")
    func appending(pathComponent path: String) -> URL {
        if #available(iOS 16.0, *) {
            self.appending(path: path)
        } else {
            self.appendingPathComponent(path)
        }
    }
}
