import Foundation

enum ServiceConfig {
    private static let v3BaseURLString = "https://api.gravatar.com/v3/"
    static let v3BaseURL = URL(string: v3BaseURLString)!
    static let v3BaseURLComponents = URLComponents(string: v3BaseURLString)!
}
