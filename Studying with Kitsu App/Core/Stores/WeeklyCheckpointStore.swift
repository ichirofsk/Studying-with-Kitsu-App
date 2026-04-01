import Foundation
import Combine

@MainActor
final class WeeklyCheckpointStore: ObservableObject {
    private let familyStore: FamilyStore
    private var cancellables = Set<AnyCancellable>()
    private var currentChildID: UUID?

    @Published var plays: [WeeklyCheckpointPlay] {
        didSet {
            persistPlays()
        }
    }

    init(familyStore: FamilyStore) {
        self.familyStore = familyStore
        self.currentChildID = familyStore.activeChildID
        self.plays = familyStore.activeChildID.flatMap {
            LocalPersistence.load([WeeklyCheckpointPlay].self, forKey: LocalPersistenceKey.weeklyCheckpoint($0))
        } ?? []

        familyStore.$activeChildID
            .removeDuplicates()
            .sink { [weak self] childID in
                self?.reload(for: childID)
            }
            .store(in: &cancellables)
    }

    func canPlayThisWeek(calendar: Calendar = .current, date: Date = Date()) -> Bool {
        playForCurrentWeek(calendar: calendar, date: date) == nil
    }

    func playForCurrentWeek(calendar: Calendar = .current, date: Date = Date()) -> WeeklyCheckpointPlay? {
        let weekStart = WeeklyCheckpointPlay.weekStartIdentifier(for: date, calendar: calendar)
        return plays.first(where: { $0.weekStartIdentifier == weekStart })
    }

    func recordPlay(correctAnswers: Int, totalQuestions: Int, coinsAwarded: Int, calendar: Calendar = .current, date: Date = Date()) {
        guard canPlayThisWeek(calendar: calendar, date: date) else { return }
        plays.insert(
            WeeklyCheckpointPlay(
                playedAt: date,
                calendar: calendar,
                correctAnswers: correctAnswers,
                totalQuestions: totalQuestions,
                coinsAwarded: coinsAwarded
            ),
            at: 0
        )
    }

    func nextUnlockDate(from date: Date = Date(), calendar: Calendar = .current) -> Date {
        let currentWeekStart = WeeklyCheckpointPlay.weekStartIdentifier(for: date, calendar: calendar)
        let startDate = calendar.date(from: currentWeekStart) ?? calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 7, to: startDate) ?? startDate
    }

    private func reload(for childID: UUID?) {
        currentChildID = childID
        guard let childID else {
            plays = []
            return
        }
        plays = LocalPersistence.load([WeeklyCheckpointPlay].self, forKey: LocalPersistenceKey.weeklyCheckpoint(childID)) ?? []
    }

    private func persistPlays() {
        guard let currentChildID else { return }
        LocalPersistence.save(plays, forKey: LocalPersistenceKey.weeklyCheckpoint(currentChildID))
    }
}
