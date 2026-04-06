import SwiftUI
import UIKit

struct RewardsHubView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var appStore: AppStore
    @ObservedObject var childStore: ChildProfileStore
    @ObservedObject var rewardStore: RewardStore
    @ObservedObject var parentSecurityStore: ParentSecurityStore
    @State private var editorIndex: Int?
    @State private var editorText = ""
    @State private var editorSymbolName = "gift.fill"
    @State private var editorImageData: Data?
    @State private var pendingEditorIndex: Int?
    @State private var celebrationRewardCost: Int?
    @State private var celebrationDismissTask: Task<Void, Never>?
    @State private var showIconPicker = false
    @State private var showRewardCamera = false

    var body: some View {
        ZStack {
            screenBackground.ignoresSafeArea()

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

            if let celebrationRewardCost {
                rewardCelebration(cost: celebrationRewardCost)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
                    .zIndex(1)
                    .allowsHitTesting(false)
            }
        }
        .background(screenBackground.ignoresSafeArea())
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: celebrationRewardCost)
        .onDisappear {
            celebrationDismissTask?.cancel()
        }
        .dashboardBackSwipe {
            appStore.goToHome()
        }
        .sheet(isPresented: $showIconPicker) {
            rewardIconPicker
        }
        .sheet(isPresented: $showRewardCamera) {
            Unit6CameraPicker { image in
                editorImageData = image?.jpegData(compressionQuality: 0.85)
                showRewardCamera = false
            }
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
            VStack(alignment: .leading, spacing: 14) {
                backButton

                HStack(alignment: .top) {
                    headerCopy
                    Spacer(minLength: 12)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                backButton
                headerCopy
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
                        rewardTapArea(for: reward, index: index)

                        HStack(spacing: 10) {
                            Button {
                                guard appStore.canRedeem(reward) else { return }
                                appStore.redeem(reward)
                                showRewardCelebration(for: reward)
                            } label: {
                                Text(appStore.canRedeem(reward) ? "Redeem" : "Need more coins")
                                    .font(.headline.weight(.bold))
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

    private func rewardTapArea(for reward: RewardItem, index: Int) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(color(for: index).opacity(0.18))
                    .frame(width: 62, height: 62)
                rewardBadge(for: reward, index: index, size: 62)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(reward.title)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.ink)
                Text("Tap to edit")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(AppTheme.skyDark)
                Text("\(reward.cost) coins")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(color(for: index))
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            openEditor(for: reward, index: index)
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

    private func rewardCelebration(cost: Int) -> some View {
        let scale = celebrationScale(for: cost)

        return VStack(spacing: 10 * scale) {
            Image("kitsuhappy1")
                .resizable()
                .scaledToFit()
                .frame(width: 88 * scale, height: 88 * scale)

            Text("Congrats!")
                .font(.system(size: 22 * scale, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.skyDark)
                .shadow(color: Color.white.opacity(0.7), radius: 0, x: 0, y: 1)
        }
        .padding(.horizontal, 20 * scale)
        .padding(.vertical, 18 * scale)
        .background(
            RoundedRectangle(cornerRadius: 24 * scale, style: .continuous)
                .fill(AppTheme.cloud.opacity(0.96))
                .shadow(color: AppTheme.skyDark.opacity(0.16), radius: 18, x: 0, y: 10)
        )
    }

    private func rewardEditor(index: Int) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reward look")
                        .font(.headline)
                        .foregroundStyle(AppTheme.skyDark)

                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(color(for: index).opacity(0.18))
                                .frame(width: 82, height: 82)
                            rewardBadgePreview(index: index, size: 82)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Button {
                                showIconPicker = true
                            } label: {
                                Text("Choose icon")
                                    .kitsuButtonTextShadow()
                            }
                            .font(.headline.weight(.bold))
                            .buttonStyle(.bordered)

                            Button {
                                showRewardCamera = true
                            } label: {
                                Text("Take photo")
                                    .kitsuButtonTextShadow()
                            }
                            .font(.headline.weight(.bold))
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.skyDark)
                        }
                    }
                }

                Text("Reward title")
                    .font(.headline)
                    .foregroundStyle(AppTheme.skyDark)
                TextField("Enter a reward title", text: $editorText)
                    .foregroundStyle(.black)
                    .tint(.black)
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
            .background(screenBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.sunflower.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit reward")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppTheme.skyDark)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        parentSecurityStore.clearVerification()
                        editorIndex = nil
                    } label: {
                        Text("Cancel")
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let trimmed = editorText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty, rewardStore.rewards.indices.contains(index) else {
                            parentSecurityStore.clearVerification()
                            editorIndex = nil
                            return
                        }
                        rewardStore.rewards[index].title = trimmed
                        rewardStore.rewards[index].symbolName = editorSymbolName
                        rewardStore.rewards[index].imageData = editorImageData
                        parentSecurityStore.clearVerification()
                        editorIndex = nil
                    } label: {
                        Text("Save")
                            .kitsuButtonTextShadow()
                    }
                    .font(.headline.weight(.bold))
                }
            }
        }
    }

    private func openEditor(for reward: RewardItem, index: Int) {
        editorText = reward.title
        editorSymbolName = reward.symbolName ?? icon(for: index)
        editorImageData = reward.imageData
        if parentSecurityStore.hasConfiguredPIN && !parentSecurityStore.isParentVerified {
            pendingEditorIndex = index
        } else {
            editorIndex = index
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

    private func rewardBadge(for reward: RewardItem, index: Int, size: CGFloat) -> some View {
        Group {
            if let data = reward.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                Image(systemName: reward.symbolName ?? icon(for: index))
                    .font(.system(size: size * 0.38, weight: .black))
                    .foregroundStyle(color(for: index))
            }
        }
    }

    private func rewardBadgePreview(index: Int, size: CGFloat) -> some View {
        Group {
            if let data = editorImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                Image(systemName: editorSymbolName)
                    .font(.system(size: size * 0.38, weight: .black))
                    .foregroundStyle(color(for: index))
            }
        }
    }

    private var rewardIconPicker: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 14)], spacing: 14) {
                    ForEach(Self.rewardSymbolChoices, id: \.self) { symbol in
                        Button {
                            editorSymbolName = symbol
                            editorImageData = nil
                            showIconPicker = false
                        } label: {
                            Image(systemName: symbol)
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(AppTheme.skyDark)
                                .frame(width: 72, height: 72)
                                .background(AppTheme.cloud)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(symbol == editorSymbolName && editorImageData == nil ? AppTheme.skyDark : AppTheme.sky.opacity(0.35), lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
            }
            .background(screenBackground.ignoresSafeArea())
            .navigationTitle("Choose icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.sunflower.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showIconPicker = false
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
        return trimmed.isEmpty ? "your child" : trimmed
    }

    private var screenBackground: AccentScreenBackground {
        AccentScreenBackground(accent: AppTheme.sunflower)
    }

    private var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    private var horizontalPadding: CGFloat {
        isCompactLayout ? 16 : 24
    }

    private func showRewardCelebration(for reward: RewardItem) {
        celebrationDismissTask?.cancel()
        celebrationRewardCost = reward.cost
        celebrationDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            celebrationRewardCost = nil
        }
    }

    private func celebrationScale(for cost: Int) -> CGFloat {
        switch cost {
        case ..<10:
            return 1.0
        case 10..<20:
            return 1.15
        case 20..<35:
            return 1.3
        default:
            return 1.45
        }
    }

    private static let rewardSymbolChoices = [
        "star.fill",
        "gift.fill",
        "popcorn.fill",
        "figure.play",
        "gamecontroller.fill",
        "balloon.2.fill",
        "book.fill",
        "puzzlepiece.fill",
        "moon.stars.fill",
        "birthday.cake.fill",
        "sparkles",
        "heart.fill"
    ]
}
