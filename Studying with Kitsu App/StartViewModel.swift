import Foundation
import Combine

/// Represents the high-level app units. For now, we only care about the initial unit
/// and the intent to move to the next one (whose UI is not implemented yet).
public enum AppUnit: Equatable {
    case start
    case narrative
    case miniGame1
    case unit4
    case unit6
    case unit7
    case unit8
    case unit9
    case nextUnit
}

/// App-wide state relevant to navigation between logical units.
public final class AppState: ObservableObject {
    @Published public var currentUnit: AppUnit

    public init(currentUnit: AppUnit = .start) {
        self.currentUnit = currentUnit
    }
}

/// View-model for the initial screen (Unit 1).
/// It exposes the action to begin the experience and move to the next unit.
public final class StartViewModel: ObservableObject {
    private let appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    /// Starts the experience by advancing to the next unit.
    /// Note: The next unit's UI is intentionally not implemented in this step.
    public func beginExperience() {
        appState.currentUnit = .narrative
    }
}

