import Foundation

extension ProcessInfo {
    var osVersionDottedString: String {
        "\(operatingSystemVersion.majorVersion).\(operatingSystemVersion.minorVersion).\(operatingSystemVersion.patchVersion)"
    }
}
