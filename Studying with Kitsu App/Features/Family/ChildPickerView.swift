import SwiftUI
import UIKit

struct ChildPickerView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ObservedObject var familyStore: FamilyStore
    @ObservedObject var appStore: AppStore
    @ObservedObject var parentSecurityStore: ParentSecurityStore
    @State private var childPendingRemoval: FamilyChild?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                DashboardCard {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 16) {
                            headerCopy
                            Spacer(minLength: 12)
                            headerArt
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            headerCopy
                            headerArt
                        }
                    }
                }

                VStack(spacing: 14) {
                    ForEach(familyStore.children) { child in
                        childCard(child)
                    }
                }

                KitsuPrimaryButton(title: "Add child") {
                    familyStore.createChildDraft()
                    appStore.goToOnboarding()
                }
            }
            .frame(maxWidth: 980)
            .padding(horizontalPadding)
            .frame(maxWidth: .infinity)
        }
        .confirmationDialog(
            "Remove child profile?",
            isPresented: Binding(
                get: { childPendingRemoval != nil },
                set: { isPresented in
                    if !isPresented {
                        childPendingRemoval = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            if let pendingChild = childPendingRemoval {
                Button("Remove \(displayName(for: pendingChild))", role: .destructive) {
                    familyStore.removeChild(pendingChild.id)
                    childPendingRemoval = nil
                    if familyStore.hasChildren {
                        appStore.goToChildPicker()
                    } else {
                        appStore.prepareLaunchDestination(hasChildren: false, hasActiveChild: false)
                    }
                }
            }

            Button("Cancel", role: .cancel) {
                childPendingRemoval = nil
            }
        } message: {
            if let pendingChild = childPendingRemoval {
                Text("This will permanently remove \(displayName(for: pendingChild)) and all saved routine, reward, and progress data for this child.")
            }
        }
    }

    private func childCard(_ child: FamilyChild) -> some View {
        let progress = familyStore.progressSnapshot(for: child.id)
        let profile = familyStore.profileSnapshot(for: child.id)
        let resolvedName = resolvedName(for: child, profile: profile)
        let resolvedStage = resolvedStage(for: child, profile: profile)
        let resolvedAvatar = profile.avatarImageData ?? child.avatarImageData

        return DashboardCard {
            if isCompactLayout {
                VStack(alignment: .leading, spacing: 14) {
                    childMainContent(
                        resolvedAvatar: resolvedAvatar,
                        resolvedName: resolvedName,
                        resolvedStage: resolvedStage,
                        progress: progress
                    )
                    childActions(for: child)
                }
            } else {
                HStack(spacing: 16) {
                    childMainContent(
                        resolvedAvatar: resolvedAvatar,
                        resolvedName: resolvedName,
                        resolvedStage: resolvedStage,
                        progress: progress
                    )
                    Spacer()
                    childActions(for: child)
                }
            }
        }
    }

    private var headerCopy: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your children")
                .font(.system(size: isCompactLayout ? 28 : 32, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.ink)
            Text("Switch between child profiles, add a new learner, and follow each study journey individually.")
                .font(.title3.weight(.medium))
                .foregroundStyle(AppTheme.ink.opacity(0.72))
        }
    }

    private var headerArt: some View {
        Image("kitsufb1")
            .resizable()
            .scaledToFit()
            .frame(width: isCompactLayout ? 84 : 110, height: isCompactLayout ? 84 : 110)
    }

    private func childMainContent(
        resolvedAvatar: Data?,
        resolvedName: String,
        resolvedStage: String,
        progress: AppProgressSnapshot
    ) -> some View {
        HStack(spacing: 16) {
            avatar(for: resolvedAvatar)

            VStack(alignment: .leading, spacing: 6) {
                Text(resolvedName)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(AppTheme.ink)
                Text(resolvedStage)
                    .foregroundStyle(AppTheme.ink.opacity(0.65))
                if isCompactLayout {
                    VStack(alignment: .leading, spacing: 8) {
                        statChip(title: "Coins", value: "\(progress.earnedCoins)", color: AppTheme.sunflower)
                        statChip(title: "Streak", value: "\(progress.currentStreak)", color: AppTheme.coral)
                    }
                } else {
                    HStack(spacing: 10) {
                        statChip(title: "Coins", value: "\(progress.earnedCoins)", color: AppTheme.sunflower)
                        statChip(title: "Streak", value: "\(progress.currentStreak)", color: AppTheme.coral)
                    }
                }
            }
        }
    }

    private func childActions(for child: FamilyChild) -> some View {
        HStack(spacing: 10) {
            Button {
                childPendingRemoval = child
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.coral)
                    .padding(10)
                    .background(AppTheme.coral.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button("Open") {
                familyStore.selectChild(child.id)
                parentSecurityStore.clearVerification()
                appStore.goToHome()
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.limeDark)
        }
    }

    private func avatar(for imageData: Data?) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.sky.opacity(0.22))
                .frame(width: 72, height: 72)

            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(AppTheme.skyDark)
            }
        }
    }

    private func statChip(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
            Text(value)
                .font(.caption.weight(.heavy))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private func resolvedName(for child: FamilyChild, profile: ChildProfile) -> String {
        let profileName = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let childName = child.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !profileName.isEmpty { return profileName }
        if !childName.isEmpty { return childName }
        return "New child"
    }

    private func resolvedStage(for child: FamilyChild, profile: ChildProfile) -> String {
        let profileStage = profile.schoolStage.trimmingCharacters(in: .whitespacesAndNewlines)
        if !profileStage.isEmpty && profileStage != ChildProfile.empty.schoolStage {
            return profileStage
        }
        return child.schoolStage
    }

    private func displayName(for child: FamilyChild) -> String {
        let profile = familyStore.profileSnapshot(for: child.id)
        return resolvedName(for: child, profile: profile)
    }

    private var isCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    private var horizontalPadding: CGFloat {
        isCompactLayout ? 16 : 24
    }
}
