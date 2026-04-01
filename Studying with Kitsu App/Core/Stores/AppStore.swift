import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    private let familyStore: FamilyStore
    private var cancellables = Set<AnyCancellable>()
    private var currentChildID: UUID?
    private var taskProgressDayIdentifier: DateComponents
    private var lastTaskCompletionDayIdentifier: DateComponents?

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
    @Published var totalTasksCompleted: Int {
        didSet {
            persistProgress()
        }
    }
    @Published var totalCoinsEarned: Int {
        didSet {
            persistProgress()
        }
    }
    @Published var totalCoinsSpent: Int {
        didSet {
            persistProgress()
        }
    }

    init(familyStore: FamilyStore) {
        self.familyStore = familyStore

        let snapshot = familyStore.activeChildID.flatMap {
            LocalPersistence.load(AppProgressSnapshot.self, forKey: LocalPersistenceKey.appProgress($0))
        } ?? .empty

        let initialDayIdentifier = snapshot.taskProgressDayIdentifier ?? Self.currentDayIdentifier()
        self.currentChildID = familyStore.activeChildID
        self.taskProgressDayIdentifier = initialDayIdentifier
        self.lastTaskCompletionDayIdentifier = snapshot.lastTaskCompletionDayIdentifier
        self.destination = snapshot.lastDestination
        self.earnedCoins = snapshot.earnedCoins
        self.completedTaskIDs = Set(snapshot.completedTaskIDs)
        self.currentStreak = snapshot.currentStreak
        self.totalTasksCompleted = snapshot.totalTasksCompleted
        self.totalCoinsEarned = snapshot.totalCoinsEarned
        self.totalCoinsSpent = snapshot.totalCoinsSpent
        ensureDailyTaskProgressIsCurrent()

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
            totalTasksCompleted: totalTasksCompleted,
            totalCoinsEarned: totalCoinsEarned,
            totalCoinsSpent: totalCoinsSpent,
            lastDestination: destination,
            taskProgressDayIdentifier: taskProgressDayIdentifier,
            lastTaskCompletionDayIdentifier: lastTaskCompletionDayIdentifier
        )
        LocalPersistence.save(snapshot, forKey: LocalPersistenceKey.appProgress(currentChildID))
    }

    private func reload(for childID: UUID?) {
        currentChildID = childID

        guard let childID else {
            taskProgressDayIdentifier = Self.currentDayIdentifier()
            lastTaskCompletionDayIdentifier = nil
            earnedCoins = 0
            completedTaskIDs = []
            currentStreak = 0
            totalTasksCompleted = 0
            totalCoinsEarned = 0
            totalCoinsSpent = 0
            destination = familyStore.hasChildren ? .childPicker : .welcome
            return
        }

        let snapshot = LocalPersistence.load(AppProgressSnapshot.self, forKey: LocalPersistenceKey.appProgress(childID)) ?? .empty
        taskProgressDayIdentifier = snapshot.taskProgressDayIdentifier ?? Self.currentDayIdentifier()
        lastTaskCompletionDayIdentifier = snapshot.lastTaskCompletionDayIdentifier
        earnedCoins = snapshot.earnedCoins
        completedTaskIDs = Set(snapshot.completedTaskIDs)
        currentStreak = snapshot.currentStreak
        totalTasksCompleted = snapshot.totalTasksCompleted
        totalCoinsEarned = snapshot.totalCoinsEarned
        totalCoinsSpent = snapshot.totalCoinsSpent
        ensureDailyTaskProgressIsCurrent()

        if destination != .onboarding && destination != .routineSetup {
            destination = .home
        }
    }

    func prepareLaunchDestination(hasChildren: Bool, hasActiveChild: Bool) {
        ensureDailyTaskProgressIsCurrent()
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

    func goToJourneyLogbook() {
        destination = .journeyLogbook
    }

    func goToWeeklyCheckpoint() {
        destination = .weeklyCheckpoint
    }

    func goToRewards() {
        destination = .rewards
    }

    func goToProgress() {
        destination = .progress
    }

    func completeTask(_ task: StudyTask) {
        ensureDailyTaskProgressIsCurrent()
        guard !completedTaskIDs.contains(task.id) else { return }
        registerTaskActivityForToday()
        completedTaskIDs.insert(task.id)
        earnedCoins += task.rewardCoins
        totalTasksCompleted += 1
        totalCoinsEarned += task.rewardCoins
    }

    func canRedeem(_ reward: RewardItem) -> Bool {
        earnedCoins >= reward.cost
    }

    func redeem(_ reward: RewardItem) {
        guard canRedeem(reward) else { return }
        earnedCoins -= reward.cost
        totalCoinsSpent += reward.cost
    }

    func syncEarnedCoins(_ coins: Int) {
        earnedCoins = max(0, coins)
    }

    func awardJourneyLogbookCoins(_ coins: Int) {
        guard coins > 0 else { return }
        earnedCoins += coins
        totalCoinsEarned += coins
    }

    func awardBonusCoins(_ coins: Int) {
        guard coins > 0 else { return }
        earnedCoins += coins
        totalCoinsEarned += coins
    }

    func markDailyRoutineCompleted() {
        ensureDailyTaskProgressIsCurrent()
        registerTaskActivityForToday()
    }

    func refreshDailyTaskStateIfNeeded() {
        ensureDailyTaskProgressIsCurrent()
    }

    private func ensureDailyTaskProgressIsCurrent() {
        let today = Self.currentDayIdentifier()
        if shouldResetStreakForMissedDays(relativeTo: today) {
            currentStreak = 0
        }
        guard taskProgressDayIdentifier != today else { return }
        taskProgressDayIdentifier = today
        completedTaskIDs = []
    }

    private func registerTaskActivityForToday(calendar: Calendar = .current, date: Date = Date()) {
        let today = Self.currentDayIdentifier(calendar: calendar, date: date)
        guard lastTaskCompletionDayIdentifier != today else { return }

        if let lastTaskCompletionDayIdentifier,
           let dayGap = Self.dayDistance(from: lastTaskCompletionDayIdentifier, to: today, calendar: calendar) {
            if dayGap == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        lastTaskCompletionDayIdentifier = today
    }

    private func shouldResetStreakForMissedDays(relativeTo today: DateComponents, calendar: Calendar = .current) -> Bool {
        guard currentStreak > 0, let lastTaskCompletionDayIdentifier else { return false }
        guard let dayGap = Self.dayDistance(from: lastTaskCompletionDayIdentifier, to: today, calendar: calendar) else {
            return false
        }
        return dayGap >= 2
    }

    private static func dayDistance(from start: DateComponents, to end: DateComponents, calendar: Calendar = .current) -> Int? {
        guard let startDate = calendar.date(from: start), let endDate = calendar.date(from: end) else { return nil }
        return calendar.dateComponents([.day], from: startDate, to: endDate).day
    }

    private static func currentDayIdentifier(calendar: Calendar = .current, date: Date = Date()) -> DateComponents {
        calendar.dateComponents([.year, .month, .day], from: date)
    }
}
