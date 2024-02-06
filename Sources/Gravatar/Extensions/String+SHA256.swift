//
//  String+SHA256.swift
//
//
//  Created by Andrew Montgomery on 1/11/24.
//

import CryptoKit

enum StringError: Error {
    case dataConvertionError
}

extension String {
    func sha256() throws -> String {
        guard let data = self.data(using: .utf8) else {
            throw StringError.dataConvertionError
        }

        let hashed = SHA256.hash(data: data)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
