@testable import Gravatar

extension ImageDownloadService {
    static func mock(with session: URLSessionProtocol, cache: ImageCaching? = nil) -> ImageDownloadService {
        let client = URLSessionHTTPClient(urlSession: session)
        let service = ImageDownloadService(client: client, cache: cache)
        return service
    }
}
