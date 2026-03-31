import Foundation
import Combine
import SwiftUI

/// ViewModel for Logical Unit 4 managing dialog phases and user interactions.
@MainActor
public final class Unit4ViewModel: ObservableObject {
    
    /// Represents the current phase of Unit 4.
    @Published public private(set) var phase: Unit4Phase = .dialog(index: 0)
    
    /// Flag indicating whether audio is muted.
    @Published public var isMuted: Bool = false
    
    /// Flag indicating readiness to advance after specific user action.
    @Published public private(set) var readyToAdvance: Bool = false
    
    /// The current dialog based on the phase index.
    public var currentDialog: Unit4Dialog {
        let index = currentIndex
        let dialogs = Unit4Content.dialogs
        let clampedIndex = min(max(0, index), dialogs.count - 1)
        return dialogs[clampedIndex]
    }
    
    /// Whether the current dialog is the first one.
    public var isFirstDialog: Bool {
        currentIndex == 0
    }
    
    /// Whether the current dialog is the second one.
    public var isSecondDialog: Bool {
        currentIndex == 1
    }
    
    /// Whether the current dialog is the last one.
    public var isLastDialog: Bool {
        currentIndex == maxIndex
    }
    
    // MARK: - Public Methods
    
    /// Handles tap anywhere gesture, advancing only if currently on the first dialog.
    public func handleTapAnywhere() {
        guard isFirstDialog else { return }
        advance()
    }
    
    /// Handles tap on "Of Course" button, advancing from second to third dialog.
    public func tapOfCourse() {
        guard isSecondDialog else { return }
        advance()
    }
    
    /// Handles tap on "Please Lead Us" button, marks readiness to advance.
    public func tapPleaseLeadUs() {
        readyToAdvance = true
    }
    
    // MARK: - Private Helpers
    
    private var currentIndex: Int {
        switch phase {
        case .dialog(let index):
            return index
        }
    }
    
    private var maxIndex: Int {
        Unit4Content.dialogs.count - 1
    }
    
    /// Advances the phase to the next dialog safely, never beyond the last dialog.
    private func advance() {
        let nextIndex = min(currentIndex + 1, maxIndex)
        phase = .dialog(index: nextIndex)
    }
}
