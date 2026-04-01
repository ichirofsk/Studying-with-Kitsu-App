import SwiftUI

struct RewardsHubView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var appStore: AppStore
    @ObservedObject var childStore: ChildProfileStore
    @ObservedObject var rewardStore: RewardStore
    @ObservedObject var parentSecurityStore: ParentSecurityStore
    @State private var editorIndex: Int?
    @State private var editorText = ""
    @State private var pendingEditorIndex: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                summaryCard
                rewardsList
                footer
            }
            .frame(maxWidth: 980)
            .padding(horizontalPadding)
            .frame(maxWidth: .infinity)
        }
        .sheet(
            isPresented: Binding(
                get: { editorIndex != nil },
                set: { isPresented in
                    if !isPresented {
                        editorIndex = nil
                    }
                }
            )
        ) {
            if let index = editorIndex {
                rewardEditor(index: index)
            }
        }
        .sheet(
            isPresented: Binding(
                get: { pendingEditorIndex != nil },
                set: { isPresented in
                    if !isPresented {
                        pendingEditorIndex = nil
                    }
                }
            )
        ) {
            ParentPinEntryView(
                securityStore: parentSecurityStore,
                title: "Parent access",
                message: "Enter the parent PIN to edit rewards.",
                onSuccess: {
                    if let pendingEditorIndex {
                        editorIndex = pendingEditorIndex
                    }
                    pendingEditorIndex = nil
                },
                onCancel: {
                    pendingEditorIndex = nil
                }
            )
        }
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top) {
                headerCopy
                Spacer(minLength: 12)
                dashboardButton
            }

            VStack(alignment: .leading, spacing: 14) {
                headerCopy
                dashboardButton
            }
        }
    }

    private var summaryCard: some View {
        DashboardCard {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) {
                    summaryCopy
                    Spacer(minLength: 12)
                    summaryArt
                }

                VStack(alignment: .leading, spacing: 14) {
                    summaryCopy
                    summaryArt
                }
            }
        }
    }

    private var rewardsList: some View {
        VStack(spacing: 14) {
            ForEach(Array(rewardStore.rewards.enumerated()), id: \.element.id) { index, reward in
                DashboardCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .center, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(color(for: index).opacity(0.18))
                                    .frame(width: 62, height: 62)
                                Image(systemName: icon(for: index))
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundStyle(color(for: index))
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text(reward.title)
                                    .font(.title3.weight(.heavy))
                                    .foregroundStyle(AppTheme.ink)
                                Text("\(reward.cost) coins")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(color(for: index))
                            }

                            Spacer()
                        }

                        HStack(spacing: 10) {
                            Button("Edit") {
                                editorText = reward.title
                                if parentSecurityStore.hasConfiguredPIN && !parentSecurityStore.isParentVerified {
                                    pendingEditorIndex = index
                                } else {
                                    editorIndex = index
                                }
                            }
                            .buttonStyle(.bordered)

                            Button {
                                appStore.redeem(reward)
                            } label: {
                                Text(appStore.canRedeem(reward) ? "Redeem" : "Need more coins")
                                    .foregroundColor(appStore.canRedeem(reward) ? .primary : .white)
                                    .shadow(
                                        color: appStore.canRedeem(reward) ? .clear : Color.black.opacity(0.35),
                                        radius: 1,
                                        x: 0,
                                        y: 1
                                    )
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(appStore.canRedeem(reward) ? AppTheme.limeDark : Color.gray)
                            .disabled(!appStore.canRedeem(reward))
                        }
                        .frame(maxWidth: .infinity, alignment: isCompactLayout ? .leading : .trailing)
                    }
                }
            }
        }
    }

    private var footer: some View {
        Group {
            if isCompactLayout {
                VStack(spacing: 12) {
                    KitsuPrimaryButton(title: "Back to dashboard") {
                        appStore.goToHome()
                    }

                    secondaryCapsuleButton(title: "See progress") {
                        appStore.goToProgress()
                    }
                }
            } else {
                HStack(spacing: 12) {
                    KitsuPrimaryButton(title: "Back to dashboard") {
                        appStore.goToHome()
                    }

                    secondaryCapsuleButton(title: "See progress") {
                        appStore.goToProgress()
                    }
                }
            }
        }
    }

    private var headerCopy: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rewards")
                .font(.system(size: isCompactLayout ? 28 : 32, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text("Use coins to celebrate progress with playful, family-approved rewards.")
                .font(.title3.weight(.medium))
                .foregroundStyle(AppTheme.ink.opacity(0.72))
        }
    }

    private var dashboardButton: some View {
        Button("Dashboard") {
            appStore.goToHome()
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.skyDark)
    }

    private var summaryCopy: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Reward bank", systemImage: "gift.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.coral)
            Text("\(appStore.earnedCoins) coins available")
                .font(.system(size: isCompactLayout ? 24 : 28, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text("Choose a reward for \(displayName), or edit one so it fits your family's routine better.")
                .foregroundStyle(AppTheme.ink.opacity(0.72))
        }
    }

    private var summaryArt: some View {
        Image("reward")
            .resizable()
            .scaledToFit()
            .frame(width: isCompactLayout ? 78 : 94, height: isCompactLayout ? 78 : 94)
    }

    private func secondaryCapsuleButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.ink)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .frame(maxWidth: isCompactLayout ? .infinity : nil)
                .background(AppTheme.sunflower)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.orange.opacity(0.35), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private func rewardEditor(index: Int) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Reward title")
                    .font(.headline)
                TextField("Enter a reward title", text: $editorText)
                    .padding(14)
                    .background(AppTheme.cloud)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.sky.opacity(0.35), lineWidth: 2)
                    )

                Text("Keep it short, clear, and easy for the family to agree on.")
                    .foregroundStyle(AppTheme.ink.opacity(0.65))

                Spacer()
            }
            .padding(24)
            .background(AppTheme.cream.ignoresSafeArea())
            .navigationTitle("Edit reward")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        parentSecurityStore.clearVerification()
                        editorIndex = nil
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let trimmed = editorText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty, rewardStore.rewards.indices.contains(index) else {
                            parentSecurityStore.clearVerification()
                            editorIndex = nil
                            return
                        }
                        rewardStore.rewards[index].title = trimmed
                        parentSecurityStore.clearVerification()
                        editorIndex = nil
                    }
                }
            }
        }
    }

    private func icon(for index: Int) -> String {
        switch index {
        case 0: return "star.fill"
        case 1: return "popcorn.fill"
        case 2: return "figure.play"
        default: return "gift.fill"
        }
    }

    private func color(for index: Int) -> Color {
        switch index {
        case 0: return AppTheme.sunflower
        case 1: return AppTheme.skyDark
        case 2: return AppTheme.coral
        default: return AppTheme.limeDark
        }
    }

    private var displayName: String {
        let trimmed = childStore.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "your child" : trimmed
    }

    private var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    private var horizontalPadding: CGFloat {
        isCompactLayout ? 16 : 24
    }
}
