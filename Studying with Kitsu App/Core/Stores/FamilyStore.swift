import Foundation
import Combine

@MainActor
final class FamilyStore: ObservableObject {
    @Published var pendingCreationChildID: UUID?

    @Published var children: [FamilyChild] {
        didSet {
            persist()
        }
    }

    @Published var activeChildID: UUID? {
        didSet {
            persist()
        }
    }

    init() {
        let snapshot = LocalPersistence.load(FamilySnapshot.self, forKey: LocalPersistenceKey.familySnapshot) ?? .empty
        let sanitizedChildren = Self.sanitizeChildren(snapshot.children)
        self.children = sanitizedChildren
        self.activeChildID = sanitizedChildren.contains(where: { $0.id == snapshot.activeChildID })
            ? snapshot.activeChildID
            : sanitizedChildren.first?.id
        persist()
    }

    var hasChildren: Bool {
        !children.isEmpty
    }

    var activeChild: FamilyChild? {
        guard let activeChildID else { return nil }
        return children.first(where: { $0.id == activeChildID })
    }

    func createChildDraft() -> UUID {
        if let pendingCreationChildID {
            activeChildID = pendingCreationChildID
            return pendingCreationChildID
        }

        let newChildID = UUID()
        activeChildID = newChildID
        pendingCreationChildID = newChildID
        return newChildID
    }

    func selectChild(_ childID: UUID) {
        guard children.contains(where: { $0.id == childID }) else { return }
        activeChildID = childID
    }

    func syncActiveChild(profile: ChildProfile) {
        guard let activeChildID else { return }

        if let index = children.firstIndex(where: { $0.id == activeChildID }) {
            children[index].name = profile.name
            children[index].schoolStage = profile.schoolStage
            children[index].avatarImageData = profile.avatarImageData
        } else {
            children.append(
                FamilyChild(
                    id: activeChildID,
                    name: profile.name,
                    schoolStage: profile.schoolStage,
                    avatarImageData: profile.avatarImageData
                )
            )
        }

        children = Self.sanitizeChildren(children)
    }

    func finalizePendingCreation() {
        pendingCreationChildID = nil
    }

    func removeChild(_ childID: UUID) {
        children.removeAll(where: { $0.id == childID })

        LocalPersistence.removeValue(forKey: LocalPersistenceKey.childProfile(childID))
        LocalPersistence.removeValue(forKey: LocalPersistenceKey.studyRoutine(childID))
        LocalPersistence.removeValue(forKey: LocalPersistenceKey.rewardItems(childID))
        LocalPersistence.removeValue(forKey: LocalPersistenceKey.appProgress(childID))
        LocalPersistence.removeValue(forKey: LocalPersistenceKey.journeyLogbook(childID))
        LocalPersistence.removeValue(forKey: LocalPersistenceKey.weeklyCheckpoint(childID))

        if activeChildID == childID {
            activeChildID = children.first?.id
        }

        children = Self.sanitizeChildren(children)
    }

    func profileSnapshot(for childID: UUID) -> ChildProfile {
        LocalPersistence.load(ChildProfile.self, forKey: LocalPersistenceKey.childProfile(childID)) ?? .empty
    }

    func childSummary(for childID: UUID) -> FamilyChild? {
        children.first(where: { $0.id == childID })
    }

    func progressSnapshot(for childID: UUID) -> AppProgressSnapshot {
        LocalPersistence.load(AppProgressSnapshot.self, forKey: LocalPersistenceKey.appProgress(childID)) ?? .empty
    }

    private func persist() {
        LocalPersistence.save(
            FamilySnapshot(children: Self.sanitizeChildren(children), activeChildID: activeChildID),
            forKey: LocalPersistenceKey.familySnapshot
        )
    }

    private static func sanitizeChildren(_ children: [FamilyChild]) -> [FamilyChild] {
        var uniqueByID: [UUID: FamilyChild] = [:]
        var orderedIDs: [UUID] = []

        for child in children {
            if uniqueByID[child.id] == nil {
                orderedIDs.append(child.id)
                uniqueByID[child.id] = child
            } else {
                uniqueByID[child.id] = merge(existing: uniqueByID[child.id]!, incoming: child)
            }
        }

        var draftCount = 0

        return orderedIDs.compactMap { id in
            guard let child = uniqueByID[id] else { return nil }
            let isEmptyDraft = child.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if isEmptyDraft {
                draftCount += 1
                return draftCount == 1 ? child : nil
            }
            return child
        }
    }

    private static func merge(existing: FamilyChild, incoming: FamilyChild) -> FamilyChild {
        FamilyChild(
            id: existing.id,
            name: incoming.name.isEmpty ? existing.name : incoming.name,
            schoolStage: incoming.schoolStage == ChildProfile.empty.schoolStage ? existing.schoolStage : incoming.schoolStage,
            avatarImageData: incoming.avatarImageData ?? existing.avatarImageData
        )
    }
}
