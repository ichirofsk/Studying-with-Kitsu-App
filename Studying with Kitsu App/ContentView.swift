import SwiftUI

struct ContentView: View {
    @State private var showUnit10 = false

    var body: some View {
        Group {
            if showUnit10 {
                Unit10NarrativeView(viewModel: Unit10NarrativeViewModel())
            } else {
                // Placeholder para a Unit 9 (evita dependências fora de escopo)
                Unit9TransitionPlaceholder()
            }
        }
        .onAppear {
            // Transição direta para a Unit 10 na próxima volta do runloop
            DispatchQueue.main.async {
                showUnit10 = true
            }
        }
    }
}

private struct Unit9TransitionPlaceholder: View {
    var body: some View {
        // Tela temporária/preta para representar a Unit 9 antes da transição
        Color.black.ignoresSafeArea()
    }
}

#Preview("iPad Pro 11-inch (Portrait)") {
    ContentView()
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
        .previewLayout(.fixed(width: 834, height: 1194))
}
