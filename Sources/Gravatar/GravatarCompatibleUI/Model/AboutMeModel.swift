import Foundation

public protocol AboutMeModel {
    var aboutMe: String? { get }
}

extension UserProfile: AboutMeModel {}
