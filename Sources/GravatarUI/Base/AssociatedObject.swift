import Foundation

func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    if #available(iOS 14, *) { // swift 5.3 fixed this issue (https://github.com/apple/swift/issues/46456)
        objc_getAssociatedObject(object, key) as? T
    } else {
        objc_getAssociatedObject(object, key) as AnyObject as? T
    }
}

func setRetainedAssociatedObject(_ object: Any, _ key: UnsafeRawPointer, _ value: some Any) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}
