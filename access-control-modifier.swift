#!/usr/bin/swift

import Foundation

let internalTypes: [String] = [
    "ModelError",
    "SetEmailAvatarRequest",
    "AssociatedResponse"
]

let packageTypes: [String] = [
    "Avatar",
    "AvatarRating",
    "UpdateAvatarRequest"
]

enum AccessControlError: Error {
    case wrongPath
}

let fileManager = FileManager.default
let openapiDirectoryURL = URL(string: "./Sources/Gravatar/OpenApi/Generated/")!

guard let filesEnumerator = fileManager.enumerator(at: openapiDirectoryURL, includingPropertiesForKeys: nil) else {
    throw AccessControlError.wrongPath
}

for case let fileURL as URL in filesEnumerator {
    let content = try String(contentsOf: fileURL, encoding: .utf8)
    print(fileURL.lastPathComponent)
    if internalTypes.map({ $0 + ".swift" }).contains(fileURL.lastPathComponent) {
        let modified = content
            .replacingOccurrences(of: "public struct", with: "internal struct")
            .replacingOccurrences(of: "public private(set)", with: "internal private(set)")
            .replacingOccurrences(of: "public func", with: "internal func")
            .replacingOccurrences(of: "public enum", with: "internal enum")
            .replacingOccurrences(of: "public init", with: "internal init")
        try modified.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    else if packageTypes.map({ $0 + ".swift" }).contains(fileURL.lastPathComponent) {
        let modified = content
            .replacingOccurrences(of: "public struct", with: "package struct")
            .replacingOccurrences(of: "public private(set)", with: "package private(set)")
            .replacingOccurrences(of: "public func", with: "package func")
            .replacingOccurrences(of: "public enum", with: "package enum")
            .replacingOccurrences(of: "public init", with: "package init")
            .replacingOccurrences(of: "init", with: "package init")
        try modified.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
