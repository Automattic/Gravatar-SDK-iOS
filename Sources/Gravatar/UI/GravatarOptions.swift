//
//  File.swift
//  
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public enum ImageTransition {
    /// No animation transition.
    case none
    /// Fade in the loaded image in a given duration.
    case fade(TimeInterval)
}

public enum GravatarDownloadOption {
    // The value is used when converting the retrieved data to an image.
    // Default value is: UIScreen.main.scale. You may set values as `1.0`, `2.0`, `3.0`.
    case scaleFactor(CGFloat)

    // Gravatar Image Ratings. Defaults to: GravatarRatings.default.
    case gravatarRating(Rating)

    // Transition style to use when setting the new image downloaded. Default: .none
    case transition(ImageTransition)

    // Preferred size of the image that will be downloaded. If not provided, layoutIfNeeded() is called on the view to get its bounds properly.
    // You can pass the preferred size to avoid the layoutIfNeeded() call and get a performance benefit.
    case preferredSize(CGSize)

    // By setting this option, the current image will be removed and the placeholder will be shown while downloading the new image.
    case removeCurrentImageWhileLoading

    // Ignore the cached value and re-download the image
    case forceRefresh

    // Cancels the ongoing download in the view wrapper if a new download starts.
    case cancelOngoingDownload
    
    // Processor to apply to the downloaded image. If you want to
    // do some customizations on the the downloaded data while converting
    // it into an image this is the correct place.
    // If not set `DefaultImageProcessor will be used.
    case processor(GravatarImageProcessor)
}

// Parsed download options
public struct GravatarDownloadOptions {
    static let defaultSize: CGSize = .init(width: 80, height: 80)

    var scaleFactor: CGFloat = UIScreen.main.scale
    var gravatarRating: Rating = .default
    var transition: ImageTransition = .none
    var preferredSize: CGSize? = nil
    var removeCurrentImageWhileLoading = false
    var forceRefresh = false
    var shouldCancelOngoingDownload = false
    var processor: GravatarImageProcessor = DefaultImageProcessor()

    init(options: [GravatarDownloadOption]?) {
        guard let options = options else { return }
        for option in options {
            switch option {
            case .gravatarRating(let rating):
                gravatarRating = rating
            case .scaleFactor(let scale):
                scaleFactor = scale
            case .transition(let imageTransition):
                transition = imageTransition
            case .preferredSize(let size):
                preferredSize = size
            case .removeCurrentImageWhileLoading:
                removeCurrentImageWhileLoading = true
            case .forceRefresh:
                forceRefresh = true
            case .cancelOngoingDownload:
                shouldCancelOngoingDownload = true
            case .processor(let imageProcessor):
                processor = imageProcessor
            }
        }
    }
}
