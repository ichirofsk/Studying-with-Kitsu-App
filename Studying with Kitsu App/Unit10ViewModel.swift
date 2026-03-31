import Foundation
import Combine
import SwiftUI

/// ViewModel for the Narrative Unit 10.
@MainActor
public final class Unit10NarrativeViewModel: ObservableObject {
    // ✅ REMOVIDO: `objectWillChange` manual — ObservableObject já sintetiza automaticamente.

    // Model
    @Published public private(set) var model: Unit10NarrativeModel

    // Outputs for the view
    @Published public private(set) var mascotImageName: String = "kitsuhappy1"

    // ✅ CORRIGIDO: Removido o `didSet` que causava loop lógico e conflito com `private(set)`.
    @Published public private(set) var showMascot: Bool = true

    @Published public private(set) var introText: String = "Of course, it would be better if you could taste it. So now, it's on you! Make it real by yourself!" // ✅ Typo corrigido

    @Published public private(set) var thanksText: String = "Thanks for enjoying!"
    @Published public private(set) var motivationText: String = "Make it a reality, with the strength you've proven you have."

    // Timing tasks
    private var introTask: Task<Void, Never>? = nil
    private var thanksTask: Task<Void, Never>? = nil

    public init(model: Unit10NarrativeModel = Unit10NarrativeModel()) {
        self.model = model
        scheduleIntroFlow()
    }

    deinit {
        introTask?.cancel()
        thanksTask?.cancel()
    }

    // MARK: - Flow
    private func scheduleIntroFlow() {
        model.phase = .intro
        mascotImageName = "kitsuhappy1"
        introText = "Of course, it would be better if you could taste it. So now, it's on you!" // ✅ Typo corrigido
        thanksText = "Thanks for enjoying!"

        introTask?.cancel()
        introTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(6.0))
            await self?.goToMotivation()
        }
    }

    private func goToMotivation() {
        model.phase = .motivation
        mascotImageName = "kitsuhappy1"

        thanksTask?.cancel()
        thanksTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(5.0))
            await self?.goToThanks()
        }
    }

    private func goToThanks() {
        model.phase = .thanks

        thanksTask?.cancel()
        thanksTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.0))
            await self?.finish()
        }
    }

    private func finish() {
        model.phase = .finished
        NotificationCenter.default.post(
            name: Notification.Name("Unit10FinishedNotification"),
            object: nil
        )
    }
}

