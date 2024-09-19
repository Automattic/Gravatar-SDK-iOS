import Foundation

private enum Constant {
    static let maxPreferredLanguages = 6
}

protocol LanguagePreferenceProvider {
    var preferredLanguages: [String] { get }
    var maxPreferredLanguages: Int { get }
}

struct SystemLanguagePreferenceProvider: LanguagePreferenceProvider {
    let maxPreferredLanguages = Constant.maxPreferredLanguages
    var preferredLanguages: [String] {
        Locale.preferredLanguages
    }
}
