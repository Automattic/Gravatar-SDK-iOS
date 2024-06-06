import Foundation

extension Data {
    func decode<T: Decodable>(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        let result = try decoder.decode(T.self, from: self)
        return result
    }
}
