import Foundation
import Combine

@MainActor
final class ParentSecurityStore: ObservableObject {
    @Published private(set) var hasConfiguredPIN: Bool
    @Published private(set) var isParentVerified = false

    init() {
        self.hasConfiguredPIN = UserDefaults.standard.string(forKey: LocalPersistenceKey.parentPIN) != nil
    }

    func configurePIN(_ pin: String) {
        guard pin.count == 4, pin.allSatisfy(\.isNumber) else { return }
        UserDefaults.standard.set(pin, forKey: LocalPersistenceKey.parentPIN)
        hasConfiguredPIN = true
        isParentVerified = true
    }

    @discardableResult
    func verifyPIN(_ pin: String) -> Bool {
        let storedPIN = UserDefaults.standard.string(forKey: LocalPersistenceKey.parentPIN)
        let isValid = storedPIN == pin
        isParentVerified = isValid
        return isValid
    }

    func clearVerification() {
        isParentVerified = false
    }
}
