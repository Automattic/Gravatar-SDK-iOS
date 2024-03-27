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

    /// Whether this URL instance corresponds to a valid Gravatar URL.
    var isGravatarURL: Bool {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let host = components.host
        else {
            return false
        }

        return (host.hasSuffix(".gravatar.com") || host == "gravatar.com")
            && components.scheme == "https"
    }
}
