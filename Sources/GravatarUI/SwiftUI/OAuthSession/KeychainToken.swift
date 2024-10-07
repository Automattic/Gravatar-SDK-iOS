import Foundation

struct KeychainToken: Codable {
    let token: String
    var isExpired: Bool = false

    init?(data: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedToken = try decoder.decode(KeychainToken.self, from: data)
            self = decodedToken
        } catch {
            return nil
        }
    }

    init(token: String) {
        self.token = token
    }

    var toData: Data? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            return nil
        }
    }
}
