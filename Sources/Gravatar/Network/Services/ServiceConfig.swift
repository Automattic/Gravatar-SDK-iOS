import Foundation

enum APIConfig {
    private static let baseURLString = "https://api.gravatar.com/"
    static let baseURL = URL(string: baseURLString)!
    static let baseURLComponents = URLComponents(string: baseURLString)!
}
