import Foundation

/// Narrative phases for Logical Unit 10.
public enum Unit10NarrativePhase: Equatable {
    case intro        // Mascot + intro message
    case motivation   // Intermediate message (no mascot)
    case thanks       // "Thanks for enjoying!" message
    case finished     // Flow finished; host may restart the app
}

/// Minimal model for Logical Unit 10.
public struct Unit10NarrativeModel {
    /// Current phase of the unit.
    public var phase: Unit10NarrativePhase = .intro
    
    public init() {}
}

