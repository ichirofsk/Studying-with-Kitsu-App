import SwiftUI

struct DashboardCard<Content: View>: View {
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cloud)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.ink.opacity(0.08), lineWidth: 1.5)
            )
            .shadow(color: AppTheme.skyDark.opacity(0.12), radius: 0, x: 0, y: 6)
    }
}
