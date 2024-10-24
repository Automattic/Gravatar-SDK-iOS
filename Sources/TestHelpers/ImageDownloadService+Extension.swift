import Gravatar

extension ImageDownloadService {
    package static func mock(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> ImageDownloadService {
        let service = ImageDownloadService(urlSession: session, cache: cache)
        return service
    }
}
