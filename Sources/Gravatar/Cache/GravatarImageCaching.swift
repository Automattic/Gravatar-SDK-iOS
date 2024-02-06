//
//  File.swift
//  
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public protocol GravatarImageCaching {
    func setImage(_ image: UIImage, forKey key: String)
    func getImage(forKey key: String) -> UIImage?
}

public class GravatarImageCache: GravatarImageCaching {
    private let cache = NSCache<NSString, UIImage>()

    /// The default cache used by the image dowloader.
    public static var shared: GravatarImageCaching = GravatarImageCache()

    public init () { }
    
    public func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    public func getImage(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
}
