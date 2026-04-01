import SwiftUI


@main
@available(iOS 26.0, *)
struct MyApp: App {
    @StateObject private var familyStore: FamilyStore
    @StateObject private var appStore: AppStore
    @StateObject private var childStore: ChildProfileStore
    @StateObject private var routineStore: RoutineStore
    @StateObject private var rewardStore: RewardStore
    @StateObject private var journeyLogbookStore: JourneyLogbookStore
    @StateObject private var weeklyCheckpointStore: WeeklyCheckpointStore
    @StateObject private var parentSecurityStore = ParentSecurityStore()

    private let customFontFileNames = [
        "Merriweather-VariableFont_opsz,wdth,wght.ttf",
        "Merriweather-Italic-VariableFont_opsz,wdth,wght.ttf"
    ]

    init() {
        let familyStore = FamilyStore()
        _familyStore = StateObject(wrappedValue: familyStore)
        _appStore = StateObject(wrappedValue: AppStore(familyStore: familyStore))
        _childStore = StateObject(wrappedValue: ChildProfileStore(familyStore: familyStore))
        _routineStore = StateObject(wrappedValue: RoutineStore(familyStore: familyStore))
        _rewardStore = StateObject(wrappedValue: RewardStore(familyStore: familyStore))
        _journeyLogbookStore = StateObject(wrappedValue: JourneyLogbookStore(familyStore: familyStore))
        _weeklyCheckpointStore = StateObject(wrappedValue: WeeklyCheckpointStore(familyStore: familyStore))
        FontLoader.loadCustomFonts(customFontFileNames)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                appStore: appStore,
                familyStore: familyStore,
                childStore: childStore,
                routineStore: routineStore,
                rewardStore: rewardStore,
                journeyLogbookStore: journeyLogbookStore,
                weeklyCheckpointStore: weeklyCheckpointStore,
                parentSecurityStore: parentSecurityStore
            )
        }
    }
}
