import SwiftUI

struct ProgressSummaryView: View {
    @ObservedObject var appStore: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                    Spacer()
                    Button("Back") {
                        appStore.goToHome()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.skyDark)
                }

                DashboardCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current streak")
                            .font(.headline)
                            .foregroundStyle(AppTheme.skyDark)
                        Text("\(appStore.currentStreak) day(s)")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                        Text("Tasks completed today: \(appStore.completedTaskIDs.count)")
                            .font(.headline)
                        Text("Available coins: \(appStore.earnedCoins)")
                            .font(.headline)
                        Text("This screen will receive the visual history and routine indicators as we continue migrating the old task logic.")
                            .foregroundStyle(.secondary)
                    }
                }

                Image("kitsufb2")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180)
                    .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding(24)
        }
    }
}
