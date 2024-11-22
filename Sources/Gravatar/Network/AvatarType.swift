import Foundation

public protocol AvatarType: Sendable {
    var url: String { get }
    var id: String { get }
}

extension Avatar: AvatarType {
    public var id: String {
        imageId
    }

    public var url: String {
        imageUrl
    }

    package func url(withSize size: String) -> String {
        if let newURL = URLComponents(string: url)?.replacingQueryItem(name: "size", value: size).string {
            return newURL
        }
        return url
    }

    package var isSelected: Bool {
        selected ?? false
    }
}
