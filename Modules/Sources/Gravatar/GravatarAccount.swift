import Foundation

public enum GravatarAccountError: Error {
    case invalidAccountInfo
}

extension GravatarAccountError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .invalidAccountInfo:
            return "Invalid Account info"
        }
    }
}

public struct GravatarAccount {
    let email: String
    let authToken: String
}

public enum GravatarValidatedAccount {
    case valid(GravatarAccount)
    case invalid(GravatarAccountError)

    public static func account(email: String?, authToken: String?) -> GravatarValidatedAccount {
        guard let email = email, !email.isEmpty,
              let authToken = authToken, !authToken.isEmpty else {
            return .invalid(.invalidAccountInfo)
        }

        let preparedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        return .valid(GravatarAccount(email: preparedEmail, authToken: authToken))
    }
}
