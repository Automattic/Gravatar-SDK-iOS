import Foundation

package enum BundleInfo {
    package static var sdkVersion: String? {
        getInfoValue(forKey: "CFBundleShortVersionString") as? String
    }

    /// The `CFBundleName`.
    ///
    /// This string may be localized.
    package static var appName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    /// The `CFBundleExecutable` name.
    package static var executableName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String
    }

    private static func getInfoValue(forKey key: String) -> Any? {
        // Access the SDKInfo.plist using Bundle.module
        guard let url = Bundle.module.url(forResource: "SDKInfo", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else {
            return nil
        }
        return plist[key]
    }
}
