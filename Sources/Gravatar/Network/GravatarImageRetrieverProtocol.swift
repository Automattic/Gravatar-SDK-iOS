import Foundation

/// Protocol for dependency injection purposes.
public protocol GravatarImageRetrieverProtocol {
    
    func retrieveImage(
      with url: URL,
      forceRefresh: Bool,
      processor: GravatarImageProcessor,
      completionHandler: ImageDownloadCompletion?
    ) -> CancellableDataTask?
}
