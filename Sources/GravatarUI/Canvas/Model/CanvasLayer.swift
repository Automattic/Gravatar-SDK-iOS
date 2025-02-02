import Foundation

enum LayerType: String, Decodable, Hashable {
    case background
    case frame
    case person
    case none
    // potentially add more if needed like "someOtherType"
}

struct CanvasLayer: Decodable, Hashable {
    enum Kind: Hashable {
        case remoteImage(RemoteImage)
        case localImage(String)
        case linearGradient(LinearGradientInfo)
        case color(HexColor)
        case maskedImage(cropped: Bool)
        case undetermined
    }

    enum SizeType: Hashable {
        case normal(Size2D)
        case intrinsicSize(IntrinsicSize)
    }

    let type: LayerType
    let kind: Kind
    let sizeType: SizeType
    let maskLayers: [MaskLayer]?
    let position: Position
    var isCropped: Bool {
        switch kind {
        case .maskedImage(let cropped):
            cropped
        default:
            false
        }
    }

    init(type: LayerType, kind: Kind, sizeType: SizeType, position: Position, maskLayers: [MaskLayer]?) {
        self.type = type
        self.kind = kind
        self.sizeType = sizeType
        self.position = position
        self.maskLayers = maskLayers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let size = try container.decodeIfPresent(Size2D.self, forKey: .size) {
            sizeType = .normal(size)
        } else if let size = try container.decodeIfPresent(IntrinsicSize.self, forKey: .intrinsicSize) {
            sizeType = .intrinsicSize(size)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.size,
                in: container,
                debugDescription: "Expected either 'size' or 'IntrinsicSize'."
            )
        }
        self.type = try container.decode(LayerType.self, forKey: .type)
        self.position = try container.decode(Position.self, forKey: .position)
        self.maskLayers = try container.decodeIfPresent([MaskLayer].self, forKey: .maskLayers)
        if let remoteImage = try container.decodeIfPresent(RemoteImage.self, forKey: .remoteImage) {
            kind = .remoteImage(remoteImage)
        } else if let imageName = try container.decodeIfPresent(String.self, forKey: .imageName) {
            kind = .localImage(imageName)
        } else if let linearGradient = try container.decodeIfPresent(LinearGradientInfo.self, forKey: .linearGradient) {
            kind = .linearGradient(linearGradient)
        } else if let color = try container.decodeIfPresent(HexColor.self, forKey: .color) {
            kind = .color(color)
        } else if let isCropped = try container.decodeIfPresent(Bool.self, forKey: .cropped) {
            kind = .maskedImage(cropped: isCropped)
        } else {
            kind = .undetermined
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
        case cropped
        case remoteImage = "remote_image"
        case imageName = "image_name"
        case intrinsicSize = "intrinsic_size"
        case linearGradient = "linear_gradient"
        case maskLayers = "mask_layers"
        case color
        case size
        case position
    }

    func copyOverriding(kind newKind: Kind) -> CanvasLayer {
        CanvasLayer(type: type, kind: newKind, sizeType: sizeType, position: position, maskLayers: maskLayers)
    }
}
