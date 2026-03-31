import SwiftUI
import Foundation
import Combine

public class Unit8ViewModel: ObservableObject {
    @Published public var user: UserStore
    @Published public var titles = RewardTitles()
    @Published public var dialogPhase: Unit8DialogPhase = .introFirst(step: 0)
    
    @Published public var highlightEditButton2: Bool = false
    @Published public var highlightRedeemButton1: Bool = false
    
    @Published public var isEditingEnabled: Bool = false // only edit button2 enabled during guidance
    @Published public var areButtonsEnabled: Bool = false // reward taps enabled only when allowed
    
    public let price1 = 24
    public let price2 = 89
    public let price3 = 201
    public let price4 = 311
    
    public var canRedeem1: Bool {
        user.coins >= price1
    }
    
    public var currentDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEE, d MMM yyyy"
        return formatter.string(from: Date())
    }
    
    public init(user: UserStore) {
        self.user = user
    }
    
    public func tapBackground() {
        switch dialogPhase {
        case .introFirst(step: 0):
            dialogPhase = .introFirst(step: 1)
        case .introFirst(step: 1):
            dialogPhase = .introSecond
        case .introSecond:
            dialogPhase = .none
            isEditingEnabled = true
            areButtonsEnabled = false
            highlightEditButton2 = true
        case .postEdit(step: 0):
            dialogPhase = .postEdit(step: 1)
        case .postEdit(step: 1):
            dialogPhase = .none
            areButtonsEnabled = true
            isEditingEnabled = false
            highlightRedeemButton1 = true
        default:
            break
        }
    }
    
    public func beginEditButton2() -> Bool {
        guard isEditingEnabled else { return false }
        highlightEditButton2 = false
        return true
    }
    
    public func confirmEditButton2(newTitle: String) {
        let trimmed = String(newTitle.prefix(25))
        titles.button2 = trimmed
        dialogPhase = .postEdit(step: 0)
        isEditingEnabled = false
    }
    
    public func redeemButton1() -> Bool {
        guard canRedeem1 && areButtonsEnabled else { return false }
        user.coins -= price1
        return true
    }
    
    public func resetHighlights() {
        highlightEditButton2 = false
        highlightRedeemButton1 = false
    }
}
