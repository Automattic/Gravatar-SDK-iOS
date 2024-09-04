import Foundation

/// Use this to express *intent* on your API that the string you are manipulating / returning is intended to already be localized
/// and its value to have been provided via a call to `NSLocalizedString` or `SDKLocalizedString`.
///
/// Semantically speaking, a method taking or returning a `LocalizedString` is signaling that you can display said UI string
/// to the end user, without the need to be treated as a key to be localized. The string is expected to already have been localized
/// at that point of the code, via a call to `NSLocalizedString`, `SDKLocalizedString` or similar upstream in the code.
///
/// - Note: Remember though that, as a `typealias`, this won't provide any compile-time guarantee.
typealias LocalizedString = String

/// Use this function instead of `NSLocalizedString` to reference localized strings **from the library module**.
///
/// You should use this `SDKLocalizedString` method in place of `NSLocalizedString` for all localized strings in the SDK.
/// This ensures that an app target that imports this module will perform localization lookup in the module, and not in the main app bundle,
/// which is the default when using `NSLocalizedStrings()` without specifying `bundle = .module`.
///
/// - Note:
///   Tooling: Be sure to pass this function's name as a custom routine when parsing the code to generate the main `.strings` file,
///   using `genstrings -s SDKLocalizedString`, so that this helper method is recognized. You will also have to
///   exclude this very file from being parsed by `genstrings`, so that it won't accidentally misinterpret that routine/function definition
///   below as a call site and generate an error because of it.
///
/// - Parameters:
///   - key: An identifying value used to reference a localized string.
///   - tableName: The basename of the `.strings` file **in the app bundle** containing
///     the localized values. If `tableName` is `nil`, the `Localizable` table is used.
///   - value: The English/default copy for the string. This is the user-visible string that the
///     translators will use as original to translate, and also the string returned when the localized string for
///     `key` cannot be found in the table. If `value` is `nil` or empty, `key` would be returned instead.
///   - comment: A note to the translator describing the context where the localized string is presented to the user.
///
/// - Returns: A localized version of the string designated by `key` in the table identified by `tableName`.
///   If the localized string for `key` cannot be found within the table, `value` is returned.
///   (However, `key` is returned instead when `value` is `nil` or the empty string).
func SDKLocalizedString(_ key: String, tableName: String? = nil, value: String? = nil, comment: String) -> LocalizedString {
    Bundle.module.localizedString(forKey: key, value: value, table: tableName)
}
