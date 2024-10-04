public protocol AvatarType {
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

    package var isSelected: Bool {
        selected ?? false
    }
}
