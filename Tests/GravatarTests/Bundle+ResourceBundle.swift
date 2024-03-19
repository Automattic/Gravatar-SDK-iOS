import Foundation

#if !SWIFT_PACKAGE
private class BundleFinder: NSObject {}
#endif

extension Bundle {
    /// Returns the GravatarCore Bundle
    /// If installed via CocoaPods, this will be GravatarCoreTestsResources.bundle,
    /// otherwise it will be the module bundle.
    ///
    public class var testsBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let defaultBundle = Bundle(for: BundleFinder.self)
        // If installed with CocoaPods, resources will be in GravatarCoreTestsResources.bundle
        if let bundleURL = defaultBundle.resourceURL,
           let resourceBundle = Bundle(url: bundleURL.appendingPathComponent("GravatarCoreTestsResources.bundle"))
        {
            return resourceBundle
        }
        // Otherwise, the default bundle is used for resources
        return defaultBundle
        #endif
    }
}
