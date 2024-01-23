//
//  GravatarDownloadResult.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public typealias GravatarDownloadProgressBlock = ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)

/// Represents the result of a  Gravatar image download task.
public struct GravatarImageDownloadResult {
    /// Gets the image of this result.
    public let image: UIImage

    /// The `URL` which this result is related to.
    public let sourceURL: URL
}
