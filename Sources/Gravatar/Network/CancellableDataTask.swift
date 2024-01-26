import Foundation

/// Allows you to cancel the data task.
public protocol CancellableDataTask {
    func cancel()
    var taskIdentifier: Int { get }
}

extension URLSessionTask: CancellableDataTask { }
