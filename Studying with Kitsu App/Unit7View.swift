import SwiftUI
import UIKit
import Combine

public struct Unit7View: View {
    @StateObject public var viewModel: Unit7ViewModel
    private let onGoToRewards: () -> Void
    @State private var didAwardCompletionistCoins = false
    @State private var tasksDisabledAfterBack = false
    @State private var dialogHintDelayPassed = false
    @State private var dialogHintPulse = false
    @State private var isRewardsEnabled = false
    
    public init(user: UserStore, onGoToRewards: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: Unit7ViewModel(user: user))
        self.onGoToRewards = onGoToRewards
    }

    public init(viewModel: Unit7ViewModel, onGoToRewards: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onGoToRewards = onGoToRewards
    }
    
    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.30, blue: 0.35), // red-ish
                    Color(red: 1.0, green: 0.60, blue: 0.75), // pink
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            switch viewModel.screen {
            case .menu:
                menuScreen
            case .tasks:
                tasksScreen
            }
            
            if viewModel.showCompletionistToast {
                completionistToast
            }
            
            if viewModel.screen == .menu {
                VStack { Spacer() }
                    .overlay(alignment: .bottomTrailing) {
                        Image("kitsufb1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 380)
                            .padding(0)
                            .zIndex(-1)
                            .offset(y: -280)
                            .offset(x: -80)
                    }
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text(viewModel.currentDateString)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 4) {
                Text("\(viewModel.user.coins)")
                    .fontWeight(.semibold)
                let bodySize = UIFont.preferredFont(forTextStyle: .body).pointSize
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: bodySize, height: bodySize)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding([.top, .horizontal])
    }
    
    // MARK: - Menu Screen (Screen 1)
    private var menuScreen: some View {
        VStack {
            header
            
            Text("Routine dashboard")
                .font(.system(size: 50, weight: .heavy))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 10)
                .shadow(color: Color(red: 1.0, green: 0.75, blue: 0.80).opacity(0.9), radius: 6, x: 0, y: 2)
            
            Spacer()
            
            Group {
                if let img = viewModel.user.capturedImage {
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 350, maxHeight: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        // Inner white border
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        // Outer pastel pink frame
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 1.0, green: 0.75, blue: 0.80), lineWidth: 4)
                        )
                } else {
                    Color.clear.frame(width: 200, height: 200)
                }
            }
            
            Text(viewModel.user.name)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            Spacer()
            
            HStack(spacing: 40) {
                Button {
                    viewModel.openTasks()
                    isRewardsEnabled = true
                } label: {
                    Image("task")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                }
                .frame(maxWidth: .infinity)
                .highlighted(viewModel.highlightTasks)
                .disabled(tasksDisabledAfterBack)
                
                Button {
                    onGoToRewards()
                } label: {
                    Image("reward")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                }
                .frame(maxWidth: .infinity)
                .highlighted(viewModel.highlightRewards)
                .disabled(!isRewardsEnabled)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .animation(.default, value: viewModel.highlightTasks)
    }
    
    // MARK: - Tasks Screen (Screen 2)
    private var tasksScreen: some View {
        ZStack {
            VStack(spacing: 12) {
                header
                
                Text("Today's tasks")
                    .font(.largeTitle.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .shadow(color: Color(red: 1.0, green: 0.75, blue: 0.80).opacity(0.9), radius: 6, x: 0, y: 2)
                
                Spacer()
                
                VStack(spacing: 20) {
                    taskButton(title: "Go to school", isEnabled: !viewModel.tasks.isTask1Disabled, action: viewModel.tapTask1)
                    taskButton(title: "Do homework", isEnabled: !viewModel.tasks.isTask2Disabled, action: viewModel.tapTask2)
                    taskButton(title: "Study session", isEnabled: !viewModel.tasks.isTask3Disabled, action: viewModel.tapTask3)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button("Back to dashboard") {
                    viewModel.backToMenu()
                    tasksDisabledAfterBack = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: 240)
                .disabled(!viewModel.canBackToMenu)
                .highlighted(viewModel.highlightBackToMenu)
                .padding(.bottom, 20)
            }
            .disabled(viewModel.showIntroDialog || viewModel.showCoinsDialog)
            
            if viewModel.showIntroDialog {
                introDialog
                    .onTapGesture {
                        viewModel.closeIntroDialogIfVisible()
                    }
            } else if viewModel.showCoinsDialog {
                coinsDialog
                    .onTapGesture {
                        viewModel.closeCoinsDialogIfVisible()
                    }
            }
            
            VStack { Spacer() }
                .overlay(alignment: .bottomTrailing) {
                    Image("kit2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 380)
                        .padding(0)
                        .zIndex(-1)
                        .offset(y: -600)
                        .offset(x: 500)
                }
                .allowsHitTesting(false)
        }
        .animation(.easeInOut, value: viewModel.showIntroDialog)
        .animation(.easeInOut, value: viewModel.showCoinsDialog)
        .animation(.easeInOut, value: viewModel.highlightBackToMenu)
        .animation(.easeInOut, value: viewModel.canBackToMenu)
    }
    
    private func taskButton(title: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("+7 coins")
                    .foregroundColor(.pink)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).stroke(isEnabled ? Color.black : Color.gray, lineWidth: 2))
        }
        .disabled(!isEnabled)
        .foregroundColor(isEnabled ? .primary : .gray)
    }
    
    private var introDialog: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 15) {
                Text("This is where the caregiver tracks the day's milestones. Imagine that \(viewModel.user.name) went to school, did homework, and had a study moment. Check the tasks to record the routine progress.")
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.ink)
                
                if viewModel.showTapToCloseHint || dialogHintDelayPassed {
                    Text("Tap anywhere to close")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .opacity(dialogHintPulse ? 1 : 0.35)
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: dialogHintPulse)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 4)
            )
            .padding(40)
            .onAppear {
                dialogHintDelayPassed = false
                dialogHintPulse = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    dialogHintDelayPassed = true
                }
            }
            .onDisappear {
                dialogHintDelayPassed = false
                dialogHintPulse = false
            }
        }
    }
    
    private var coinsDialog: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 15) {
                Text("Great job! You earned 24 coins today. They help turn consistency into rewards, so it is worth coming back every day to log the routine.")
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.ink)
                
                if viewModel.showTapToCloseHint || dialogHintDelayPassed {
                    Text("Tap anywhere to close")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .opacity(dialogHintPulse ? 1 : 0.35)
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: dialogHintPulse)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 4)
            )
            .padding(40)
            .onAppear {
                dialogHintDelayPassed = false
                dialogHintPulse = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    dialogHintDelayPassed = true
                }
            }
            .onDisappear {
                dialogHintDelayPassed = false
                dialogHintPulse = false
            }
        }
    }
    
    private var completionistToast: some View {
        Text("+3 consistency bonus!")
            .font(.title2.weight(.bold))
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.limeDark.opacity(0.9)))
            .foregroundColor(.white)
            .shadow(radius: 6)
            .transition(.opacity)
            .zIndex(1)
            .onAppear {
                if !didAwardCompletionistCoins {
                    viewModel.user.coins += 3
                    didAwardCompletionistCoins = true
                }
            }
            .onDisappear {
                didAwardCompletionistCoins = false
            }
    }
}

