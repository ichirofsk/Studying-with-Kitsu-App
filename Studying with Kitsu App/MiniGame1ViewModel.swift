import Foundation
import Combine

@MainActor
public final class MiniGame1ViewModel: ObservableObject {
    // Phases
    @Published public private(set) var phase: MiniGame1Phase = .focusAnimation

    // Leaves count and stage
    @Published public private(set) var qtdFolhas: Int = MiniGame1Config.initialLeaves

    // Microphone activation (placeholder toggled by the View)
    @Published public var isMicrofoneBeingActivated: Bool = false {
        didSet { updateMicTimer() }
    }

    // UI helpers
    @Published public var showFullBackground: Bool = false // becomes true after tap during focusAnimation
    @Published public var showFadeOut: Bool = false // becomes true when finished, after delay

    private var micTimer: AnyCancellable?
    private var fadeOutTask: Task<Void, Never>?

    public init() {}

    // MARK: - User interactions

    public func handleTap() {
        switch phase {
        case .focusAnimation:
            // Stop the focus animation and show full background, go to first dialogue
            showFullBackground = true
            phase = .dialogue(index: 0)

        case .dialogue(let index):
            if index < MiniGame1Dialogue.items.count - 1 {
                phase = .dialogue(index: index + 1)
            } else {
                // Start the minigame on the 3rd dialogue
                phase = .playing
            }

        case .playing, .finished:
            break
        }
    }

    // MARK: - Game loop

    private func updateMicTimer() {
        micTimer?.cancel()
        guard isMicrofoneBeingActivated, case .playing = phase else { return }

        micTimer = Timer.publish(every: MiniGame1Config.micTickSeconds, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.decreaseLeaves()
            }
    }

    private func decreaseLeaves() {
        guard case .playing = phase else { return }
        qtdFolhas = max(0, qtdFolhas - MiniGame1Config.leavesStep)
        if qtdFolhas == 0 {
            phase = .finished
            micTimer?.cancel()
            scheduleFadeOut()
        }
    }

    private func scheduleFadeOut() {
        fadeOutTask?.cancel()
        fadeOutTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(MiniGame1Config.fadeOutDelay * 1_000_000_000))
            guard let self = self else { return }
            self.triggerFadeOut()
        }
    }

    private func triggerFadeOut() {
        showFadeOut = true
        // Do not advance to the next unit here; the hosting view can observe showFadeOut/phase
    }

    // Expose current dialogue text for convenience
    public var currentDialogue: String? {
        if case let .dialogue(index) = phase {
            return MiniGame1Dialogue.items[index]
        }
        return nil
    }
}

