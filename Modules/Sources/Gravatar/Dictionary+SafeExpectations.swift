import Foundation

extension NSDictionary {
    func string(forKey key: String) -> String? {
        guard let value = self[key] else { return nil }

        if let stringValue = value as? String {
            return stringValue
        } else if let convertibleToString = self[key] {
            return String(describing: convertibleToString)
        } else {
            return nil
        }
    }
}
