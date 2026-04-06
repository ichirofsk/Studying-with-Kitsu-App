import SwiftUI

struct KitsuPrimaryButton: View {
    let title: String
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(Color.white)
                .kitsuButtonTextShadow(active: isEnabled)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .frame(minWidth: 180)
                .background(isEnabled ? AppTheme.lime : Color.gray.opacity(0.6))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isEnabled ? AppTheme.limeDark : Color.gray, lineWidth: 2)
                )
                .shadow(color: isEnabled ? AppTheme.limeDark.opacity(0.35) : .clear, radius: 0, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}
