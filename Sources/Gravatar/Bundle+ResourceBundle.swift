import Foundation

#if !SWIFT_PACKAGE
private class BundleFinder: NSObject {}
extension Bundle {
    static var module: Bundle {
        let defaultBundle = Bundle(for: BundleFinder.self)
        // If installed with CocoaPods, resources will be in Gravatar.bundle
        // The name of the bundle "Gravatar.bundle" (without the .bundle file extension)
        // needs to match the key in the respective Gravatar.podspec:
        // `s.resource_bundles = { 'Gravatar' => ['Sources/Gravatar/Resources/*.plist'] }`
        if let bundleURL = defaultBundle.resourceURL,
           let resourceBundle = Bundle(url: bundleURL.appendingPathComponent("Gravatar.bundle"))
        {
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
    }
}
#endif
