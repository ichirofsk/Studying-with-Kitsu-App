import SwiftUI

struct WeeklyCheckpointView: View {
    @ObservedObject var appStore: AppStore
    @ObservedObject var childStore: ChildProfileStore
    @ObservedObject var weeklyCheckpointStore: WeeklyCheckpointStore

    @State private var showInstructions = false
    @State private var showGame = false
    @State private var showGameLog = false
    @State private var latestResult: WeeklyCheckpointPlay?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Weekly Checkpoint")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    Spacer()

                    Button("Back") {
                        appStore.goToHome()
                    }
                    .font(.headline.weight(.bold))
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.skyDark)
                }

                DashboardCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("A once-a-week question game for the family")
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(AppTheme.ink)

                        Text("From Sunday 00:00 to Saturday 23:59, the child can play this checkpoint only once. After a play, it unlocks again only on the next Sunday at 00:00.")
                            .foregroundStyle(AppTheme.ink.opacity(0.72))
                    }
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 16) {
                        startGameCard
                        instructionsCard
                        gameLogCard
                    }

                    VStack(spacing: 16) {
                        startGameCard
                        instructionsCard
                        gameLogCard
                    }
                }

                if let latestResult {
                    DashboardCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Latest result")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(AppTheme.skyDark)
                            Text("\(displayName) got \(latestResult.correctAnswers) / \(latestResult.totalQuestions) right and earned \(latestResult.coinsAwarded) coins.")
                                .foregroundStyle(AppTheme.ink)
                        }
                    }
                }
            }
            .frame(maxWidth: 980)
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showInstructions) {
            instructionsSheet
        }
        .sheet(isPresented: $showGame) {
            WeeklyCheckpointGameSheet { result in
                weeklyCheckpointStore.recordPlay(
                    correctAnswers: result.correctAnswers,
                    totalQuestions: result.totalQuestions,
                    coinsAwarded: result.coinsAwarded
                )
                appStore.awardBonusCoins(result.coinsAwarded)
                latestResult = WeeklyCheckpointPlay(
                    playedAt: Date(),
                    correctAnswers: result.correctAnswers,
                    totalQuestions: result.totalQuestions,
                    coinsAwarded: result.coinsAwarded
                )
                showGame = false
            }
        }
        .sheet(isPresented: $showGameLog) {
            gameLogSheet
        }
    }

    private var startGameCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Start game")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.ink)

                if weeklyCheckpointStore.canPlayThisWeek() {
                    Text("The weekly checkpoint is available now.")
                        .foregroundStyle(AppTheme.ink.opacity(0.72))
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        Text("Unlocks in \(countdownText(until: weeklyCheckpointStore.nextUnlockDate(from: context.date), now: context.date))")
                            .foregroundStyle(AppTheme.skyDark)
                    }
                }

                Button(weeklyCheckpointStore.canPlayThisWeek() ? "Start weekly game" : "Already played this week") {
                    showGame = true
                }
                .font(.headline.weight(.bold))
                .buttonStyle(.borderedProminent)
                .tint(weeklyCheckpointStore.canPlayThisWeek() ? AppTheme.skyDark : Color.gray)
                .foregroundColor(weeklyCheckpointStore.canPlayThisWeek() ? .primary : .white)
                .disabled(!weeklyCheckpointStore.canPlayThisWeek())
            }
        }
    }

    private var instructionsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Instructions")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.ink)

                Text("Read the turn flow and scoring before starting the weekly game.")
                    .foregroundStyle(AppTheme.ink.opacity(0.72))

                Button("Open instructions") {
                    showInstructions = true
                }
                .font(.headline.weight(.bold))
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.sunflower)
            }
        }
    }

    private var gameLogCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Game log")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.ink)

                Text("See each week's run, the number of correct answers, and the coins earned.")
                    .foregroundStyle(AppTheme.ink.opacity(0.72))

                Button("Open game log") {
                    showGameLog = true
                }
                .font(.headline.weight(.bold))
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.coral)
            }
        }
    }

    private var instructionsSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("How the weekly checkpoint works")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.skyDark)

                Text("1. The adult sees “Adult turn X: Think of a question!” and taps Ready when the question is prepared.")
                Text("2. The child sees “Kid turn X: Answer!” and has 90 seconds to answer.")
                Text("3. The adult marks the answer as Right or Wrong.")
                Text("4. If no button is pressed before 90 seconds end, that answer counts as Wrong.")
                Text("5. This repeats until question 10.")
                Text("6. At the end, the game shows total correct answers and coins earned, with up to 50 coins total.")

                Spacer()
            }
            .foregroundStyle(AppTheme.ink)
            .padding(24)
            .background(AppTheme.cream.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Instructions")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.black)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        showInstructions = false
                    }
                    .font(.headline.weight(.bold))
                }
            }
        }
    }

    private var gameLogSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if weeklyCheckpointStore.plays.isEmpty {
                        DashboardCard {
                            Text("No weekly games played yet. Start this week's checkpoint to create the first log.")
                                .foregroundStyle(AppTheme.ink.opacity(0.72))
                        }
                    } else {
                        ForEach(weeklyCheckpointStore.plays) { play in
                            DashboardCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(dateTitle(for: play.playedAt))
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(AppTheme.skyDark)
                                    Text("Correct answers: \(play.correctAnswers) / \(play.totalQuestions)")
                                        .font(.title3.weight(.heavy))
                                        .foregroundStyle(AppTheme.ink)
                                    Text("Coins earned: \(play.coinsAwarded)")
                                        .foregroundStyle(AppTheme.ink.opacity(0.72))
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(AppTheme.cream.ignoresSafeArea())
            .navigationTitle("Game log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        showGameLog = false
                    }
                    .font(.headline.weight(.bold))
                }
            }
        }
    }

    private var displayName: String {
        let trimmed = childStore.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "The child" : trimmed
    }

    private func countdownText(until resetDate: Date, now: Date) -> String {
        let remaining = max(0, Int(resetDate.timeIntervalSince(now)))
        let days = remaining / 86_400
        let hours = (remaining % 86_400) / 3_600
        let minutes = (remaining % 3_600) / 60
        let seconds = remaining % 60
        if days > 0 {
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func dateTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

private struct WeeklyCheckpointResult {
    let correctAnswers: Int
    let totalQuestions: Int
    let coinsAwarded: Int
}

private struct WeeklyCheckpointGameSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onFinish: (WeeklyCheckpointResult) -> Void

    @State private var questionNumber = 1
    @State private var phase: TurnPhase = .adult
    @State private var correctAnswers = 0
    @State private var secondsRemaining = 90
    @State private var timerTask: Task<Void, Never>?

    private let totalQuestions = 10
    private let maxCoins = 50

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Weekly game")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.skyDark)

                HStack(spacing: 16) {
                    statChip(title: "Question", value: currentQuestionValue)
                    statChip(title: "Right", value: "\(correctAnswers)")
                    if phase == .kid {
                        statChip(title: "Timer", value: formattedTime)
                    }
                }

                Spacer()

                switch phase {
                case .adult:
                    checkpointCard(
                        title: "Adult turn \(questionNumber):",
                        message: "Think of a question!"
                    ) {
                        Button("Ready") {
                            beginKidTurn()
                        }
                        .font(.headline.weight(.bold))
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.skyDark)
                    }

                case .kid:
                    checkpointCard(
                        title: "Kid turn \(questionNumber):",
                        message: "Answer!"
                    ) {
                        HStack(spacing: 12) {
                            Button("Right") {
                                submitAnswer(isRight: true)
                            }
                            .font(.headline.weight(.bold))
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.limeDark)

                            Button("Wrong") {
                                submitAnswer(isRight: false)
                            }
                            .font(.headline.weight(.bold))
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.coral)
                        }
                    }

                case .finished:
                    checkpointCard(
                        title: "Game complete",
                        message: "The 10 questions are done."
                    ) {
                        VStack(spacing: 10) {
                            Text("Correct answers: \(correctAnswers) / \(totalQuestions)")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(AppTheme.ink)
                            Text("Coins earned: \(coinsAwarded)")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(AppTheme.skyDark)
                            Button("Close") {
                                onFinish(
                                    WeeklyCheckpointResult(
                                        correctAnswers: correctAnswers,
                                        totalQuestions: totalQuestions,
                                        coinsAwarded: coinsAwarded
                                    )
                                )
                                dismiss()
                            }
                            .font(.headline.weight(.bold))
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.skyDark)
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
            .background(AppTheme.cream.ignoresSafeArea())
            .interactiveDismissDisabled(phase != .finished)
            .onDisappear {
                timerTask?.cancel()
            }
        }
    }

    private var coinsAwarded: Int {
        (correctAnswers * maxCoins) / totalQuestions
    }

    private var currentQuestionValue: String {
        phase == .finished ? "\(totalQuestions)/\(totalQuestions)" : "\(questionNumber)/\(totalQuestions)"
    }

    private var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func checkpointCard<Content: View>(title: String, message: String, @ViewBuilder content: () -> Content) -> some View {
        DashboardCard {
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.skyDark)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppTheme.ink)
                    .multilineTextAlignment(.center)

                content()
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func statChip(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption.weight(.heavy))
                .foregroundStyle(AppTheme.skyDark)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.cloud)
        .clipShape(Capsule())
    }

    private func beginKidTurn() {
        phase = .kid
        secondsRemaining = 90
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while secondsRemaining > 0 && phase == .kid {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled, phase == .kid else { return }
                secondsRemaining -= 1
            }
            if phase == .kid && secondsRemaining == 0 {
                submitAnswer(isRight: false)
            }
        }
    }

    private func submitAnswer(isRight: Bool) {
        timerTask?.cancel()
        if isRight {
            correctAnswers += 1
        }

        if questionNumber >= totalQuestions {
            phase = .finished
        } else {
            questionNumber += 1
            phase = .adult
        }
    }
}

private enum TurnPhase {
    case adult
    case kid
    case finished
}
