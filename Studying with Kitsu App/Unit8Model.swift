import Foundation

public struct RewardTitles: Equatable {
    public var button1: String = "Eat ice cream"
    public var button2: String = "Cinema day"
    public var button3: String = "New game"
    public var button4: String = "Parents surprise"
    
    public init() {}
}

/// Represents the dialog phases for Unit 8 (Rewards).
/// 
/// The `step` parameter alternates the hint label displayed (skip/close)
/// and moves to the next dialog when tapped at step 1.
public enum Unit8DialogPhase: Equatable {
    case none
    /// Intro first dialog phase with steps:
    /// - step 0: shows "Tap anywhere to skip"
    /// - step 1: shows "Tap anywhere to close"
    case introFirst(step: Int)
    /// Intro second dialog phase:
    /// Shows "At first, try changing what is inside the medium price prize button."
    case introSecond
    /// Post edit dialog phase with steps:
    /// - step 0: conteudoc1 (skip)
    /// - step 1: conteudoc2 (close)
    case postEdit(step: Int)
}
