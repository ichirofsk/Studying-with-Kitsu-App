import SwiftUI

public struct NarrativeView: View {
    @ObservedObject private var viewModel: NarrativeViewModel
    private let onFollowKitsu: () -> Void

    @State private var showBlink: Bool = true

    public init(viewModel: NarrativeViewModel, onFollowKitsu: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onFollowKitsu = onFollowKitsu
    }

    public var body: some View {
        ZStack {
            // Black background across the entire screen
            Color.black.ignoresSafeArea()

            // Full screen tappable area to advance dialog when not on last page
            content
                .contentShape(Rectangle())
                .onTapGesture {
                    if !viewModel.isOnLastPage {
                        viewModel.advanceIfPossible()
                    }
                }
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.canGoBack {
                    Button(action: { viewModel.goBackIfPossible() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Previous dialogue")
                        }
                        .font(.custom("PressStart2P-Regular", size: 18))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding([.leading, .bottom])
        }
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 0) {
                if viewModel.isOnLastPage {
                    Button(action: onFollowKitsu) {
                        Text("Follow Kitsu")
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding([.trailing, .bottom])
        }
    }

    private var content: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let topPanelHeight = height * 0.25 // top 25% for dialog panel

            VStack(spacing: 0) {
                // Dialog panel (Unit4View-style container)
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                    Text(viewModel.pages[viewModel.currentIndex].text)
                        .font(.custom("PressStart2P-Regular", size: 30))
                        .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 1)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .frame(height: topPanelHeight)
                .padding(.horizontal)
                .padding(.top)

                // Mascot image occupies ~70% of remaining area
                let remainingHeight = height - topPanelHeight
                let mascotHeight = remainingHeight * 0.70

                VStack(spacing: 8) {
                    Image(viewModel.pages[viewModel.currentIndex].mascotImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: mascotHeight)

                    // Blinking hint until the last page
                    if !viewModel.isOnLastPage {
                        Text("Tap anywhere to skip")
                            .font(.custom("PressStart2P-Regular", size: 18))
                            .foregroundColor(.white.opacity(showBlink ? 1.0 : 0.2))
                            .onAppear { startBlinking() }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func startBlinking() {
        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            showBlink.toggle()
        }
    }
}

#Preview {
    NarrativeView(viewModel: NarrativeViewModel()) { }
}
