import Foundation

struct ChildProfile: Equatable, Codable {
    var name: String
    var schoolStage: String
    var avatarImageData: Data?

    static let empty = ChildProfile(name: "", schoolStage: "Early learner", avatarImageData: nil)
}
