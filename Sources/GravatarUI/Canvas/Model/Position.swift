import Foundation

struct Position: Decodable, Hashable {
    enum Kind: Hashable {
        case center(Point)
        case origin(Point)
    }

    let kind: Kind

    private enum CodingKeys: String, CodingKey {
        case center
        case origin
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let centerVal = try container.decodeIfPresent(Point.self, forKey: .center) {
            kind = .center(centerVal)
        } else if let originVal = try container.decodeIfPresent(Point.self, forKey: .origin) {
            kind = .origin(originVal)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.center,
                in: container,
                debugDescription: "Expected either 'center' or 'origin' in 'position' object."
            )
        }
    }
}
