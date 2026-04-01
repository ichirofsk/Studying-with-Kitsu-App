import Foundation

struct JourneyLogEntry: Identifiable, Equatable, Codable {
    let id: UUID
    let createdAt: Date
    let dayIdentifier: DateComponents
    var text: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        calendar: Calendar = .current,
        text: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.dayIdentifier = calendar.dateComponents([.year, .month, .day], from: createdAt)
        self.text = text
    }
}
