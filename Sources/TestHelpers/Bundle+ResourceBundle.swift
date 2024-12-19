import Foundation

#if !SWIFT_PACKAGE
private class BundleFinder: NSObject {}
#endif

extension Bundle {
    /// Returns the GravatarTests Bundle
    /// If installed via CocoaPods, this will be GravatarTestsResources.bundle,
    /// otherwise it will be the module bundle.
    ///
    class var testsBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let defaultBundle = Bundle(for: BundleFinder.self)
        // If installed with CocoaPods, resources will be in GravatarTestsResources.bundle
        if let bundleURL = defaultBundle.resourceURL,
           let resourceBundle = Bundle(url: bundleURL.appendingPathComponent("GravatarTestsResources.bundle"))
        {
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
        #endif
    }
}

extension Bundle {
    func jsonData(forResource resource: String) -> Data {
        let url = Bundle.testsBundle.url(forResource: resource, withExtension: "json")!
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("Could not load JSON file at \(url). \(error)")
        }
    }

    public static var fullProfileJsonData: Data {
        testsBundle.jsonData(forResource: "fullProfile")
    }

    public static var imageUploadJsonData: Data? {
        testsBundle.jsonData(forResource: "avatarUploadResponse")
    }

    public static var setRatingJsonData: Data {
        testsBundle.jsonData(forResource: "avatarSetRatingResponse")
    }

    public static var setAltTextJsonData: Data {
        testsBundle.jsonData(forResource: "avatarSetAltTextResponse")
    }

    public static var getAvatarsJsonData: Data {
        testsBundle.jsonData(forResource: "avatarsResponse")
    }

    public static var postAvatarSelectedJsonData: Data {
        testsBundle.jsonData(forResource: "avatarSelected")
    }

    public static var postAvatarUploadJsonData: Data {
        testsBundle.jsonData(forResource: "avatarSelected")
    }
}
