//
//  File.swift
//  
//
//  Created by Pinar Olguc on 24.01.2024.
//

import UIKit

class ImageHelper {
    
    static var testImage: UIImage {
        return image(named: "test", type: "png")!
    }
    
    static var testImageData: Data {
        return dataFromImage(named: "test", type: "png")!
    }
    
    static func dataFromImage(named: String, type: String) -> Data? {
        let bundle = Bundle(for: ImageHelper.self)
        guard let url = bundle.url(forResource: named, withExtension: type, subdirectory: "Gravatar_Gravatar-Tests.bundle/ResourceFiles/") else {
            return nil
        }
        var data: Data? = nil
        do {
            data = try Data(contentsOf: url)
        } catch {}
        return data
    }
    
    static func image(named: String, type: String) -> UIImage? {
        let bundle = Bundle(for: ImageHelper.self)
        guard let path = bundle.path(forResource: named, ofType: type, inDirectory: "Gravatar_Gravatar-Tests.bundle/ResourceFiles/") else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}
