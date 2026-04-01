import Foundation
import Combine

@MainActor
final class JourneyLogbookStore: ObservableObject {
    private let familyStore: FamilyStore
    private var cancellables = Set<AnyCancellable>()
    private var currentChildID: UUID?

    @Published var entries: [JourneyLogEntry] {
        didSet {
            persistEntries()
        }
    }

    init(familyStore: FamilyStore) {
        self.familyStore = familyStore
        self.currentChildID = familyStore.activeChildID
        self.entries = familyStore.activeChildID.flatMap {
            LocalPersistence.load([JourneyLogEntry].self, forKey: LocalPersistenceKey.journeyLogbook($0))
        } ?? []

        familyStore.$activeChildID
            .removeDuplicates()
            .sink { [weak self] childID in
                self?.reload(for: childID)
            }
            .store(in: &cancellables)
    }

    func canAddEntryToday(calendar: Calendar = .current, date: Date = Date()) -> Bool {
        entryForToday(calendar: calendar, date: date) == nil
    }

    func entryForToday(calendar: Calendar = .current, date: Date = Date()) -> JourneyLogEntry? {
        let today = calendar.dateComponents([.year, .month, .day], from: date)
        return entries.first(where: { $0.dayIdentifier == today })
    }

    @discardableResult
    func addTodayEntry(_ text: String, calendar: Calendar = .current, date: Date = Date()) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard canAddEntryToday(calendar: calendar, date: date) else { return false }
        entries.insert(JourneyLogEntry(createdAt: date, calendar: calendar, text: trimmed), at: 0)
        return true
    }

    private func reload(for childID: UUID?) {
        currentChildID = childID
        guard let childID else {
            entries = []
            return
        }
        entries = LocalPersistence.load([JourneyLogEntry].self, forKey: LocalPersistenceKey.journeyLogbook(childID)) ?? []
    }

    private func persistEntries() {
        guard let currentChildID else { return }
        LocalPersistence.save(entries, forKey: LocalPersistenceKey.journeyLogbook(currentChildID))
    }
}
