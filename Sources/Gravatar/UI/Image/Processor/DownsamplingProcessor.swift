//
//  DownsamplingProcessor.swift
//
//
//  Created by Pinar Olguc on 22.01.2024.
//

import UIKit

/// Processor for downsamples  an image. It downsamples the input data directly to an
/// image.
///
/// Only CG-based images are supported. Animated images (like GIF) are not supported.
public struct DownsamplingProcessor: GravatarImageProcessor {

    /// Target size of output image should be. It should be smaller than the size of
    /// input image. If it is larger, there will be no downsampling. And the  result image
    /// will be the same size with the input data.
    public let size: CGSize

    public init(size: CGSize) {
        self.size = size
    }

    public func process(_ data: Data, options: GravatarDownloadOptions) -> UIImage? {
        return UIImage.downsampledImage(data: data, to: size, scale: options.scaleFactor)
    }
}
