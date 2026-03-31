import Foundation

struct StudyRoutine: Equatable, Codable {
    var tasks: [StudyTask]
    var focusMinutesGoal: Int

    static let starter = StudyRoutine(
        tasks: [
            StudyTask(title: "Guided reading", detail: "10 minutes with support from the caregiver.", rewardCoins: 7, isDefault: true),
            StudyTask(title: "Homework or activity", detail: "Complete the main activity of the day.", rewardCoins: 7, isDefault: true),
            StudyTask(title: "Light review", detail: "Revisit the topic through a game or conversation.", rewardCoins: 7, isDefault: true)
        ],
        focusMinutesGoal: 30
    )
}
