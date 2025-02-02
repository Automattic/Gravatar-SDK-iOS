import Foundation

// "remote_image": { "url": "...", "width": 626, "height": 626 }
struct RemoteImage: Decodable, Hashable {
    let url: String
    let width: Int
    let height: Int
}
