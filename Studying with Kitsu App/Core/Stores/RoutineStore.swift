import Foundation
import Combine

@MainActor
final class RoutineStore: ObservableObject {
    private let familyStore: FamilyStore
    private var cancellables = Set<AnyCancellable>()
    private var currentChildID: UUID?

    @Published var routine: StudyRoutine {
        didSet {
            persistRoutine()
        }
    }

    init(familyStore: FamilyStore) {
        self.familyStore = familyStore
        self.currentChildID = familyStore.activeChildID
        self.routine = Self.normalize(
            familyStore.activeChildID.flatMap {
                LocalPersistence.load(StudyRoutine.self, forKey: LocalPersistenceKey.studyRoutine($0))
            } ?? .starter
        )

        familyStore.$activeChildID
            .removeDuplicates()
            .sink { [weak self] childID in
                self?.reload(for: childID)
            }
            .store(in: &cancellables)
    }

    private func reload(for childID: UUID?) {
        currentChildID = childID
        guard let childID else {
            routine = .starter
            return
        }
        routine = Self.normalize(
            LocalPersistence.load(StudyRoutine.self, forKey: LocalPersistenceKey.studyRoutine(childID)) ?? .starter
        )
    }

    private func persistRoutine() {
        guard let currentChildID else { return }
        LocalPersistence.save(routine, forKey: LocalPersistenceKey.studyRoutine(currentChildID))
    }

    func addCustomTask(title: String, rewardCoins: Int) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        var updatedRoutine = routine
        updatedRoutine.tasks.append(
            StudyTask(
                title: trimmedTitle,
                detail: "",
                rewardCoins: max(0, rewardCoins),
                isDefault: false
            )
        )
        routine = updatedRoutine
    }

    func updateCustomTask(id: UUID, title: String, rewardCoins: Int) {
        guard let index = routine.tasks.firstIndex(where: { $0.id == id }) else { return }
        guard !routine.tasks[index].isDefault else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        var updatedRoutine = routine
        updatedRoutine.tasks[index].title = trimmedTitle
        updatedRoutine.tasks[index].rewardCoins = max(0, rewardCoins)
        routine = updatedRoutine
    }

    func removeCustomTask(id: UUID) {
        guard let index = routine.tasks.firstIndex(where: { $0.id == id }) else { return }
        guard !routine.tasks[index].isDefault else { return }

        var updatedRoutine = routine
        updatedRoutine.tasks.remove(at: index)
        routine = updatedRoutine
    }

    private static func normalize(_ routine: StudyRoutine) -> StudyRoutine {
        var normalizedRoutine = routine
        normalizedRoutine.focusMinutesGoal = max(10, normalizedRoutine.focusMinutesGoal)

        let defaultTaskSignatures = Set(
            StudyRoutine.starter.tasks.map {
                TaskSignature(title: $0.title, detail: $0.detail, rewardCoins: $0.rewardCoins)
            }
        )

        normalizedRoutine.tasks = routine.tasks.map { task in
            let signature = TaskSignature(title: task.title, detail: task.detail, rewardCoins: task.rewardCoins)
            let shouldBeDefault = task.isDefault || defaultTaskSignatures.contains(signature)

            return StudyTask(
                id: task.id,
                title: task.title,
                detail: task.detail,
                rewardCoins: max(0, task.rewardCoins),
                isDefault: shouldBeDefault
            )
        }

        if normalizedRoutine.tasks.isEmpty {
            normalizedRoutine.tasks = StudyRoutine.starter.tasks
        }

        return normalizedRoutine
    }
}

private struct TaskSignature: Hashable {
    let title: String
    let detail: String
    let rewardCoins: Int
}
