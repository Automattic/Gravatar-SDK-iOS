import Foundation
import GravatarUI

@propertyWrapper
struct StoredValue<T: UserDefaultsSerializable> {
    private let defaultValue: T
    private let userDefaults = UserDefaults.standard

    public let key: String

    public var wrappedValue: T {
        get {
            guard let storedValue = self.userDefaults.value(forKey: self.key) as? T.StoredValue else {
                return defaultValue
            }
            return T(storedValue: storedValue)!
        }
        set {
            self.userDefaults.set(newValue.storedValue, forKey: self.key)
        }
    }

    public init(keyName: String, defaultValue: T) {
        self.key = keyName
        self.defaultValue = defaultValue
        userDefaults.register(defaults: [keyName: defaultValue.storedValue])
    }
}

protocol UserDefaultsSerializable {
    associatedtype StoredValue

    var storedValue: StoredValue { get }

    init?(storedValue: StoredValue)
}

extension String: UserDefaultsSerializable {
    var storedValue: Self { self }

    init(storedValue: Self) {
        self = storedValue
    }
}

extension Int: UserDefaultsSerializable {
    var storedValue: Self { self }

    init(storedValue: Self) {
        self = storedValue
    }
}

extension UserDefaultsSerializable where Self: RawRepresentable, Self.RawValue: UserDefaultsSerializable {
    var storedValue: RawValue.StoredValue {
        self.rawValue.storedValue
    }

    init?(storedValue: RawValue.StoredValue) {
        guard
            let rawValue = Self.RawValue(storedValue: storedValue),
            let value = Self(rawValue: rawValue)
        else {
            fatalError("Found unexpected stored value: \(storedValue) for \(Self.self)")
        }
        self = value
    }
}

extension AboutInfoField: UserDefaultsSerializable {}
extension QEScope: UserDefaultsSerializable {}
extension AvatarPickerLayoutOptions: UserDefaultsSerializable {}
extension InitialPage: UserDefaultsSerializable {}
extension SheetPresentationStyleRepresentation: UserDefaultsSerializable {}
