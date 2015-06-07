import Foundation

final class User {
    let name: String
    let email: String

    private let avatarSize  = 128
    private let gravatarUri = "http://www.gravatar.com/avatar/%@?s=%d"

    init(name: String, email: String) {
        self.name  = name
        self.email = email
    }

    func avatarUrl() -> String {
        return String(format: gravatarUri, self.email.md5(), avatarSize)
    }
}