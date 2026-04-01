import SwiftUI

struct HomeDashboardView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var appStore: AppStore
    @ObservedObject var familyStore: FamilyStore
    @ObservedObject var childStore: ChildProfileStore
    @ObservedObject var routineStore: RoutineStore
    @ObservedObject var parentSecurityStore: ParentSecurityStore
    @State private var showParentGate = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero

                quickStats

                if isCompactLayout {
                    VStack(spacing: 16) {
                        featureCard(
                            title: "Daily tasks",
                            subtitle: "Check off the learning steps for today",
                            accent: AppTheme.lime
                        ) {
                            appStore.goToDailyTasks()
                        }

                        featureCard(
                            title: "Journey logbook",
                            subtitle: "Open the family's story and milestone journal",
                            accent: AppTheme.skyDark
                        ) {
                            appStore.goToJourneyLogbook()
                        }

                        featureCard(
                            title: "Weekly Checkpoint",
                            subtitle: "Review the week and celebrate what stood out",
                            accent: AppTheme.coral
                        ) {
                            appStore.goToWeeklyCheckpoint()
                        }

                        featureCard(
                            title: "Rewards",
                            subtitle: "Trade coins for playful family rewards",
                            accent: AppTheme.sunflower
                        ) {
                            appStore.goToRewards()
                        }
                    }
                } else {
                    HStack(alignment: .top, spacing: 16) {
                        featureCard(
                            title: "Daily tasks",
                            subtitle: "Check off the learning steps for today",
                            accent: AppTheme.lime
                        ) {
                            appStore.goToDailyTasks()
                        }

                        featureCard(
                            title: "Journey logbook",
                            subtitle: "Open the family's story and milestone journal",
                            accent: AppTheme.skyDark
                        ) {
                            appStore.goToJourneyLogbook()
                        }

                        featureCard(
                            title: "Weekly Checkpoint",
                            subtitle: "Review the week and celebrate what stood out",
                            accent: AppTheme.coral
                        ) {
                            appStore.goToWeeklyCheckpoint()
                        }

                        featureCard(
                            title: "Rewards",
                            subtitle: "Trade coins for playful family rewards",
                            accent: AppTheme.sunflower
                        ) {
                            appStore.goToRewards()
                        }
                    }
                }

                DashboardCard {
                    featureButton(
                        title: "Progress",
                        subtitle: "See consistency, wins, and what to improve next",
                        accent: AppTheme.coral
                    ) {
                        appStore.goToProgress()
                    }
                }
            }
            .frame(maxWidth: 980)
            .padding(horizontalPadding)
            .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showParentGate) {
            ParentPinEntryView(
                securityStore: parentSecurityStore,
                title: "Parent access",
                message: "Enter the parent PIN to manage child profiles.",
                onSuccess: {
                    showParentGate = false
                    appStore.goToChildPicker()
                },
                onCancel: {
                    showParentGate = false
                }
            )
        }
    }

    private var hero: some View {
        DashboardCard {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 18) {
                    heroCopy

                    Spacer(minLength: 12)

                    heroAside(alignment: .trailing, imageSize: 120)
                }

                VStack(alignment: .leading, spacing: 16) {
                    heroCopy
                    heroAside(alignment: .leading, imageSize: 96)
                }
            }
        }
    }

    private var quickStats: some View {
        Group {
            if isCompactLayout {
                VStack(alignment: .leading, spacing: 12) {
                    statPill(title: "Focus", value: "\(routineStore.routine.focusMinutesGoal) min", color: AppTheme.skyDark)
                    statPill(title: "Coins", value: "\(appStore.earnedCoins)", color: AppTheme.sunflower)
                    statPill(title: "Streak", value: "\(appStore.currentStreak) day(s)", color: AppTheme.coral)
                }
            } else {
                HStack(spacing: 14) {
                    statPill(title: "Focus", value: "\(routineStore.routine.focusMinutesGoal) min", color: AppTheme.skyDark)
                    statPill(title: "Coins", value: "\(appStore.earnedCoins)", color: AppTheme.sunflower)
                    statPill(title: "Streak", value: "\(appStore.currentStreak) day(s)", color: AppTheme.coral)
                }
            }
        }
    }

    private var displayName: String {
        let trimmed = childStore.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "the child" : trimmed
    }

    private func statPill(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.cloud.opacity(0.95))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(color.opacity(0.18), lineWidth: 2))
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Family dashboard")
                .font(.system(size: isCompactLayout ? 28 : 32, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text("Build a steady study rhythm with \(displayName), one clear step at a time.")
                .font(.title3.weight(.medium))
                .foregroundStyle(AppTheme.ink.opacity(0.75))
            Text("\(familyStore.children.count) child profile(s) ready to manage")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.coral)
            if let firstTask = routineStore.routine.tasks.first {
                Label("Today's first anchor: \(firstTask.title)", systemImage: "flag.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.skyDark)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func heroAside(alignment: HorizontalAlignment, imageSize: CGFloat) -> some View {
        VStack(alignment: alignment, spacing: 10) {
            Button("Children") {
                if parentSecurityStore.hasConfiguredPIN && !parentSecurityStore.isParentVerified {
                    showParentGate = true
                } else {
                    appStore.goToChildPicker()
                }
            }
            .font(.headline.weight(.bold))
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.skyDark)

            Image("kitsuhappy1")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
        }
    }

    private func featureCard(title: String, subtitle: String, accent: Color, action: @escaping () -> Void) -> some View {
        DashboardCard {
            featureButton(title: title, subtitle: subtitle, accent: accent, action: action)
        }
    }

    private func featureButton(title: String, subtitle: String, accent: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Circle()
                    .fill(accent)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.white.opacity(0.7), lineWidth: 2))
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Text(subtitle)
                    .foregroundStyle(AppTheme.ink.opacity(0.72))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    private var horizontalPadding: CGFloat {
        isCompactLayout ? 16 : 24
    }
}
