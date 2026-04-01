import SwiftUI

struct AppRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var appStore: AppStore
    @ObservedObject var familyStore: FamilyStore
    @ObservedObject var childStore: ChildProfileStore
    @ObservedObject var routineStore: RoutineStore
    @ObservedObject var rewardStore: RewardStore
    @ObservedObject var journeyLogbookStore: JourneyLogbookStore
    @ObservedObject var weeklyCheckpointStore: WeeklyCheckpointStore
    @ObservedObject var parentSecurityStore: ParentSecurityStore

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.sky,
                    Color(red: 0.99, green: 0.84, blue: 0.88),
                    AppTheme.cream
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(AppTheme.sunflower.opacity(0.25))
                .frame(width: 220, height: 220)
                .blur(radius: 6)
                .offset(x: 140, y: -280)

            Circle()
                .fill(AppTheme.lime.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 10)
                .offset(x: -160, y: 330)

            currentScreen
        }
        .animation(.easeInOut, value: appStore.destination)
        .onAppear {
            appStore.refreshDailyTaskStateIfNeeded()
            if familyStore.hasChildren && !parentSecurityStore.hasConfiguredPIN {
                appStore.goToParentPinSetup()
                return
            }
            appStore.prepareLaunchDestination(
                hasChildren: familyStore.hasChildren,
                hasActiveChild: familyStore.activeChildID != nil
            )
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                appStore.refreshDailyTaskStateIfNeeded()
            } else {
                parentSecurityStore.clearVerification()
            }
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch appStore.destination {
        case .welcome:
            WelcomeView {
                if parentSecurityStore.hasConfiguredPIN {
                    familyStore.createChildDraft()
                    appStore.goToOnboarding()
                } else {
                    appStore.goToParentPinSetup()
                }
            }
        case .parentPinSetup:
            ParentPinSetupView { pin in
                parentSecurityStore.configurePIN(pin)
                if familyStore.hasChildren {
                    appStore.goToChildPicker()
                } else {
                    familyStore.createChildDraft()
                    appStore.goToOnboarding()
                }
            }
        case .childPicker:
            if parentSecurityStore.isParentVerified {
                ChildPickerView(
                    familyStore: familyStore,
                    appStore: appStore,
                    parentSecurityStore: parentSecurityStore
                )
            } else {
                ParentPinEntryView(
                    securityStore: parentSecurityStore,
                    title: "Parent access",
                    message: "Enter the 4-digit PIN to manage child profiles.",
                    onSuccess: {},
                    onCancel: {
                        if familyStore.activeChildID != nil {
                            appStore.goToHome()
                        } else {
                            appStore.goToWelcome()
                        }
                    }
                )
            }
        case .onboarding:
            ChildOnboardingView(
                childStore: childStore,
                onContinue: {
                    appStore.goToRoutineSetup()
                },
                onCancel: {
                    cancelActiveChildCreation()
                }
            )
        case .routineSetup:
            RoutineSetupView(
                routineStore: routineStore,
                onContinue: {
                    familyStore.finalizePendingCreation()
                    appStore.goToHome()
                },
                onCancel: {
                    cancelActiveChildCreation()
                }
            )
        case .home:
            HomeDashboardView(
                appStore: appStore,
                familyStore: familyStore,
                childStore: childStore,
                routineStore: routineStore,
                parentSecurityStore: parentSecurityStore
            )
        case .dailyTasks:
            DailyTasksHubView(
                appStore: appStore,
                childStore: childStore,
                routineStore: routineStore,
                parentSecurityStore: parentSecurityStore
            )
        case .journeyLogbook:
            JourneyLogbookView(
                appStore: appStore,
                childStore: childStore,
                journeyLogbookStore: journeyLogbookStore
            )
        case .weeklyCheckpoint:
            WeeklyCheckpointView(
                appStore: appStore,
                childStore: childStore,
                weeklyCheckpointStore: weeklyCheckpointStore
            )
        case .rewards:
            RewardsHubView(
                appStore: appStore,
                childStore: childStore,
                rewardStore: rewardStore,
                parentSecurityStore: parentSecurityStore
            )
        case .progress:
            ProgressSummaryView(appStore: appStore)
        }
    }

    private func cancelActiveChildCreation() {
        if let pendingChildID = familyStore.pendingCreationChildID {
            familyStore.removeChild(pendingChildID)
        }
        familyStore.finalizePendingCreation()
        appStore.goToChildPicker()
    }
}
