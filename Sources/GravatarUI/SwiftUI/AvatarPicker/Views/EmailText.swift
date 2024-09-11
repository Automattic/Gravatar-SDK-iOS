import SwiftUI

struct EmailText: View {
    enum Constants {
        static let bottomSpacing: CGFloat = .DS.Padding.double
    }

    let email: Email?
    var body: some View {
        if let email = email?.rawValue, !email.isEmpty {
            Text(email)
                .padding(.bottom, Constants.bottomSpacing / 2)
                .font(.footnote)
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
    }
}
