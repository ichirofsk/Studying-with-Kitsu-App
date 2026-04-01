import Foundation

struct RewardItem: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var cost: Int
    var symbolName: String?
    var imageData: Data?

    init(
        id: UUID = UUID(),
        title: String,
        cost: Int,
        symbolName: String? = nil,
        imageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.cost = cost
        self.symbolName = symbolName
        self.imageData = imageData
    }
}
