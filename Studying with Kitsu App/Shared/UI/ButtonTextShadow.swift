import SwiftUI

extension View {
    func kitsuButtonTextShadow(active: Bool = true) -> some View {
        shadow(
            color: active ? Color.black.opacity(0.35) : .clear,
            radius: 1,
            x: 0,
            y: 1
        )
    }
}
