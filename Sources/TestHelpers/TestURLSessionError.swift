import Foundation

package class TestURLSessionError: NSError, @unchecked Sendable {
    let message: String

    package init(message: String) {
        self.message = message
        super.init(domain: NSURLErrorDomain, code: 1)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override package var localizedDescription: String {
        message
    }
}
