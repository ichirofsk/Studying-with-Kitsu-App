import Foundation

enum LocalPersistenceKey {
    static let familySnapshot = "kitsu.familySnapshot"
    static let parentPIN = "kitsu.parentPIN"

    static func childProfile(_ childID: UUID) -> String {
        "kitsu.child.\(childID.uuidString).profile"
    }

    static func studyRoutine(_ childID: UUID) -> String {
        "kitsu.child.\(childID.uuidString).routine"
    }

    static func rewardItems(_ childID: UUID) -> String {
        "kitsu.child.\(childID.uuidString).rewards"
    }

    static func appProgress(_ childID: UUID) -> String {
        "kitsu.child.\(childID.uuidString).progress"
    }
}

enum LocalPersistence {
    static func load<Value: Decodable>(_ type: Value.Type, forKey key: String) -> Value? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    static func save<Value: Encodable>(_ value: Value, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func removeValue(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
