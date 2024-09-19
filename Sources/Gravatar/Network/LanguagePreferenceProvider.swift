import Foundation

protocol LanguagePreferenceProvider {
    var preferredLanguages: [String] { get }
    var maxPreferredLanguages: Int { get }
}

struct SystemLanguagePreferenceProvider: LanguagePreferenceProvider {
    var maxPreferredLanguages = 6
    var preferredLanguages: [String] {
        Locale.preferredLanguages
    }
}
