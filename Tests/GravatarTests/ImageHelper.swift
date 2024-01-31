//
//  File.swift
//  
//
//  Created by Pinar Olguc on 24.01.2024.
//

import UIKit

class ImageHelper {
    
    static let testResourcesDir = "Gravatar_Gravatar-Tests.bundle/ResourceFiles/"
    
    static var testImage: UIImage {
        return image(named: "test", type: "png")!
    }
    
    static var testImageData: Data {
        return dataFromImage(named: "test", type: "png")!
    }
    
    static func dataFromImage(named: String, type: String) -> Data? {
        let bundle = Bundle(for: ImageHelper.self)
        guard let url = Bundle.module.url(forResource: named, withExtension: type) else {
            return nil
        }
        var data: Data? = nil
        do {
            data = try Data(contentsOf: url)
        } catch {}
        return data
    }
    
    static func image(named: String, type: String) -> UIImage? {
        guard let path = Bundle.module.path(forResource: named, ofType: type) else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}
