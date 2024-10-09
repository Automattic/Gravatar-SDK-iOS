import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(AnyCodable)
import AnyCodable
#endif

extension Bool: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension Float: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension Int: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension Int32: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension Int64: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension Double: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension Decimal: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension String: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension URL: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension UUID: JSONEncodable {
    func encodeToJSON() -> Any { self }
}

extension RawRepresentable where RawValue: JSONEncodable {
    func encodeToJSON() -> Any { self.rawValue }
}

private func encodeIfPossible(_ object: some Any) -> Any {
    if let encodableObject = object as? JSONEncodable {
        encodableObject.encodeToJSON()
    } else {
        object
    }
}

extension Array: JSONEncodable {
    func encodeToJSON() -> Any {
        self.map(encodeIfPossible)
    }
}

extension Set: JSONEncodable {
    func encodeToJSON() -> Any {
        Array(self).encodeToJSON()
    }
}

extension Dictionary: JSONEncodable {
    func encodeToJSON() -> Any {
        var dictionary = [AnyHashable: Any]()
        for (key, value) in self {
            dictionary[key] = encodeIfPossible(value)
        }
        return dictionary
    }
}

extension Data: JSONEncodable {
    func encodeToJSON() -> Any {
        self.base64EncodedString(options: Data.Base64EncodingOptions())
    }
}

extension Date: JSONEncodable {
    func encodeToJSON() -> Any {
        CodableHelper.dateFormatter.string(from: self)
    }
}

extension JSONEncodable where Self: Encodable {
    func encodeToJSON() -> Any {
        guard let data = try? CodableHelper.jsonEncoder.encode(self) else {
            fatalError("Could not encode to json: \(self)")
        }
        return data.encodeToJSON()
    }
}

extension String: CodingKey {
    public var stringValue: String {
        self
    }

    public init?(stringValue: String) {
        self.init(stringLiteral: stringValue)
    }

    public var intValue: Int? {
        nil
    }

    public init?(intValue: Int) {
        nil
    }
}

extension KeyedEncodingContainerProtocol {
    public mutating func encodeArray(_ values: [some Encodable], forKey key: Self.Key) throws {
        var arrayContainer = nestedUnkeyedContainer(forKey: key)
        try arrayContainer.encode(contentsOf: values)
    }

    public mutating func encodeArrayIfPresent(_ values: [some Encodable]?, forKey key: Self.Key) throws {
        if let values {
            try encodeArray(values, forKey: key)
        }
    }

    public mutating func encodeMap(_ pairs: [Self.Key: some Encodable]) throws {
        for (key, value) in pairs {
            try encode(value, forKey: key)
        }
    }

    public mutating func encodeMapIfPresent(_ pairs: [Self.Key: some Encodable]?) throws {
        if let pairs {
            try encodeMap(pairs)
        }
    }

    public mutating func encode(_ value: Decimal, forKey key: Self.Key) throws {
        var mutableValue = value
        let stringValue = NSDecimalString(&mutableValue, Locale(identifier: "en_US"))
        try encode(stringValue, forKey: key)
    }

    public mutating func encodeIfPresent(_ value: Decimal?, forKey key: Self.Key) throws {
        if let value {
            try encode(value, forKey: key)
        }
    }
}

extension KeyedDecodingContainerProtocol {
    public func decodeArray<T>(_ type: T.Type, forKey key: Self.Key) throws -> [T] where T: Decodable {
        var tmpArray = [T]()

        var nestedContainer = try nestedUnkeyedContainer(forKey: key)
        while !nestedContainer.isAtEnd {
            let arrayValue = try nestedContainer.decode(T.self)
            tmpArray.append(arrayValue)
        }

        return tmpArray
    }

    public func decodeArrayIfPresent<T>(_ type: T.Type, forKey key: Self.Key) throws -> [T]? where T: Decodable {
        var tmpArray: [T]?

        if contains(key) {
            tmpArray = try decodeArray(T.self, forKey: key)
        }

        return tmpArray
    }

    public func decodeMap<T>(_ type: T.Type, excludedKeys: Set<Self.Key>) throws -> [Self.Key: T] where T: Decodable {
        var map: [Self.Key: T] = [:]

        for key in allKeys {
            if !excludedKeys.contains(key) {
                let value = try decode(T.self, forKey: key)
                map[key] = value
            }
        }

        return map
    }

    public func decode(_ type: Decimal.Type, forKey key: Self.Key) throws -> Decimal {
        let stringValue = try decode(String.self, forKey: key)
        guard let decimalValue = Decimal(string: stringValue) else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "The key \(key) couldn't be converted to a Decimal value")
            throw DecodingError.typeMismatch(type, context)
        }

        return decimalValue
    }

    public func decodeIfPresent(_ type: Decimal.Type, forKey key: Self.Key) throws -> Decimal? {
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let decimalValue = Decimal(string: stringValue) else {
            let context = DecodingError.Context(codingPath: [key], debugDescription: "The key \(key) couldn't be converted to a Decimal value")
            throw DecodingError.typeMismatch(type, context)
        }

        return decimalValue
    }
}

extension HTTPURLResponse {
    var isStatusCodeSuccessful: Bool {
        Configuration.successfulStatusCodeRange.contains(statusCode)
    }
}
