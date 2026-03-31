import Foundation
import Combine

@MainActor
final class ChildProfileStore: ObservableObject {
    private let familyStore: FamilyStore
    private var cancellables = Set<AnyCancellable>()
    private var currentChildID: UUID?
    private var isReloadingProfile = false

    @Published var profile: ChildProfile {
        didSet {
            guard !isReloadingProfile else { return }
            persistProfile()
        }
    }

    init(familyStore: FamilyStore) {
        self.familyStore = familyStore
        self.currentChildID = familyStore.activeChildID
        self.profile = familyStore.activeChildID.flatMap {
            LocalPersistence.load(ChildProfile.self, forKey: LocalPersistenceKey.childProfile($0))
                ?? familyStore.childSummary(for: $0).map {
                    ChildProfile(
                        name: $0.name,
                        schoolStage: $0.schoolStage,
                        avatarImageData: $0.avatarImageData
                    )
                }
        } ?? .empty

        familyStore.$activeChildID
            .removeDuplicates()
            .sink { [weak self] childID in
                self?.reload(for: childID)
            }
            .store(in: &cancellables)
    }

    var hasMinimumInfo: Bool {
        !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func updateName(_ name: String) {
        profile.name = name
    }

    func updateSchoolStage(_ schoolStage: String) {
        profile.schoolStage = schoolStage
    }

    func updateAvatarData(_ avatarImageData: Data?) {
        profile.avatarImageData = avatarImageData
    }

    private func reload(for childID: UUID?) {
        currentChildID = childID
        isReloadingProfile = true
        defer { isReloadingProfile = false }

        guard let childID else {
            profile = .empty
            return
        }
        profile = LocalPersistence.load(ChildProfile.self, forKey: LocalPersistenceKey.childProfile(childID))
            ?? familyStore.childSummary(for: childID).map {
                ChildProfile(
                    name: $0.name,
                    schoolStage: $0.schoolStage,
                    avatarImageData: $0.avatarImageData
                )
            }
            ?? .empty
    }

    private func persistProfile() {
        guard let currentChildID else { return }
        LocalPersistence.save(profile, forKey: LocalPersistenceKey.childProfile(currentChildID))
        familyStore.syncActiveChild(profile: profile)
    }
}
