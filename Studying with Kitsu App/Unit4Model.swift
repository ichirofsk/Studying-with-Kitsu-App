import Foundation
import SwiftUI

/// Represents the different phases of Logical Unit 4.
public enum Unit4Phase {
    /// Dialog phase with an associated index.
    case dialog(index: Int)
}

/// Holds the content of a dialog in Logical Unit 4.
public struct Unit4Dialog: Sendable {
    /// The text content of the dialog.
    public let text: String
    /// The name of the mascot image associated with the dialog.
    public let mascotImageName: String
    
    /// Initializes a new Unit4Dialog.
    /// - Parameters:
    ///   - text: The dialog text.
    ///   - mascotImageName: The mascot image name.
    public init(text: String, mascotImageName: String) {
        self.text = text
        self.mascotImageName = mascotImageName
    }
}

/// Configuration constants for layout ratios and animation timings of Logical Unit 4.
public struct Unit4Config {
    /// The ratio of the top panel height relative to the total height.
    public static let topPanelHeightRatio: CGFloat = 0.25
    /// The ratio of the mascot area relative to the top panel.
    public static let mascotAreaRatio: CGFloat = 0.70
    /// The duration of the blink animation.
    public static let blinkDuration: TimeInterval = 0.9
}

/// Provides the dialogs content for Logical Unit 4.
public struct Unit4Content {
    /// The dialogs used in Logical Unit 4.
    public static let dialogs: [Unit4Dialog] = [
        Unit4Dialog(text: "Yay! Now the boy can study!", mascotImageName: "kitsu-1"),
        Unit4Dialog(text: "Could you see how important it is, for a kid, to be guided through study path?", mascotImageName: "kitsu-2"),
        Unit4Dialog(text: "Now, as I was saying, I'm Kitsu, I'm here to lead you two, kid and its responsible, through this path, in a funny way!", mascotImageName: "kitsu-3")
    ]
}
