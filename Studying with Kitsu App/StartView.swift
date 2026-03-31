import SwiftUI

struct StartView: View {
    let viewModel: StartViewModel
    let onBegin: () -> Void
    var onResetCoins: () -> Void = {}
    var buttonTitle: String = "Begin"

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("mainback")
                .resizable()
                .scaledToFit()
                .padding(40)
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("Tap Start to 'start to enjoy this playground.")
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 8)

                Button(action: {
                    onResetCoins()
                    onBegin()
                }) {
                    Image("start")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .accessibilityLabel(Text(buttonTitle))
                }
                .buttonStyle(.plain)
                .tint(.white)
                .padding(.bottom, 24)
            }
            .padding()
        }
    }
}

#Preview {
    StartView(viewModel: StartViewModel(appState: AppState()), onBegin: {})
}
