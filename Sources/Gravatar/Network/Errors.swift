import Foundation
import UIKit

public enum GravatarImageDownloadError: Error {
    
    public enum RequestErrorReason {
        
        /// The gravatar URL could not be initialized.
        case urlInitializationFailed
        
        /// URL in the given request is empty.
        case emptyURL
    }
    
    public enum ResponseErrorReason {

        /// An error occurred in the system URL session.
        case URLSessionError(error: Error)
        
        /// Could not initialize the image from the downloaded data.
        case imageInitializationFailed
        
        /// Avatar not found (404).
        case notFound
        
        /// URL of response doesn't match with the request (request is outdated).
        case urlMismatch
    }
    
    case requestError(reason: GravatarImageDownloadError.RequestErrorReason)
    case responseError(reason: GravatarImageDownloadError.ResponseErrorReason)
}

public enum UploadError: Error {
    case cannotConvertImageIntoData
}
