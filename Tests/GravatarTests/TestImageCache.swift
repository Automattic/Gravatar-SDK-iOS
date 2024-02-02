//
//  File.swift
//  
//
//  Created by Pinar Olguc on 24.01.2024.
//

import Foundation
import Gravatar
import UIKit

class TestImageCache: GravatarImageCaching {
    var dict: [String: UIImage] = [:]
    var getImageCallCount = 0
    
    public func setImage(_ image: UIImage, forKey key: String) {
        dict[key] = image
    }

    public func getImage(forKey key: String) -> UIImage? {
        getImageCallCount += 1
        return dict[key]
    }
}