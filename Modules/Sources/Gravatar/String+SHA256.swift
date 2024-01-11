//
//  String+SHA256.swift
//
//
//  Created by Andrew Montgomery on 1/11/24.
//

import CryptoKit

extension String {
    func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return "" }

        let hashed = SHA256.hash(data: data)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
