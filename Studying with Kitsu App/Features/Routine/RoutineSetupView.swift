import SwiftUI

struct RoutineSetupView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var routineStore: RoutineStore
    let onContinue: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                DashboardCard {
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top) {
                            routineHeaderCopy
                            Spacer(minLength: 12)
                            cancelButton
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            routineHeaderCopy
                            cancelButton
                        }
                    }
                }
                .frame(maxWidth: 720)

                VStack(spacing: 16) {
                    ForEach(routineStore.routine.tasks) { task in
                        DashboardCard {
                            HStack(alignment: .top, spacing: 14) {
                                Circle()
                                    .fill(AppTheme.sky.opacity(0.22))
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(AppTheme.skyDark)
                                    )

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(task.title)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(AppTheme.ink)
                                    Text(task.detail)
                                        .foregroundStyle(.secondary)
                                    Text("+\(task.rewardCoins) coins")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(AppTheme.coral)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: 680)

                KitsuPrimaryButton(title: "Open main dashboard", action: onContinue)

                Spacer(minLength: 0)
            }
            .padding(horizontalPadding)
            .frame(maxWidth: .infinity)
        }
    }

    private var routineHeaderCopy: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Starter routine")
                .font(.system(size: isCompactLayout ? 28 : 32, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.ink)

            Text("This foundation replaces the old unit-based flow and creates a real product skeleton. Next, we will keep evolving the routine experience from the old Unit7.")
                .font(.headline)
                .foregroundStyle(AppTheme.ink.opacity(0.72))
        }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            onCancel()
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.coral)
    }

    private var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    private var horizontalPadding: CGFloat {
        isCompactLayout ? 16 : 32
    }
}
