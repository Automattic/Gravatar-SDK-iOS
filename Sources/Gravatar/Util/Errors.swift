//
//  File.swift
//  
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public enum GravatarRequestError {
    
    /// The url is empty. Code 1000.
    case emptyURL
    
    /// The request is empty. Code 1001.
    case emptyRequest
    
    /// The URL of request is invalid. Code 1002.
    /// - request: The request is tend to be sent but its URL is invalid.
    case invalidURL(request: URLRequest)
    
    /// The downloading task is cancelled by user. Code 1003.
    case taskCancelled
}

public enum GravatarImageSettingError {
    
    /// The input resource is empty or `nil`.
    case emptySource
    
    /// The resource task is finished, but it is not the one expected now. This usually happens when you set another
    /// resource on the view without cancelling the current on-going one. The previous setting task will fail with
    /// this `.notCurrentSourceTask` error when a result got, regardless of it being successful or not for that task.
    /// The result of this original task is contained in the associated value.
    /// - result: The `GravatarImageDownloadResult` if the source task is finished without problem. `nil` if an error
    ///           happens.
    /// - error: The `Error` if an issue happens during image setting task. `nil` if the task finishes without
    ///          problem.
    /// - source: The original source value of the task.
    case notCurrentSourceTask(result: GravatarImageDownloadResult?, error: Error?, source: URL)

}

public enum GravatarResponseError {
    
    /// The response is not a valid URL response. Code 2001.
    case invalidURLResponse(response: URLResponse)
    
    /// The response contains an invalid HTTP status code. Code 2002.
    /// - Note:
    ///   By default, status code 200..<400 is recognized as valid.
    case invalidHTTPStatusCode(response: HTTPURLResponse)
    
    /// An error happens in the system URL session. Code 2003.
    case URLSessionError(error: Error)
    
    /// Data modifying fails on returning a valid data. Code 2004.
    case dataModifyingFailed
    
    /// The task is done but no URL response found. Code 2005.
    case noURLResponse

    /// The task is cancelled.
    case cancelled
    
    /// Could not initialize the image from the downloaded data.
    case imageInitializationFailed
    
    /// URL of response doesn't match with the request (request is outdated)
    case urlMismatch
}

public enum GravatarError: Error {
    case requestError(reason: GravatarRequestError)
    case responseError(reason: GravatarResponseError)
    case imageSettingError(reason: GravatarImageSettingError)
}
