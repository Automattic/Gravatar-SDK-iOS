import Foundation
import SwiftUI

extension String {
    var localized: LocalizedStringKey {
        LocalizedStringKey(self)
    }
}
