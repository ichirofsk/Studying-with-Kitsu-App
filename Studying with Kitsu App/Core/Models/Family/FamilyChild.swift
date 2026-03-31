import Foundation

struct FamilyChild: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var schoolStage: String
    var avatarImageData: Data?

    init(
        id: UUID = UUID(),
        name: String = "",
        schoolStage: String = ChildProfile.empty.schoolStage,
        avatarImageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.schoolStage = schoolStage
        self.avatarImageData = avatarImageData
    }
}
