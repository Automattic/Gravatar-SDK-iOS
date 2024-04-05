import Foundation
import Gravatar

public protocol AboutMeModel {
    var aboutMe: String? { get }
}

extension UserProfile: AboutMeModel {}
