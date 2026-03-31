import Foundation

struct StudyTask: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var rewardCoins: Int
    var isDefault: Bool

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        rewardCoins: Int,
        isDefault: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.rewardCoins = rewardCoins
        self.isDefault = isDefault
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case detail
        case rewardCoins
        case isDefault
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? ""
        rewardCoins = try container.decodeIfPresent(Int.self, forKey: .rewardCoins) ?? 0
        isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(detail, forKey: .detail)
        try container.encode(rewardCoins, forKey: .rewardCoins)
        try container.encode(isDefault, forKey: .isDefault)
    }
}
