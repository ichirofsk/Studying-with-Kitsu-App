import Foundation

struct AppProgressSnapshot: Equatable, Codable {
    var earnedCoins: Int
    var completedTaskIDs: [UUID]
    var currentStreak: Int
    var totalTasksCompleted: Int
    var totalCoinsEarned: Int
    var totalCoinsSpent: Int
    var lastDestination: AppDestination
    var taskProgressDayIdentifier: DateComponents?
    var lastTaskCompletionDayIdentifier: DateComponents?

    static let empty = AppProgressSnapshot(
        earnedCoins: 0,
        completedTaskIDs: [],
        currentStreak: 0,
        totalTasksCompleted: 0,
        totalCoinsEarned: 0,
        totalCoinsSpent: 0,
        lastDestination: .childPicker,
        taskProgressDayIdentifier: nil,
        lastTaskCompletionDayIdentifier: nil
    )

    private enum CodingKeys: String, CodingKey {
        case earnedCoins
        case completedTaskIDs
        case currentStreak
        case totalTasksCompleted
        case totalCoinsEarned
        case totalCoinsSpent
        case lastDestination
        case taskProgressDayIdentifier
        case lastTaskCompletionDayIdentifier
    }

    init(
        earnedCoins: Int,
        completedTaskIDs: [UUID],
        currentStreak: Int,
        totalTasksCompleted: Int,
        totalCoinsEarned: Int,
        totalCoinsSpent: Int,
        lastDestination: AppDestination,
        taskProgressDayIdentifier: DateComponents?,
        lastTaskCompletionDayIdentifier: DateComponents?
    ) {
        self.earnedCoins = earnedCoins
        self.completedTaskIDs = completedTaskIDs
        self.currentStreak = currentStreak
        self.totalTasksCompleted = totalTasksCompleted
        self.totalCoinsEarned = totalCoinsEarned
        self.totalCoinsSpent = totalCoinsSpent
        self.lastDestination = lastDestination
        self.taskProgressDayIdentifier = taskProgressDayIdentifier
        self.lastTaskCompletionDayIdentifier = lastTaskCompletionDayIdentifier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        earnedCoins = try container.decode(Int.self, forKey: .earnedCoins)
        completedTaskIDs = try container.decode([UUID].self, forKey: .completedTaskIDs)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        totalTasksCompleted = try container.decodeIfPresent(Int.self, forKey: .totalTasksCompleted) ?? 0
        totalCoinsEarned = try container.decodeIfPresent(Int.self, forKey: .totalCoinsEarned) ?? 0
        totalCoinsSpent = try container.decodeIfPresent(Int.self, forKey: .totalCoinsSpent) ?? 0
        lastDestination = try container.decode(AppDestination.self, forKey: .lastDestination)
        taskProgressDayIdentifier = try container.decodeIfPresent(DateComponents.self, forKey: .taskProgressDayIdentifier)
        lastTaskCompletionDayIdentifier = try container.decodeIfPresent(DateComponents.self, forKey: .lastTaskCompletionDayIdentifier)
    }
}
