import Foundation

struct WeeklyCheckpointPlay: Identifiable, Equatable, Codable {
    let id: UUID
    let playedAt: Date
    let weekStartIdentifier: DateComponents
    let correctAnswers: Int
    let totalQuestions: Int
    let coinsAwarded: Int

    init(
        id: UUID = UUID(),
        playedAt: Date = Date(),
        calendar: Calendar = .current,
        correctAnswers: Int,
        totalQuestions: Int,
        coinsAwarded: Int
    ) {
        self.id = id
        self.playedAt = playedAt
        self.weekStartIdentifier = WeeklyCheckpointPlay.weekStartIdentifier(for: playedAt, calendar: calendar)
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
        self.coinsAwarded = coinsAwarded
    }

    static func weekStartIdentifier(for date: Date, calendar: Calendar = .current) -> DateComponents {
        let startOfDay = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: startOfDay)
        let daysFromSunday = weekday - 1
        let weekStart = calendar.date(byAdding: .day, value: -daysFromSunday, to: startOfDay) ?? startOfDay
        return calendar.dateComponents([.year, .month, .day], from: weekStart)
    }
}
