import SwiftUI

/// View for the Narrative Unit 10.
public struct Unit10NarrativeView: View {
    @ObservedObject private var viewModel: Unit10NarrativeViewModel
    
    public init(viewModel: Unit10NarrativeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch viewModel.model.phase {
            case .intro:
                introScreen
            case .motivation:
                motivationScreen
            case .thanks:
                thanksScreen
            case .finished:
                // Nothing visible; host may restart the app.
                Color.clear
            }
        }
    }
    
    // MARK: - Screens
    private var introScreen: some View {
        VStack(spacing: 16) {
            if viewModel.showMascot {
                // Placeholder mascot; replace with your asset if available
                Image("kitsuhappy1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .foregroundColor(.white)
            }
            
            Text(viewModel.introText)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.title3.weight(.semibold))
                .padding(.horizontal, 24)
        }
    }
    
    private var motivationScreen: some View {
        Text(viewModel.motivationText)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .font(.title3.weight(.semibold))
            .padding(.horizontal, 24)
    }

    private var thanksScreen: some View {
        Text(viewModel.thanksText)
            .foregroundColor(.white)
            .font(.largeTitle.weight(.bold))
            .multilineTextAlignment(.center)
            .padding()
    }
}

#Preview {
    Unit10NarrativeView(viewModel: Unit10NarrativeViewModel())
}
