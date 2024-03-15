import Foundation
import UIKit

public typealias ImageDownloadCompletion = (Result<ImageDownloadResult, ImageFetchingError>) -> Void

/// Represents a type which can be used by Gravatar to fetch images.
public protocol ImageDownloader {
    /// Fetches a Gravatar user profile image using the user account's email.
    /// - Parameters:
    ///   - email: The user account email
    ///   - options: The options needed to perform the download.
    ///   - completionHandler: A closure which is called when the task is completed.
    /// - Returns: The task of an image downloading process.
    func fetchImage(
        with email: String,
        options: ImageDownloadOptions,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask

    /// Fetches an image from the given `URL`.
    /// - Parameters:
    ///   - url: The URL from where to download the image.
    ///   - forceRefresh: Force the image to be downloaded, ignoring the cache.
    ///   - processingMethod: Method to use for processing the downloaded `Data`.
    ///   - completionHandler: A closure which is called when the task is completed.
    /// - Returns: The task of an image downloading process.
    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processingMethod: ImageProcessingMethod,
        completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask?

    /// Fetches a Gravatar user profile image using the user account's email, and delivers the image asynchronously.
    /// - Parameters:
    ///   - email: The user account email
    ///   - options: The options needed to perform the download.
    /// - Returns: An asynchronously-delivered Result type containing the image and its URL.
    func fetchImage(
        with email: String,
        options: ImageDownloadOptions
    ) async throws -> ImageDownloadResult

    /// Fetches an image from the given `URL`, and delivers the image asynchronously.
    /// - Parameters:
    ///   - url: The URL from where to download the image.
    ///   - forceRefresh: Force the image to be downloaded, ignoring the cache.
    ///   - processingMethod: Method to use for processing the downloaded `Data`.
    /// - Returns: An asynchronously-delivered Result type containing the image and its URL.
    func fetchImage(
        with url: URL,
        forceRefresh: Bool,
        processingMethod: ImageProcessingMethod
    ) async throws -> ImageDownloadResult
}