// MARK: - HighlightPulse ViewModifier and extension

private struct HighlightPulse: ViewModifier {
    @State private var pulse = false
    var isHighlighted: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHighlighted && pulse ? 1.12 : 1.0)
            .shadow(color: isHighlighted ? Color.yellow.opacity(pulse ? 1.0 : 0.5) : .clear, radius: 18, x: 0, y: 0)
            .zIndex(isHighlighted ? 1 : 0)
            .animation(isHighlighted ? Animation.easeInOut(duration: 1).repeatForever(autoreverses: true) : .default, value: pulse)
            .onAppear {
                if isHighlighted {
                    pulse = true
                } else {
                    pulse = false
                }
            }
            .onChange(of: isHighlighted) { newValue in
                pulse = newValue
            }
    }
}

private extension View {
    @ViewBuilder
    func highlighted(_ flag: Bool) -> some View {
        if flag {
            self.modifier(HighlightPulse(isHighlighted: true))
        } else {
            self
        }
    }
}

// MARK: - Unit7Images helper type

public enum Unit7Images {
    public static var blackPNG: Data {
        // Generate a 1x1 black PNG using UIKit drawing APIs
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.black.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.pngData() ?? Data()
    }
}

// MARK: - Preview

#if DEBUG
import UIKit

struct Unit7View_Previews: PreviewProvider {
    static var previews: some View {
        let userStore = UserStore(name: "Alice",
                                  coins: 12,
                                  imageData: Unit7Images.blackPNG)
        Unit7View(user: userStore) {
            // onGoToRewards closure no-op
        }
        .previewDevice("iPhone 14")
    }
}
#endif
