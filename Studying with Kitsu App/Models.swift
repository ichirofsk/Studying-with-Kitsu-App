import Foundation

// MARK: - User
/// Represents the player using the app. Performs daily tasks to earn coins
/// and can later redeem rewards (not modeled here).
public struct User {
    public var name: String
    public var coins: Int
    public var imageName: String

    public init(name: String, coins: Int = 0, imageName: String) {
        self.name = name
        self.coins = coins
        self.imageName = imageName
    }

    /// Adds coins to the user's balance.
    public mutating func addCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
    }
}

// MARK: - DailyTasks
/// Represents the state of the three fixed daily tasks for the current day.
/// - There are always exactly three tasks.
/// - Each task can be completed once per day.
/// - Completing a task grants a fixed coin reward.
/// - When all three tasks are completed on the same day, a fixed bonus is granted once.
/// - On a new day, all tasks reset to not completed and progress returns to zero.
public struct DailyTasks {
    // Note: The following booleans intentionally mirror the provided naming,
    // where "Disabled" means the corresponding task has been completed today
    // and therefore its button should be disabled in UI. This keeps the model
    // aligned with the original description while we avoid UI code here.
    public private(set) var isButton1Disabled: Bool
    public private(set) var isButton2Disabled: Bool
    public private(set) var isButton3Disabled: Bool

    /// Derived completion percentage for the current day: 0.0, 1/3, 2/3, or 1.0.
    /// This value is computed from the three booleans to avoid divergence.
    public var completionPercentile: Float {
        let completedCount = [isButton1Disabled, isButton2Disabled, isButton3Disabled].filter { $0 }.count
        return Float(completedCount) / 3.0
    }

    /// Fixed coin reward per task completion (same for all three tasks).
    public let perTaskCoinReward: Int

    /// Fixed bonus coin reward granted once when all three tasks are completed in the same day.
    public let fullCompletionBonusCoins: Int

    /// Tracks whether the full completion bonus has been granted for the current day.
    private var bonusGrantedThisDay: Bool

    /// The calendar day identifier for which this state is valid. When the day changes,
    /// tasks must be reset. We store only the date components (year, month, day) to detect rollovers.
    private var dayIdentifier: DateComponents

    public init(
        isButton1Disabled: Bool = false,
        isButton2Disabled: Bool = false,
        isButton3Disabled: Bool = false,
        perTaskCoinReward: Int = 1,
        fullCompletionBonusCoins: Int = 3,
        calendar: Calendar = .current,
        date: Date = Date()
    ) {
        self.isButton1Disabled = isButton1Disabled
        self.isButton2Disabled = isButton2Disabled
        self.isButton3Disabled = isButton3Disabled
        self.perTaskCoinReward = perTaskCoinReward
        self.fullCompletionBonusCoins = fullCompletionBonusCoins
        self.bonusGrantedThisDay = false
        self.dayIdentifier = calendar.dateComponents([.year, .month, .day], from: date)
    }

    // MARK: Daily lifecycle
    /// Resets all tasks for a new day and clears the bonus flag.
    public mutating func resetForNewDay(calendar: Calendar = .current, date: Date = Date()) {
        isButton1Disabled = false
        isButton2Disabled = false
        isButton3Disabled = false
        // completionPercentile derives from the flags, so it will be 0.0 after reset.
        bonusGrantedThisDay = false
        dayIdentifier = calendar.dateComponents([.year, .month, .day], from: date)
    }

    /// Ensures the state is for the provided date; if the day rolled over, it resets.
    public mutating func ensureCurrentDay(calendar: Calendar = .current, date: Date = Date()) {
        let current = calendar.dateComponents([.year, .month, .day], from: date)
        if current != dayIdentifier {
            resetForNewDay(calendar: calendar, date: date)
        }
    }

    // MARK: Task completion helpers
    /// Attempts to complete Task 1 for the given user. Awards per-task coins if the task was not yet completed today.
    /// Also checks and awards the full completion bonus once when all three tasks are done.
    public mutating func completeTask1(for user: inout User, calendar: Calendar = .current, date: Date = Date()) {
        ensureCurrentDay(calendar: calendar, date: date)
        guard !isButton1Disabled else { return } // already completed today
        isButton1Disabled = true
        user.addCoins(perTaskCoinReward)
        grantBonusIfFullCompletion(for: &user)
    }

    /// Attempts to complete Task 2 for the given user.
    public mutating func completeTask2(for user: inout User, calendar: Calendar = .current, date: Date = Date()) {
        ensureCurrentDay(calendar: calendar, date: date)
        guard !isButton2Disabled else { return }
        isButton2Disabled = true
        user.addCoins(perTaskCoinReward)
        grantBonusIfFullCompletion(for: &user)
    }

    /// Attempts to complete Task 3 for the given user.
    public mutating func completeTask3(for user: inout User, calendar: Calendar = .current, date: Date = Date()) {
        ensureCurrentDay(calendar: calendar, date: date)
        guard !isButton3Disabled else { return }
        isButton3Disabled = true
        user.addCoins(perTaskCoinReward)
        grantBonusIfFullCompletion(for: &user)
    }

    /// Grants the full completion bonus once when all three tasks are completed on the same day.
    private mutating func grantBonusIfFullCompletion(for user: inout User) {
        if !bonusGrantedThisDay && isButton1Disabled && isButton2Disabled && isButton3Disabled {
            user.addCoins(fullCompletionBonusCoins)
            bonusGrantedThisDay = true
        }
    }
}

// MARK: - Minigame1
/// Represents the state of Minigame 1 (blowing leaves to clear the path).
public struct Minigame1 {
    /// Number of leaves currently obstructing the path.
    public var qtdFolhas: Int

    /// Indicates whether the quantity of leaves is zero. Kept for compatibility with the provided name.
    /// Consider interpreting this as an alias for "isCompleted" (path cleared) in the domain.
    public var isQuantityLeafZero: Bool {
        return qtdFolhas <= 0
    }

    /// Indicates whether the microphone is currently being activated/used by the player.
    public var isMicrofoneBeingActivated: Bool

    public init(qtdFolhas: Int, isMicrofoneBeingActivated: Bool = false) {
        self.qtdFolhas = qtdFolhas
        self.isMicrofoneBeingActivated = isMicrofoneBeingActivated
    }

    /// Reduces leaves when wind/microphone input is detected. Non-negative lower bound.
    public mutating func disperseLeaves(by amount: Int) {
        guard amount > 0 else { return }
        qtdFolhas = max(0, qtdFolhas - amount)
    }
}
