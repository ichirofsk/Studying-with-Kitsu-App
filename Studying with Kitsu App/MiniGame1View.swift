import SwiftUI

public struct MiniGame1View: View {

    @ObservedObject private var viewModel: MiniGame1ViewModel
    private let onFinished: () -> Void

    @State private var pulse: Bool = false
    @State private var dialogueImageName: String = "kitsuhappy1"

    public init(viewModel: MiniGame1ViewModel, onFinished: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            // Background mapped to leaves stage (with dynamic images for specific leaf counts)
            let bgName: String = {
                switch viewModel.qtdFolhas {
                case 45: return "m2"
                case 30: return "m3"
                case 15: return "m4"
                case 0:  return "m5"
                default: return stageForLeaves(viewModel.qtdFolhas).imageName
                }
            }()
            Image(bgName)
                .resizable()
                .scaledToFit()
                .overlay(initialFocusOverlay)

            // Dialogue area (20% bottom) when not in focus animation
            if case .dialogue = viewModel.phase {
                bottomDialogue
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Fade to black when finished (do not navigate)
            if viewModel.showFadeOut {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.8), value: viewModel.showFadeOut)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if case .focusAnimation = viewModel.phase {
                // Stop local pulse animation; ViewModel handles state change to dialogue(index: 0)
                pulse = false
            }
            viewModel.handleTap()
        }
        .onAppear {
            startPulse()
        }
        .onChange(of: viewModel.showFadeOut) { _, newValue in
            if newValue {
                onFinished()
            }
        }
        .onChange(of: viewModel.phase) { _, newPhase in
            handlePhaseChange(newPhase)
        }
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(((viewModel.phase == .playing) && viewModel.isMicrofoneBeingActivated) ? Color.green : Color.gray.opacity(0.4))
                .frame(width: 10, height: 10)
                .accessibilityLabel(Text("Activity indicator"))
            .padding([.top, .trailing], 12)
        }
        .overlay(alignment: .top) {
            let showTopBar: Bool = {
                switch viewModel.phase {
                case .playing, .finished: return true
                default: return false
                }
            }()
            if showTopBar {
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geo in
                        let barWidth = geo.size.width * 0.75
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                                .frame(width: barWidth, height: 8)

                            let total = Double(MiniGame1Config.initialLeaves)
                            let progress = 1.0 - max(0.0, min(1.0, Double(viewModel.qtdFolhas) / total))
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.limeDark, AppTheme.coral, AppTheme.sunflower],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: barWidth * progress, height: 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(height: 8)

                    Text("Kid safety")
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 16)
                .padding(.top, 28)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.35), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: - Initial focus overlay
    private var initialFocusOverlay: some View {
        Group {
            if case .focusAnimation = viewModel.phase {
                GeometryReader { proxy in
                    let size = min(proxy.size.width, proxy.size.height) * 0.35
                    ZStack {
                        // Dim background only during focus
                        Color.black.opacity(0.6)
                            .blendMode(.multiply)
                            .ignoresSafeArea()

                        // Spotlight hole, slightly lower
                        Circle()
                            .frame(width: size * (pulse ? 1.15 : 0.85), height: size * (pulse ? 1.15 : 0.85))
                            .offset(y: size * 0.4)
                            .blendMode(.destinationOut)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
                    }
                    .compositingGroup() // needed for destinationOut
                }
            } else {
                // No overlay outside the focus phase
                Color.clear
            }
        }
    }

    // MARK: - Bottom dialogue
    private var bottomDialogue: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let panelHeight = height * 0.20
            VStack(spacing: 0) {
                Spacer()
                HStack(alignment: .center, spacing: 12) {
                    // Mascot image from Assets on the left, circular
                    Image(dialogueImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: panelHeight, height: panelHeight)
                        .clipShape(Circle())
                        .padding(.leading, -14)

                    // Dialogue text (pixel-art) on the right
                    Text(viewModel.currentDialogue ?? "")
                        .font(.custom("PressStart2P-Regular", size: 18, relativeTo: .title3))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.85), radius: 4, x: 0, y: 1)
                        .padding(.trailing, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onAppear {
                    if case let .dialogue(index) = viewModel.phase {
                        if index < MiniGame1Dialogue.initialImageNames.count {
                            dialogueImageName = MiniGame1Dialogue.initialImageNames[index]
                        } else {
                            dialogueImageName = "kitsuhappy1"
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if case let .dialogue(currentIndex) = viewModel.phase, currentIndex == index {
                                if index < MiniGame1Dialogue.swappedImageNames.count {
                                    dialogueImageName = MiniGame1Dialogue.swappedImageNames[index]
                                }
                            }
                        }
                    }
                }
                .onChange(of: viewModel.phase) { _, newPhase in
                    guard case let .dialogue(index) = newPhase else { return }
                    // Set initial image for this dialogue
                    if index < MiniGame1Dialogue.initialImageNames.count {
                        dialogueImageName = MiniGame1Dialogue.initialImageNames[index]
                    } else {
                        dialogueImageName = "kitsuhappy1"
                    }
                    // Swap shortly after appearing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if case let .dialogue(currentIndex) = viewModel.phase, currentIndex == index {
                            if index < MiniGame1Dialogue.swappedImageNames.count {
                                dialogueImageName = MiniGame1Dialogue.swappedImageNames[index]
                            }
                        }
                    }
                }
                .frame(height: panelHeight)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.86), Color.black.opacity(0.28)]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func startPulse() {
        pulse = true
    }

    private func handlePhaseChange(_ phase: MiniGame1Phase) {
        if case .playing = phase {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                viewModel.isMicrofoneBeingActivated = true
            }
        } else {
            viewModel.isMicrofoneBeingActivated = false
        }
    }
}

#Preview {
    MiniGame1View(viewModel: MiniGame1ViewModel(), onFinished: {})
}

private extension MiniGame1View {
    // Nome da imagem de fundo baseado no valor de qtdFolhas.
    // Ajuste o padrão de nome conforme os seus assets (ex.: "folhas_0", "folhas_1", ...).
    func backgroundImageName(for qtdFolhas: Int) -> String {
        return "folhas_\(qtdFolhas)"
    }
    // Background em tela cheia: preto por trás, imagem centralizada no tamanho original,
    // e um gradiente por cima para acabamento.
    @ViewBuilder
    func backgroundView(qtdFolhas: Int) -> some View {
        ZStack {
            // Preenche toda a tela com preto
            Color.black
                .ignoresSafeArea()

            // Imagem no tamanho original (sem .resizable()), centralizada
            Image(backgroundImageName(for: qtdFolhas))
                .accessibilityHidden(true)

            // Gradiente superior -> inferior para dar profundidade
            LinearGradient(
                colors: [Color.black.opacity(0.7), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}
