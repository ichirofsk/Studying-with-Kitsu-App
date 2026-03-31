import Foundation
import SwiftUI
import Combine

public enum Unit7Screen: Equatable {
    case menu
    case tasks
    // rewards screen is not part of this unit per instruction; navigation to next unit is external
}

@MainActor public final class Unit7ViewModel: ObservableObject {
    // Inputs
    @Published public private(set) var screen: Unit7Screen = .menu
    @Published public var showGlobalDim: Bool = false // global opacity overlay

    // Header
    @Published public private(set) var currentDateString: String = ""

    // User store reference
    public var user: UserStore

    // Task tracker
    @Published public private(set) var tasks: DailyTaskTracker

    // Highlight states
    @Published public private(set) var highlightTasks: Bool = false
    @Published public private(set) var highlightBackToMenu: Bool = false
    @Published public private(set) var highlightRewards: Bool = false

    // Dialogs on Tasks screen
    @Published public private(set) var showIntroDialog: Bool = false
    @Published public private(set) var showTapToCloseHint: Bool = false
    @Published public private(set) var showCompletionistToast: Bool = false
    @Published public private(set) var showCoinsDialog: Bool = false
    @Published public private(set) var canBackToMenu: Bool = false

    private var hasShownTasksIntro: Bool = false

    private var cancellables: [Task<Void, Never>] = []
    private let dateFormatter: DateFormatter

    public init(user: UserStore, tasks: DailyTaskTracker = DailyTaskTracker()) {
        self.user = user
        self.tasks = tasks
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        self.dateFormatter = df
        updateDateString()
        schedulePerMinuteDateRefresh()
        scheduleInitialMenuHighlight()
        self.tasks.ensureCurrent()
        self.tasks = self.tasks
    }

    deinit { cancellables.forEach { $0.cancel() } }

    // MARK: - Header date updates
    private func updateDateString() {
        currentDateString = dateFormatter.string(from: Date())
    }

    private func schedulePerMinuteDateRefresh() {
        let t = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                if Task.isCancelled { break }
                self.updateDateString()
                var tracker = self.tasks
                tracker.ensureCurrent()
                self.tasks = tracker
            }
        }
        cancellables.append(t)
    }

    // MARK: - Menu flow
    private func scheduleInitialMenuHighlight() {
        showGlobalDim = false
        highlightTasks = false
        highlightRewards = false
        let t = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            self.showGlobalDim = true
            self.highlightTasks = true
        }
        cancellables.append(t)
    }

    public func openTasks() {
        highlightTasks = false
        showGlobalDim = false
        tasks.ensureCurrent()
        tasks = tasks
        screen = .tasks
        if !hasShownTasksIntro {
            startTasksIntro()
        } else {
            // Ensure the intro dialog stays dismissed on subsequent entries
            showIntroDialog = false
            showTapToCloseHint = false
        }
    }

    // MARK: - Tasks flow
    private func startTasksIntro() {
        showIntroDialog = true
        showTapToCloseHint = false
        canBackToMenu = false
        highlightBackToMenu = false
        let t = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.0))
            self.showTapToCloseHint = true
        }
        cancellables.append(t)
    }

    public func closeIntroDialogIfVisible() {
        guard showIntroDialog else { return }
        showIntroDialog = false
        showTapToCloseHint = false
        hasShownTasksIntro = true
    }

    public func tapTask1() {
        var tracker = tasks
        tracker.completeTask1(user: &user)
        tasks = tracker
        screen = .tasks
        handlePostTask()
    }
    public func tapTask2() {
        var tracker = tasks
        tracker.completeTask2(user: &user)
        tasks = tracker
        screen = .tasks
        handlePostTask()
    }
    public func tapTask3() {
        var tracker = tasks
        tracker.completeTask3(user: &user)
        tasks = tracker
        screen = .tasks
        handlePostTask()
    }

    private func handlePostTask() {
        if tasks.isTask1Disabled && tasks.isTask2Disabled && tasks.isTask3Disabled {
            let t = Task { @MainActor in
                try? await Task.sleep(for: .seconds(1.0))
                self.showCompletionistToast = true
                try? await Task.sleep(for: .seconds(1.0))
                self.showCompletionistToast = false
                self.showCoinsDialogAfterCompletion()
            }
            cancellables.append(t)
        }
    }

    private func showCoinsDialogAfterCompletion() {
        showCoinsDialog = true
        showTapToCloseHint = false
        let t = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.0))
            self.showTapToCloseHint = true
        }
        cancellables.append(t)
    }

    public func closeCoinsDialogIfVisible() {
        guard showCoinsDialog else { return }
        showCoinsDialog = false
        showTapToCloseHint = false
        // Only now Back to menu can work
        canBackToMenu = true
        // After 1s, highlight Back to menu
        let t = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.0))
            self.showGlobalDim = true
            self.highlightBackToMenu = true
        }
        cancellables.append(t)
    }

    public func backToMenu() {
        guard canBackToMenu else { return }
        screen = .menu
        canBackToMenu = false
        showGlobalDim = false
        highlightBackToMenu = false
        // After 1s, highlight Rewards on menu
        let t = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.0))
            self.showGlobalDim = true
            self.highlightRewards = true
        }
        cancellables.append(t)
    }
}

