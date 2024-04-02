import Foundation

extension HTTPURLResponse {
    public static func successResponse(with url: URL? = URL(string: "https://gravatar.com")) -> HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    public static func errorResponse(with url: URL? = URL(string: "https://gravatar.com"), code: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}
