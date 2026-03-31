import Foundation

struct AppProgressSnapshot: Equatable, Codable {
    var earnedCoins: Int
    var completedTaskIDs: [UUID]
    var currentStreak: Int
    var lastDestination: AppDestination

    static let empty = AppProgressSnapshot(
        earnedCoins: 0,
        completedTaskIDs: [],
        currentStreak: 0,
        lastDestination: .childPicker
    )
}
