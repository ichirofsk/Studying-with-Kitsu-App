import SwiftUI

struct DailyTasksHubView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var appStore: AppStore
    @ObservedObject var childStore: ChildProfileStore
    @ObservedObject var routineStore: RoutineStore
    @ObservedObject var parentSecurityStore: ParentSecurityStore
    @State private var editorMode: TaskEditorMode?
    @State private var pendingEditorMode: TaskEditorMode?
    @State private var pendingRemovalTask: StudyTask?
    @State private var taskPendingRemoval: StudyTask?
    @State private var showRemovalAlert = false
    @State private var editorTitle = ""
    @State private var editorCoins = "7"

    init(
        appStore: AppStore,
        childStore: ChildProfileStore,
        routineStore: RoutineStore,
        parentSecurityStore: ParentSecurityStore
    ) {
        self.appStore = appStore
        self.childStore = childStore
        self.routineStore = routineStore
        self.parentSecurityStore = parentSecurityStore
    }

    var body: some View {
        ZStack {
            screenBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    progressCard
                    taskList
                    footerActions
                }
                .frame(maxWidth: 980)
                .padding(horizontalPadding)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            appStore.refreshDailyTaskStateIfNeeded()
        }
        .dashboardBackSwipe {
            appStore.goToHome()
        }
        .sheet(
            isPresented: Binding(
                get: { editorMode != nil },
                set: { isPresented in
                    if !isPresented {
                        editorMode = nil
                    }
                }
            )
        ) {
            if let editorMode {
                taskEditor(editorMode)
            }
        }
        .sheet(
            isPresented: Binding(
                get: { pendingEditorMode != nil || pendingRemovalTask != nil },
                set: { isPresented in
                    if !isPresented {
                        pendingEditorMode = nil
                        pendingRemovalTask = nil
                    }
                }
            )
        ) {
            ParentPinEntryView(
                securityStore: parentSecurityStore,
                title: "Parent access",
                message: "Enter the parent PIN to add, edit, or remove daily tasks.",
                onSuccess: {
                    if let pendingEditorMode {
                        editorMode = pendingEditorMode
                    }
                    let authenticatedRemovalTask = pendingRemovalTask
                    pendingEditorMode = nil
                    pendingRemovalTask = nil

                    // Present the deletion confirmation after the PIN sheet has fully dismissed.
                    if let authenticatedRemovalTask {
                        DispatchQueue.main.async {
                            taskPendingRemoval = authenticatedRemovalTask
                            showRemovalAlert = true
                        }
                    }
                },
                onCancel: {
                    pendingEditorMode = nil
                    pendingRemovalTask = nil
                }
            )
        }
        .alert("Remove task?", isPresented: $showRemovalAlert) {
            Button("Cancel", role: .cancel) {
                taskPendingRemoval = nil
            }
            Button("Remove", role: .destructive) {
                removePendingTask()
            }
        } message: {
            Text(removalMessage)
        }
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            VStack(alignment: .leading, spacing: 14) {
                backButton

                HStack(alignment: .top) {
                    headerCopy

                    Spacer(minLength: 12)

                    headerActions
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                backButton
                headerCopy
                headerActions
            }
        }
    }

    private var progressCard: some View {
        DashboardCard {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 18) {
                    progressCopy
                    Spacer(minLength: 12)
                    progressBadge
                }

                VStack(alignment: .leading, spacing: 16) {
                    progressCopy
                    progressBadge
                }
            }
        }
    }

    private var taskList: some View {
        VStack(spacing: 14) {
            ForEach(routineStore.routine.tasks) { task in
                DashboardCard {
                    if isCompactLayout {
                        VStack(alignment: .leading, spacing: 14) {
                            taskTapArea(task)
                            taskActions(task)
                        }
                    } else {
                        HStack(alignment: .center, spacing: 16) {
                            taskTapArea(task)
                            Spacer()
                            taskActions(task)
                                .frame(maxWidth: 160, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    private var footerActions: some View {
        Group {
            if isCompactLayout {
                VStack(spacing: 12) {
                    KitsuPrimaryButton(title: "Back to dashboard") {
                        appStore.goToHome()
                    }

                    secondaryCapsuleButton(title: "Go to rewards") {
                        appStore.goToRewards()
                    }
                }
            } else {
                HStack(spacing: 12) {
                    KitsuPrimaryButton(title: "Back to dashboard") {
                        appStore.goToHome()
                    }

                    secondaryCapsuleButton(title: "Go to rewards") {
                        appStore.goToRewards()
                    }
                }
            }
        }
    }

    private var headerCopy: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily tasks")
                .font(.system(size: isCompactLayout ? 28 : 32, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text("Help \(displayName) complete today's learning steps and collect coins along the way.")
                .font(.title3.weight(.medium))
                .foregroundStyle(AppTheme.ink.opacity(0.72))
        }
    }

    private var headerActions: some View {
        Group {
            if isCompactLayout {
                VStack(alignment: .leading, spacing: 10) {
                    Button {
                        prepareEditor(for: .create)
                    } label: {
                        Text("Add task")
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                    .buttonStyle(.bordered)
                }
            } else {
                HStack(spacing: 10) {
                    Button {
                        prepareEditor(for: .create)
                    } label: {
                        Text("Add task")
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var backButton: some View {
        Button {
            appStore.goToHome()
        } label: {
            Text("Back")
                .kitsuButtonTextShadow()
        }
        .font(.headline.weight(.bold))
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.skyDark)
    }

    private var progressCopy: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Today's mission", systemImage: "checklist")
                .font(.headline)
                .foregroundStyle(AppTheme.skyDark)
            Text("\(completedCount) of \(routineStore.routine.tasks.count) tasks completed")
                .font(.system(size: isCompactLayout ? 24 : 28, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text("\(remainingCount) task(s) left before reward time.")
                .foregroundStyle(AppTheme.ink.opacity(0.7))
        }
    }

    private var progressBadge: some View {
        ZStack {
            Circle()
                .fill(AppTheme.lime.opacity(0.18))
                .frame(width: isCompactLayout ? 96 : 112, height: isCompactLayout ? 96 : 112)
            VStack(spacing: 4) {
                Text("\(appStore.earnedCoins)")
                    .font(.system(size: isCompactLayout ? 24 : 28, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text("coins")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.limeDark)
            }
        }
    }

    private func taskMainContent(_ task: StudyTask) -> some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCompleted(task) ? AppTheme.lime : AppTheme.sky.opacity(0.22))
                    .frame(width: 52, height: 52)
                Image(systemName: isCompleted(task) ? "checkmark" : "book.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(isCompleted(task) ? Color.white : AppTheme.skyDark)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.ink)
                if !task.isDefault {
                    Text("Tap to edit")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(AppTheme.skyDark)
                }
                if !task.detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(task.detail)
                        .foregroundStyle(AppTheme.ink.opacity(0.68))
                }
                Label("+\(task.rewardCoins) coins", systemImage: "star.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.sunflower)
            }
        }
    }

    private func taskTapArea(_ task: StudyTask) -> some View {
        taskMainContent(task)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !task.isDefault else { return }
                prepareEditor(for: .edit(task))
            }
    }

    private func taskActions(_ task: StudyTask) -> some View {
        VStack(alignment: isCompactLayout ? .leading : .trailing, spacing: 10) {
            if task.isDefault {
                tagLabel(title: "Default", color: AppTheme.skyDark)
            }

            Button {
                appStore.completeTask(task)
                if completedCount == routineStore.routine.tasks.count {
                    appStore.markDailyRoutineCompleted()
                }
            } label: {
                if isCompleted(task) {
                    VStack(spacing: 4) {
                        Text("Done")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)
                            .kitsuButtonTextShadow()
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            Text(countdownText(until: nextTaskResetDate(from: context.date), now: context.date))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.skyDark)
                                .kitsuButtonTextShadow()
                        }
                    }
                } else {
                    Text("Mark done")
                        .kitsuButtonTextShadow()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(isCompleted(task) ? Color.gray.opacity(0.6) : AppTheme.limeDark)
            .disabled(isCompleted(task))
        }
    }

    private func secondaryCapsuleButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.ink)
                .kitsuButtonTextShadow()
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .frame(maxWidth: isCompactLayout ? .infinity : nil)
                .background(AppTheme.sunflower)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.orange.opacity(0.35), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private var displayName: String {
        let trimmed = childStore.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "your child" : trimmed
    }

    private var completedCount: Int {
        routineStore.routine.tasks.filter { appStore.completedTaskIDs.contains($0.id) }.count
    }

    private var remainingCount: Int {
        max(0, routineStore.routine.tasks.count - completedCount)
    }

    private func prepareEditor(for mode: TaskEditorMode) {
        switch mode {
        case .create:
            editorTitle = ""
            editorCoins = "7"
        case .edit(let task):
            editorTitle = task.title
            editorCoins = "\(task.rewardCoins)"
        }

        if parentSecurityStore.hasConfiguredPIN && !parentSecurityStore.isParentVerified {
            pendingEditorMode = mode
        } else {
            editorMode = mode
        }
    }

    private func prepareRemoval(for task: StudyTask) {
        guard !task.isDefault else { return }

        if parentSecurityStore.hasConfiguredPIN && !parentSecurityStore.isParentVerified {
            pendingRemovalTask = task
        } else {
            taskPendingRemoval = task
            showRemovalAlert = true
        }
    }

    private func removePendingTask() {
        guard let pendingTask = taskPendingRemoval else { return }
        routineStore.removeCustomTask(id: pendingTask.id)
        appStore.completedTaskIDs.remove(pendingTask.id)
        parentSecurityStore.clearVerification()
        editorMode = nil
        taskPendingRemoval = nil
        showRemovalAlert = false
    }

    private var removalMessage: String {
        guard let pendingTask = taskPendingRemoval else {
            return "This custom task will be permanently removed."
        }
        return "This will permanently remove the custom task \(pendingTask.title)."
    }

    private func isCompleted(_ task: StudyTask) -> Bool {
        appStore.completedTaskIDs.contains(task.id)
    }

    private func tagLabel(title: String, color: Color) -> some View {
        Text(title)
            .font(.caption.weight(.heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func taskEditor(_ mode: TaskEditorMode) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text(mode == .create ? "Create a task" : "Edit task")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(AppTheme.skyDark)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Task name")
                        .font(.headline)
                        .foregroundStyle(AppTheme.skyDark)
                    TextField("Enter the task title", text: $editorTitle)
                        .foregroundStyle(.black)
                        .tint(.black)
                        .padding(14)
                        .background(AppTheme.cloud)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.sky.opacity(0.35), lineWidth: 2)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Reward coins")
                        .font(.headline)
                        .foregroundStyle(AppTheme.skyDark)
                    TextField("7", text: $editorCoins)
                        .keyboardType(.numberPad)
                        .foregroundStyle(.black)
                        .tint(.black)
                        .padding(14)
                        .background(AppTheme.cloud)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.sky.opacity(0.35), lineWidth: 2)
                        )
                        .onChange(of: editorCoins) { _, newValue in
                            editorCoins = String(newValue.filter(\.isNumber).prefix(2))
                        }
                }

                Text("Default tasks stay protected. Only custom tasks can be edited here.")
                    .foregroundStyle(AppTheme.ink.opacity(0.65))

                if case .edit(let task) = mode, !task.isDefault {
                    Button(role: .destructive) {
                        taskPendingRemoval = task
                        showRemovalAlert = true
                    } label: {
                        Label("Delete task", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.coral)
                }

                Spacer()
            }
            .padding(24)
            .background(screenBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.lime.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(mode == .create ? "New task" : "Edit task")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.skyDark)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        parentSecurityStore.clearVerification()
                        editorMode = nil
                    } label: {
                        Text("Cancel")
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let rewardCoins = Int(editorCoins) ?? 0

                        switch mode {
                        case .create:
                            routineStore.addCustomTask(title: editorTitle, rewardCoins: rewardCoins)
                        case .edit(let task):
                            routineStore.updateCustomTask(id: task.id, title: editorTitle, rewardCoins: rewardCoins)
                        }

                        parentSecurityStore.clearVerification()
                        editorMode = nil
                    } label: {
                        Text("Save")
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                }
            }
        }
    }
}

    private enum TaskEditorMode: Equatable {
    case create
    case edit(StudyTask)
}

private extension DailyTasksHubView {
    var screenBackground: AccentScreenBackground {
        AccentScreenBackground(accent: AppTheme.lime)
    }

    var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    var horizontalPadding: CGFloat {
        isCompactLayout ? 16 : 24
    }

    func nextTaskResetDate(from date: Date = Date(), calendar: Calendar = .current) -> Date {
        let startOfToday = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? date
    }

    func countdownText(until resetDate: Date, now: Date) -> String {
        let remaining = max(0, Int(resetDate.timeIntervalSince(now)))
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
