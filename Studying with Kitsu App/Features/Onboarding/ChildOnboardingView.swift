import SwiftUI
import UIKit

struct ChildOnboardingView: View {
    @ObservedObject var childStore: ChildProfileStore
    @StateObject private var viewModel: Unit6ViewModel
    let onContinue: () -> Void
    let onCancel: () -> Void

    init(
        childStore: ChildProfileStore,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.childStore = childStore
        self.onContinue = onContinue
        self.onCancel = onCancel

        let viewModel = Unit6ViewModel(
            onSaveName: { name in
                childStore.updateName(name)
            },
            onSavePhoto: { image in
                childStore.updateAvatarData(image.pngData())
            }
        )
        viewModel.nameInput = childStore.profile.name
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Unit6View(viewModel: viewModel)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Child profile")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()

                    Button("Cancel") {
                        onCancel()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.coral)
                }

                Text("This screen reuses the old Unit6 flow as the real onboarding for the product.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onChange(of: viewModel.readyToAdvance) { _, newValue in
            if newValue {
                onContinue()
            }
        }
    }
}
