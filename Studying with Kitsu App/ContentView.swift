import SwiftUI

struct ContentView: View {
    var body: some View {
        // Apresenta o fluxo 9 → 10. A transição para a Unidade 10
        // ocorre 3 segundos após a detecção da mão e exibição do sorvete.
        LocalUnitFlowContainer()
    }
}

private struct LocalUnitFlowContainer: View {
    @State private var showUnit10 = false
    @State private var hasScheduledTransition = false

    var body: some View {
        Group {
            if showUnit10 {
                Unit10View()
            } else {
                Unit9View(viewModel: Unit9ViewModel(userName: "Kid"))
                    .onReceive(NotificationCenter.default.publisher(for: .handDetected)) { _ in
                        guard !hasScheduledTransition else { return }
                        hasScheduledTransition = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                            showUnit10 = true
                        }
                    }
            }
        }
    }
}

#Preview("iPad Pro 11-inch (Portrait)") {
    ContentView()
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
        .previewLayout(.fixed(width: 834, height: 1194))
}

