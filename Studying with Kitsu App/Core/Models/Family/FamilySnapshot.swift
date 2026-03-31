import Foundation

struct FamilySnapshot: Equatable, Codable {
    var children: [FamilyChild]
    var activeChildID: UUID?

    static let empty = FamilySnapshot(children: [], activeChildID: nil)
}
