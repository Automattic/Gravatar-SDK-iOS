//
//  GravatarImageProcessor.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

/// Processor to apply to the downloaded image data. 
public protocol GravatarImageProcessor {
    func process(_ data: Data, options: GravatarImageDownloadOptions) -> UIImage?
}
