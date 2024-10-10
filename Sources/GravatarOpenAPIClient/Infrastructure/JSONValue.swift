import Foundation

public enum JSONValue: Codable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([JSONValue])
    case dictionary([String: JSONValue])
    case null

    // MARK: - Decoding Logic

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let arrayValue = try? container.decode([JSONValue].self) {
            self = .array(arrayValue)
        } else if let dictionaryValue = try? container.decode([String: JSONValue].self) {
            self = .dictionary(dictionaryValue)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown JSON value")
        }
    }

    // MARK: - Encoding Logic

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

extension JSONValue {
    public init(_ value: String) {
        self = .string(value)
    }

    public init(_ value: Int) {
        self = .int(value)
    }

    public init(_ value: Double) {
        self = .double(value)
    }

    public init(_ value: Bool) {
        self = .bool(value)
    }

    public init(_ value: [JSONValue]) {
        self = .array(value)
    }

    public init(_ value: [String: JSONValue]) {
        self = .dictionary(value)
    }

    public init(_ codable: some Codable) throws {
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(codable)
        let decoder = JSONDecoder()

        let decodedValue = try decoder.decode(JSONValue.self, from: encodedData)
        self = decodedValue
    }
}

extension JSONValue {
    public var isString: Bool {
        if case .string = self { return true }
        return false
    }

    public var isInt: Bool {
        if case .int = self { return true }
        return false
    }

    public var isDouble: Bool {
        if case .double = self { return true }
        return false
    }

    public var isBool: Bool {
        if case .bool = self { return true }
        return false
    }

    public var isArray: Bool {
        if case .array = self { return true }
        return false
    }

    public var isDictionary: Bool {
        if case .dictionary = self { return true }
        return false
    }

    public var isNull: Bool {
        self == .null
    }
}

extension JSONValue {
    public var stringValue: String? {
        switch self {
        case .string(let value):
            value
        default:
            nil
        }
    }

    public var intValue: Int? {
        switch self {
        case .int(let value):
            value
        default:
            nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case .double(let value):
            value
        default:
            nil
        }
    }

    public var boolValue: Bool? {
        switch self {
        case .bool(let value):
            value
        default:
            nil
        }
    }

    public var arrayValue: [JSONValue]? {
        if case .array(let value) = self {
            return value
        }
        return nil
    }

    public var dictionaryValue: [String: JSONValue]? {
        if case .dictionary(let value) = self {
            return value
        }
        return nil
    }
}

extension JSONValue {
    public subscript(key: String) -> JSONValue? {
        dictionaryValue?[key]
    }

    public subscript(index: Int) -> JSONValue? {
        guard case .array(let array) = self, index >= 0 && index < array.count else {
            return nil
        }
        return array[index]
    }
}

extension JSONValue: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValue...) {
        self = .array(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        var dict: [String: JSONValue] = [:]
        for (key, value) in elements {
            dict[key] = value
        }
        self = .dictionary(dict)
    }
}

extension JSONValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}
