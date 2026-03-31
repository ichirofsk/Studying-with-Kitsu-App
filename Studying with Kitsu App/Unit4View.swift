import SwiftUI

let unit4Title: String = "Unit 4"

public struct Unit4View: View {
    @ObservedObject private var viewModel: Unit4ViewModel
    private let onAdvance: () -> Void
    
    public init(viewModel: Unit4ViewModel, onAdvance: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onAdvance = onAdvance
    }
    
    @State private var blink = false
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top fixed area - 25% height
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1.5)
                        Text(viewModel.currentDialog.text)
                            .font(.custom("PressStart2P-Regular", size: 30))
                            .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 1)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .padding(16)
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
                    .frame(height: geo.size.height * 0.25)
                    
                    // Mascot image - 70% of remaining space below top area
                    let remainingHeight = geo.size.height * 0.75
                    Image(mascotImageNameForCurrentDialog())
                        .resizable()
                        .scaledToFit()
                        .frame(height: remainingHeight * 0.7)
                        .frame(maxWidth: .infinity)
                    
                    // Below mascot area - roughly 30% of remaining height
                    VStack {
                        if viewModel.isFirstDialog {
                            Text("Tap anywhere to skip")
                                .font(.custom("PressStart2P-Regular", size: 18))
                                .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
                                .foregroundColor(.white)
                                .opacity(blink ? 1 : 0)
                                .animation(.easeInOut(duration: Unit4Config.blinkDuration).repeatForever(autoreverses: true), value: blink)
                                .onAppear {
                                    blink = true
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 8)
                        } else if viewModel.isSecondDialog {
                            Button("Of course!") {
                                viewModel.tapOfCourse()
                            }
                            .font(.custom("PressStart2P-Regular", size: 20))
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                        } else if viewModel.isLastDialog {
                            Button("Please, lead us!") {
                                viewModel.tapPleaseLeadUs()
                            }
                            .font(.custom("PressStart2P-Regular", size: 30))
                            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                        }
                        Spacer()
                    }
                    .frame(height: remainingHeight * 0.3)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.handleTapAnywhere()
                }
            }
            .onChange(of: viewModel.readyToAdvance) { _, newValue in
                if newValue {
                    onAdvance()
                }
            }
        }
    }
    
    private func mascotImageNameForCurrentDialog() -> String {
        if viewModel.isFirstDialog { return "kit1" }
        else if viewModel.isSecondDialog { return "kit2" }
        else { return "kit3" }
    }
}

#Preview(traits: .portrait) {
    Unit4View(viewModel: Unit4ViewModel(), onAdvance: {})
}

