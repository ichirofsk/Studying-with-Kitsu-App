import SwiftUI

struct ProgressSummaryView: View {
    @ObservedObject var appStore: AppStore

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

                        Text("Progress")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your learning progress at a glance")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(AppTheme.ink)

                            Text("See your current streak, how many tasks were already done, and how many coins were earned or used over time.")
                                .foregroundStyle(AppTheme.ink.opacity(0.72))

                            ViewThatFits(in: .horizontal) {
                                HStack(spacing: 14) {
                                    progressStatCard(
                                        title: "Current streak",
                                        value: "\(appStore.currentStreak)",
                                        footnote: appStore.currentStreak == 1 ? "day in a row" : "days in a row",
                                        accent: AppTheme.coral
                                    )
                                    progressStatCard(
                                        title: "Tasks done",
                                        value: "\(appStore.totalTasksCompleted)",
                                        footnote: "completed in total",
                                        accent: AppTheme.skyDark
                                    )
                                }

                                VStack(spacing: 14) {
                                    progressStatCard(
                                        title: "Current streak",
                                        value: "\(appStore.currentStreak)",
                                        footnote: appStore.currentStreak == 1 ? "day in a row" : "days in a row",
                                        accent: AppTheme.coral
                                    )
                                    progressStatCard(
                                        title: "Tasks done",
                                        value: "\(appStore.totalTasksCompleted)",
                                        footnote: "completed in total",
                                        accent: AppTheme.skyDark
                                    )
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Coins got / used")
                                .font(.title3.weight(.heavy))
                                .foregroundStyle(AppTheme.ink)

                            ViewThatFits(in: .horizontal) {
                                HStack(spacing: 14) {
                                    progressStatCard(
                                        title: "Coins available",
                                        value: "\(appStore.earnedCoins)",
                                        footnote: "ready to use now",
                                        accent: AppTheme.sunflower
                                    )
                                    progressStatCard(
                                        title: "Coins got",
                                        value: "\(appStore.totalCoinsEarned)",
                                        footnote: "earned from tasks",
                                        accent: AppTheme.limeDark
                                    )
                                    progressStatCard(
                                        title: "Coins used",
                                        value: "\(appStore.totalCoinsSpent)",
                                        footnote: "spent on rewards",
                                        accent: AppTheme.skyDark
                                    )
                                }

                                VStack(spacing: 14) {
                                    progressStatCard(
                                        title: "Coins available",
                                        value: "\(appStore.earnedCoins)",
                                        footnote: "ready to use now",
                                        accent: AppTheme.sunflower
                                    )
                                    progressStatCard(
                                        title: "Coins got",
                                        value: "\(appStore.totalCoinsEarned)",
                                        footnote: "earned from tasks",
                                        accent: AppTheme.limeDark
                                    )
                                    progressStatCard(
                                        title: "Coins used",
                                        value: "\(appStore.totalCoinsSpent)",
                                        footnote: "spent on rewards",
                                        accent: AppTheme.skyDark
                                    )
                                }
                            }
                        }
                    }

                    DashboardCard {
                        HStack(alignment: .center, spacing: 18) {
                            Image("kitsufb2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 96, height: 96)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("How to read this screen")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(AppTheme.ink)
                                Text("Current streak shows how many days in a row the child completed at least one task. Tasks done counts every completed task. Coins got and coins used help the family understand progress and rewards over time.")
                                    .foregroundStyle(AppTheme.ink.opacity(0.72))
                            }
                        }
                    }

                    Spacer()
                }
                .padding(24)
            }
        }
        .dashboardBackSwipe {
            appStore.goToHome()
        }
    }

    private func progressStatCard(title: String, value: String, footnote: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(accent)
                    .frame(width: 12, height: 12)
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
            }

            Text(value)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.ink)

            Text(footnote)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.ink.opacity(0.68))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.cloud)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.25), lineWidth: 2)
        )
    }

    private var screenBackground: AccentScreenBackground {
        AccentScreenBackground(accent: AppTheme.coral)
    }
}
