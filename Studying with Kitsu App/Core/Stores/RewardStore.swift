import Foundation
import Combine

@MainActor
final class RewardStore: ObservableObject {
    private let familyStore: FamilyStore
    private var cancellables = Set<AnyCancellable>()
    private var currentChildID: UUID?

    @Published var rewards: [RewardItem] {
        didSet {
            persistRewards()
        }
    }

    init(familyStore: FamilyStore) {
        self.familyStore = familyStore
        self.currentChildID = familyStore.activeChildID
        self.rewards = familyStore.activeChildID.flatMap {
            LocalPersistence.load([RewardItem].self, forKey: LocalPersistenceKey.rewardItems($0))
        } ?? [
            RewardItem(title: "Choose dessert", cost: 24),
            RewardItem(title: "Family movie night", cost: 89),
            RewardItem(title: "Special weekend outing", cost: 201),
            RewardItem(title: "Family surprise", cost: 311)
        ]

        familyStore.$activeChildID
            .removeDuplicates()
            .sink { [weak self] childID in
                self?.reload(for: childID)
            }
            .store(in: &cancellables)
    }

    func makeLegacyTitles() -> RewardTitles {
        var titles = RewardTitles()
        if rewards.indices.contains(0) { titles.button1 = rewards[0].title }
        if rewards.indices.contains(1) { titles.button2 = rewards[1].title }
        if rewards.indices.contains(2) { titles.button3 = rewards[2].title }
        if rewards.indices.contains(3) { titles.button4 = rewards[3].title }
        return titles
    }

    func syncFromLegacyTitles(_ titles: RewardTitles) {
        guard rewards.count >= 4 else { return }
        rewards[0].title = titles.button1
        rewards[1].title = titles.button2
        rewards[2].title = titles.button3
        rewards[3].title = titles.button4
    }

    private func reload(for childID: UUID?) {
        currentChildID = childID
        guard let childID else {
            rewards = Self.defaultRewards
            return
        }
        rewards = LocalPersistence.load([RewardItem].self, forKey: LocalPersistenceKey.rewardItems(childID)) ?? Self.defaultRewards
    }

    private func persistRewards() {
        guard let currentChildID else { return }
        LocalPersistence.save(rewards, forKey: LocalPersistenceKey.rewardItems(currentChildID))
    }

    private static let defaultRewards: [RewardItem] = [
        RewardItem(title: "Choose dessert", cost: 24),
        RewardItem(title: "Family movie night", cost: 89),
        RewardItem(title: "Special weekend outing", cost: 201),
        RewardItem(title: "Family surprise", cost: 311)
    ]
}
