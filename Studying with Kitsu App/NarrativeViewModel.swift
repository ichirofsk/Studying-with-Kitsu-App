import Foundation
import Combine

public struct DialogPage: Equatable {
    public let text: String
    public let mascotImageName: String

    public init(text: String, mascotImageName: String) {
        self.text = text
        self.mascotImageName = mascotImageName
    }
}

public final class NarrativeViewModel: ObservableObject {
    // Fixed three pages as requested
    @Published public private(set) var pages: [DialogPage]
    @Published public private(set) var currentIndex: Int = 0
    @Published public var isMuted: Bool = false

    public var isOnLastPage: Bool { currentIndex >= pages.count - 1 }
    public var canGoBack: Bool { currentIndex > 0 }

    public init(
        pages: [DialogPage] = [
            DialogPage(text: "Hey! I'm Kitsu, the fox of knowledge and prosperity.", mascotImageName: "kitsufb1"),
            DialogPage(text: "I'm here to…", mascotImageName: "kitsufb2"),
            DialogPage(text: "Oh, wait! A kid is asking us for help. We gotta go!", mascotImageName: "kitsufb3")
        ]
    ) {
        self.pages = pages
    }

    /// Advances to the next page if not on the last page.
    public func advanceIfPossible() {
        guard !isOnLastPage else { return }
        currentIndex += 1
    }

    /// Goes back to the previous page if possible.
    public func goBackIfPossible() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    /// Resets to the first page (useful if re-entering the unit).
    public func reset() {
        currentIndex = 0
    }
}
