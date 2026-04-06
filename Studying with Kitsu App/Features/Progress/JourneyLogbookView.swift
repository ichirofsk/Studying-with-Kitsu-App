import SwiftUI

struct JourneyLogbookView: View {
    @ObservedObject var appStore: AppStore
    @ObservedObject var childStore: ChildProfileStore
    @ObservedObject var journeyLogbookStore: JourneyLogbookStore

    @State private var showAddLesson = false
    @State private var showAlbum = false
    @State private var todayLessonText = ""
    @State private var showRewardToast = false
    @State private var rewardDismissTask: Task<Void, Never>?

    private let dailyRewardCoins = 15

    var body: some View {
        ZStack {
            screenBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            appStore.goToHome()
                        } label: {
                            Text("Back")
                                .kitsuButtonTextShadow()
                        }
                        .font(.headline.weight(.bold))
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.skyDark)

                        Text("Journey logbook")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("A daily place to keep the best lesson of the day")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(AppTheme.ink)

                            Text("Each day, the child can write the most interesting or funniest lesson they learned. When today's entry is saved, the child earns 15 coins once for that day.")
                                .foregroundStyle(AppTheme.ink.opacity(0.72))
                        }
                    }

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 16) {
                            primaryActionCard
                            albumActionCard
                        }

                        VStack(spacing: 16) {
                            primaryActionCard
                            albumActionCard
                        }
                    }

                    if let todayEntry = journeyLogbookStore.entryForToday() {
                        DashboardCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's log")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(AppTheme.skyDark)

                                Text(todayEntry.text)
                                    .font(.title3.weight(.medium))
                                    .foregroundStyle(AppTheme.ink)

                                Text("Today's 15-coin reward has already been collected.")
                                    .foregroundStyle(AppTheme.ink.opacity(0.68))
                            }
                        }
                    }
                }
                .frame(maxWidth: 980)
                .padding(24)
                .frame(maxWidth: .infinity)
            }

            if showRewardToast {
                VStack(spacing: 10) {
                    Image("kitsuhappy1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)

                    Text("+15 coins")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.skyDark)

                    Text("Great journal entry!")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.ink)
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppTheme.cloud.opacity(0.96))
                        .shadow(color: AppTheme.skyDark.opacity(0.16), radius: 18, x: 0, y: 10)
                )
                .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: showRewardToast)
        .onDisappear {
            rewardDismissTask?.cancel()
        }
        .dashboardBackSwipe {
            appStore.goToHome()
        }
        .sheet(isPresented: $showAddLesson) {
            addLessonSheet
        }
        .sheet(isPresented: $showAlbum) {
            logAlbumSheet
        }
    }

    private var primaryActionCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Add today's most interesting/funny lesson")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.ink)

                Text(journeyLogbookStore.canAddEntryToday()
                    ? "Write today's best lesson and earn 15 coins."
                    : "Today's lesson is already saved. Come back tomorrow for a new entry.")
                    .foregroundStyle(AppTheme.ink.opacity(0.72))

                Button {
                    showAddLesson = true
                } label: {
                    Text(journeyLogbookStore.canAddEntryToday() ? "Add today's lesson" : "Today's lesson already added")
                        .kitsuButtonTextShadow(active: journeyLogbookStore.canAddEntryToday())
                }
                .font(.headline.weight(.bold))
                .buttonStyle(.borderedProminent)
                .tint(journeyLogbookStore.canAddEntryToday() ? AppTheme.skyDark : Color.gray)
                .foregroundColor(journeyLogbookStore.canAddEntryToday() ? .primary : .white)
                .disabled(!journeyLogbookStore.canAddEntryToday())
            }
        }
    }

    private var albumActionCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Log album")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.ink)

                Text("Open the diary archive and browse every saved lesson separated by date.")
                    .foregroundStyle(AppTheme.ink.opacity(0.72))

                Button {
                    showAlbum = true
                } label: {
                    Text("Open album")
                        .kitsuButtonTextShadow()
                }
                .font(.headline.weight(.bold))
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.sunflower)
            }
        }
    }

    private var addLessonSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Today's lesson")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.skyDark)

                Text("What was the most interesting or funniest thing \(displayName) learned today?")
                    .foregroundStyle(AppTheme.ink.opacity(0.72))

                TextEditor(text: $todayLessonText)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.black)
                    .padding(12)
                    .frame(minHeight: 180)
                    .background(AppTheme.cloud)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.sky.opacity(0.35), lineWidth: 2)
                    )

                Text("One entry per day. Saving this gives 15 coins.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.ink.opacity(0.68))

                Spacer()
            }
            .padding(24)
            .background(screenBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.skyDark.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add today's lesson")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.skyDark)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        todayLessonText = ""
                        showAddLesson = false
                    } label: {
                        Text("Cancel")
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let saved = journeyLogbookStore.addTodayEntry(todayLessonText)
                        guard saved else {
                            showAddLesson = false
                            todayLessonText = ""
                            return
                        }
                        appStore.awardJourneyLogbookCoins(dailyRewardCoins)
                        todayLessonText = ""
                        showAddLesson = false
                        showRewardFeedback()
                    } label: {
                        Text("Save")
                            .kitsuButtonTextShadow(active: !todayLessonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .font(.headline.weight(.bold))
                    .disabled(todayLessonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var logAlbumSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if groupedEntries.isEmpty {
                        DashboardCard {
                            Text("No lessons saved yet. Add today's lesson to start the family logbook.")
                                .foregroundStyle(AppTheme.ink.opacity(0.72))
                        }
                    } else {
                        ForEach(groupedEntries, id: \.dayKey) { group in
                            DashboardCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.title)
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(AppTheme.skyDark)

                                    ForEach(group.entries) { entry in
                                        Text(entry.text)
                                            .foregroundStyle(AppTheme.ink)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(14)
                                            .background(AppTheme.cloud)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(screenBackground.ignoresSafeArea())
            .navigationTitle("Log album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.skyDark.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAlbum = false
                    } label: {
                        Text("Close")
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                }
            }
        }
    }

    private var displayName: String {
        let trimmed = childStore.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "the child" : trimmed
    }

    private var screenBackground: AccentScreenBackground {
        AccentScreenBackground(accent: AppTheme.skyDark)
    }

    private var groupedEntries: [EntryGroup] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none

        let grouped = Dictionary(grouping: journeyLogbookStore.entries) { entry in
            calendar.startOfDay(for: entry.createdAt)
        }

        return grouped.keys.sorted(by: >).map { date in
            EntryGroup(
                dayKey: date,
                title: formatter.string(from: date),
                entries: grouped[date]?.sorted(by: { $0.createdAt > $1.createdAt }) ?? []
            )
        }
    }

    private func showRewardFeedback() {
        rewardDismissTask?.cancel()
        showRewardToast = true
        rewardDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            showRewardToast = false
        }
    }
}

private struct EntryGroup {
    let dayKey: Date
    let title: String
    let entries: [JourneyLogEntry]
}
