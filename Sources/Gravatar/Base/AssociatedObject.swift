//
//  AssociatedObject.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation

func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    if #available(iOS 14, *) { // swift 5.3 fixed this issue (https://github.com/apple/swift/issues/46456)
        return objc_getAssociatedObject(object, key) as? T
    } else {
        return objc_getAssociatedObject(object, key) as AnyObject as? T
    }
}

func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}
