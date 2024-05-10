import Foundation

public struct UserProfile: Hashable, Sendable {
    let profile: Components.Schemas.Profile
    
    public var hash: String {
        profile.hash
    }

    public var displayName: String? {
        profile.display_name
    }

    public var profileURLString: String {
        profile.profile_url
    }

    public var profileURL: URL? {
        URL(string: profileURLString)
    }

    public var avatarURLString: String {
        profile.avatar_url
    }

    public var avatarURL: URL? {
        URL(string: profile.avatar_url)
    }

    public var avatarAltText: String {
        profile.avatar_alt_text
    }

    public var location: String {
        profile.location
    }

    public var description: String {
        profile.description
    }

    public var jobTitle: String {
        profile.job_title
    }

    public var company: String {
        profile.company
    }

    public var pronunciation: String {
        profile.pronunciation
    }

    public var pronouns: String {
        profile.pronouns
    }

    public var numberVerifiedAccounts: Int? {
        profile.number_verified_accounts
    }

    public var lastProfileEdit: Date? {
        profile.last_profile_edit
    }

    public var registrationDate: String? {
        profile.registration_date
    }

    public var verifiedAccounts: [VerifiedAccount] {
        profile.verified_accounts.map(VerifiedAccount.init)
    }

    public var links: [Link]? {
        profile.links?.map(Link.init)
    }

    public var gallery: [GalleryImage]? {
        profile.gallery?.map(GalleryImage.init)
    }

    public var payments: Payment? {
        profile.payments.flatMap(Payment.init)
    }

    public var contactInfo: ContactInfo? {
        profile.contact_info.flatMap(ContactInfo.init)
    }
}


extension UserProfile {
    /// A link the user has added to their profile.
    ///
    public struct Link: Hashable, Sendable {
        let link: Components.Schemas.Link
        /// The label for the link.
        public var label: String {
            link.label
        }
        /// The URL string to the link.
        public var urlString: String {
            link.url
        }
        /// The URL to the link.
        public var url: URL? {
            URL(string: urlString)
        }

        init(link: Components.Schemas.Link) {
            self.link = link
        }
    }
    /// A crypto currency wallet address the user accepts.
    ///
    public struct CryptoWalletAddress: Hashable, Sendable {
        let wallet: Components.Schemas.CryptoWalletAddress
        /// The label for the crypto currency.
        ///
        public var label: String {
            wallet.label
        }
        /// The wallet address for the crypto currency.
        ///
        public var address: String {
            wallet.address
        }

        init(wallet: Components.Schemas.CryptoWalletAddress) {
            self.wallet = wallet
        }
    }
    /// A verified account on a user's profile.
    ///
    public struct VerifiedAccount: Hashable, Sendable {
        let account: Components.Schemas.VerifiedAccount

        /// The name of the service.
        ///
        public var service_label: String {
            account.service_label
        }
        /// The URL to the service's icon.
        ///
        public var service_icon: String {
            account.service_icon
        }
        /// The URL string to the user's profile on the service.
        ///
        public var urlString: String {
            account.url
        }
        /// The URL to the user's profile on the service.
        ///
        public var url: URL? {
            URL(string: account.url)
        }

        init(account: Components.Schemas.VerifiedAccount) {
            self.account = account
        }
    }
    /// A gallery image a user has uploaded.
    ///
    public struct GalleryImage: Hashable, Sendable {
        let gallery: Components.Schemas.GalleryImage
        /// The URL string to the image.
        ///
        public var urlString: String {
            gallery.url
        }
        /// The URL  to the image.
        ///
        public var url: URL? {
            URL(string: gallery.url)
        }

        init(gallery: Components.Schemas.GalleryImage) {
            self.gallery = gallery
        }
    }

    public struct Payment: Hashable, Sendable {
        let payment: Components.Schemas.Profile.paymentsPayload
        /// A list of payment URLs the user has added to their profile.
        ///
        public var links: [Link] {
            payment.links.map(Link.init)
        }
        /// A list of crypto currencies the user accepts.
        ///
        public var cryptoWallets: [CryptoWalletAddress] {
            payment.crypto_wallets.map(CryptoWalletAddress.init)
        }

        init(payment: Components.Schemas.Profile.paymentsPayload) {
            self.payment = payment
        }
    }

    public struct ContactInfo: Hashable, Sendable {
        let info: Components.Schemas.Profile.contact_infoPayload
        /// The user's home phone number.
        ///
        public var homePhone: String? {
            info.home_phone
        }
        /// The user's work phone number.
        ///
        public var workPhone: String? {
            info.work_phone
        }
        /// The user's cell phone number.
        ///
        public var cellPhone: String? {
            info.cell_phone
        }
        /// The user's email address as provided on the contact section of the profile. Might differ from their account emails.
        ///
        public var email: String? {
            info.email
        }
        /// The URL to the user's contact form.
        ///
        public var contactForm: String? {
            info.contact_form
        }
        /// The URL to the user's calendar.
        ///
        public var calendar: String? {
            info.calendar
        }
        init(info: Components.Schemas.Profile.contact_infoPayload) {
            self.info = info
        }
    }
}
