import Foundation

struct AppProgressSnapshot: Equatable, Codable {
    var earnedCoins: Int
    var completedTaskIDs: [UUID]
    var currentStreak: Int
    var lastDestination: AppDestination
    var taskProgressDayIdentifier: DateComponents?

    static let empty = AppProgressSnapshot(
        earnedCoins: 0,
        completedTaskIDs: [],
        currentStreak: 0,
        lastDestination: .childPicker,
        taskProgressDayIdentifier: nil
    )

    private enum CodingKeys: String, CodingKey {
        case earnedCoins
        case completedTaskIDs
        case currentStreak
        case lastDestination
        case taskProgressDayIdentifier
    }

    init(
        earnedCoins: Int,
        completedTaskIDs: [UUID],
        currentStreak: Int,
        lastDestination: AppDestination,
        taskProgressDayIdentifier: DateComponents?
    ) {
        self.earnedCoins = earnedCoins
        self.completedTaskIDs = completedTaskIDs
        self.currentStreak = currentStreak
        self.lastDestination = lastDestination
        self.taskProgressDayIdentifier = taskProgressDayIdentifier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        earnedCoins = try container.decode(Int.self, forKey: .earnedCoins)
        completedTaskIDs = try container.decode([UUID].self, forKey: .completedTaskIDs)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        lastDestination = try container.decode(AppDestination.self, forKey: .lastDestination)
        taskProgressDayIdentifier = try container.decodeIfPresent(DateComponents.self, forKey: .taskProgressDayIdentifier)
    }
}
