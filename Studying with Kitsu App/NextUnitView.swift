import SwiftUI
import Combine

public final class NextUnitViewModel: ObservableObject {
    private let appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public func goToStart() {
        appState.currentUnit = .start
    }
}

public struct NextUnitView: View {
    @ObservedObject private var viewModel: NextUnitViewModel

    public init(viewModel: NextUnitViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Next Unit")
                    .font(.largeTitle)
                Text("Conteúdo da próxima unidade lógica aqui.")
                    .foregroundColor(.secondary)

                Button("Voltar ao início") {
                    viewModel.goToStart()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    // Preview with a temporary AppState
    let state = AppState(currentUnit: .nextUnit)
    return NextUnitView(viewModel: NextUnitViewModel(appState: state))
}
