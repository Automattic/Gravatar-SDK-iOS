//
//  DefaultImageProcessor.swift
//
//
//  Created by Pinar Olguc on 22.01.2024.
//

import UIKit

/// The default processor. It applies the scale factor on the given image data and converts it into an image.
/// Images of .PNG, .JPEG  format are supported.
public struct DefaultImageProcessor: GravatarImageProcessor {

    public func process(_ data: Data, options: GravatarDownloadOptions) -> UIImage? {
        return UIImage(data: data, scale: options.scaleFactor)
    }
}
