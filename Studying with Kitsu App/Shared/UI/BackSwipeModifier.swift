import SwiftUI

private struct BackSwipeModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .leading) {
                Color.clear
                    .frame(width: 28)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 24)
                            .onEnded { value in
                                let horizontal = value.translation.width
                                let vertical = abs(value.translation.height)
                                
                                guard horizontal > 90, vertical < 80 else { return }
                                action()
                            }
                    )
            }
            }
    }
    
    extension View {
        func dashboardBackSwipe(action: @escaping () -> Void) -> some View {
            modifier(BackSwipeModifier(action: action))
        }
    }

