import Foundation

struct RewardItem: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var cost: Int

    init(id: UUID = UUID(), title: String, cost: Int) {
        self.id = id
        self.title = title
        self.cost = cost
    }
}
