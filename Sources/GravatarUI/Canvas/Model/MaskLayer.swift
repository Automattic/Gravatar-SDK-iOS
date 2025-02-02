import Foundation

struct MaskLayer: Decodable, Hashable {
    enum Kind: Hashable {
        case remoteImage(RemoteImage)
        case localImage(String)
        case circle
        case rectangle
        case roundedRectangle(cornerRadii: Size2D, roundCorners: [String]?)
        case oval
    }

    let kind: Kind
    let size: Size2D
    let position: Position
    let blendMode: MaskBlendMode

    enum CodingKeys: String, CodingKey {
        case type
        case remoteImage = "remote_image"
        case imageName = "image_name"
        case size
        case radius
        case cornerRadii = "corner_radii"
        case roundCorners = "round_corners"
        case position
        case blendMode = "blend_mode"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.size = try container.decode(Size2D.self, forKey: .size)
        self.blendMode = try container.decode(MaskBlendMode.self, forKey: .blendMode)
        self.position = try container.decode(Position.self, forKey: .position)
        let type = try container.decode(MaskLayerType.self, forKey: .type)
        switch type {
        case .circle:
            kind = .circle
        case .localImage:
            kind = try .localImage(container.decode(String.self, forKey: .imageName))
        case .remoteImage:
            kind = try .remoteImage(container.decode(RemoteImage.self, forKey: .remoteImage))
        case .rectangle:
            kind = .rectangle
        case .roundedRectangle:
            kind = try .roundedRectangle(
                cornerRadii: container.decode(Size2D.self, forKey: .cornerRadii),
                roundCorners: container.decodeIfPresent([String].self, forKey: .roundCorners)
            )
        case .oval:
            kind = .oval
        }
    }
}

enum MaskLayerType: String, Decodable, Hashable {
    case remoteImage = "remote_image"
    case localImage = "local_image"
    case rectangle
    case circle
    case roundedRectangle = "rounded_rectangle"
    case oval
}

enum MaskBlendMode: String, Decodable, Hashable {
    case normal
    case clear
}
