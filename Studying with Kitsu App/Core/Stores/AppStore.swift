import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    private let familyStore: FamilyStore
    private var cancellables = Set<AnyCancellable>()
    private var currentChildID: UUID?

    @Published var destination: AppDestination {
        didSet {
            persistProgress()
        }
    }
    @Published var earnedCoins: Int {
        didSet {
            persistProgress()
        }
    }
    @Published var completedTaskIDs: Set<UUID> {
        didSet {
            persistProgress()
        }
    }
    @Published var currentStreak: Int {
        didSet {
            persistProgress()
        }
    }

    init(familyStore: FamilyStore) {
        self.familyStore = familyStore

        let snapshot = familyStore.activeChildID.flatMap {
            LocalPersistence.load(AppProgressSnapshot.self, forKey: LocalPersistenceKey.appProgress($0))
        } ?? .empty

        self.currentChildID = familyStore.activeChildID
        self.destination = snapshot.lastDestination
        self.earnedCoins = snapshot.earnedCoins
        self.completedTaskIDs = Set(snapshot.completedTaskIDs)
        self.currentStreak = snapshot.currentStreak

        familyStore.$activeChildID
            .removeDuplicates()
            .sink { [weak self] childID in
                self?.reload(for: childID)
            }
            .store(in: &cancellables)
    }

    private func persistProgress() {
        guard let currentChildID else { return }
        let snapshot = AppProgressSnapshot(
            earnedCoins: earnedCoins,
            completedTaskIDs: Array(completedTaskIDs),
            currentStreak: currentStreak,
            lastDestination: destination
        )
        LocalPersistence.save(snapshot, forKey: LocalPersistenceKey.appProgress(currentChildID))
    }

    private func reload(for childID: UUID?) {
        currentChildID = childID

        guard let childID else {
            earnedCoins = 0
            completedTaskIDs = []
            currentStreak = 0
            destination = familyStore.hasChildren ? .childPicker : .welcome
            return
        }

        let snapshot = LocalPersistence.load(AppProgressSnapshot.self, forKey: LocalPersistenceKey.appProgress(childID)) ?? .empty
        earnedCoins = snapshot.earnedCoins
        completedTaskIDs = Set(snapshot.completedTaskIDs)
        currentStreak = snapshot.currentStreak

        if destination != .onboarding && destination != .routineSetup {
            destination = .home
        }
    }

    func prepareLaunchDestination(hasChildren: Bool, hasActiveChild: Bool) {
        if !hasChildren {
            destination = .welcome
        } else if !hasActiveChild {
            destination = .childPicker
        } else if destination == .welcome {
            destination = .childPicker
        }
    }

    func goToChildPicker() {
        destination = .childPicker
    }

    func goToParentPinSetup() {
        destination = .parentPinSetup
    }

    func goToWelcome() {
        destination = .welcome
    }

    func goToOnboarding() {
        destination = .onboarding
    }

    func goToRoutineSetup() {
        destination = .routineSetup
    }

    func goToHome() {
        destination = .home
    }

    func goToDailyTasks() {
        destination = .dailyTasks
    }

    func goToRewards() {
        destination = .rewards
    }

    func goToProgress() {
        destination = .progress
    }

    func completeTask(_ task: StudyTask) {
        guard !completedTaskIDs.contains(task.id) else { return }
        completedTaskIDs.insert(task.id)
        earnedCoins += task.rewardCoins

        if completedTaskIDs.count == 3 {
            currentStreak = max(currentStreak, 1)
        }
    }

    func canRedeem(_ reward: RewardItem) -> Bool {
        earnedCoins >= reward.cost
    }

    func redeem(_ reward: RewardItem) {
        guard canRedeem(reward) else { return }
        earnedCoins -= reward.cost
    }

    func syncEarnedCoins(_ coins: Int) {
        earnedCoins = max(0, coins)
    }

    func markDailyRoutineCompleted() {
        currentStreak = max(currentStreak, 1)
    }
}
