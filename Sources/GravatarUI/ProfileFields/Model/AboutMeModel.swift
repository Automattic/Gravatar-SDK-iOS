import Foundation
import Gravatar

public protocol AboutMeModel {
    var description: String { get }
}

extension Profile: AboutMeModel { }
