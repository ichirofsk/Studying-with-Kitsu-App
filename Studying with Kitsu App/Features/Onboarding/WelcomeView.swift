import SwiftUI

struct WelcomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            DashboardCard {
                VStack(spacing: 18) {
                    Image("mainback")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 340)

                    VStack(spacing: 12) {
                        Text("Kitsu Study Journey")
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppTheme.ink)

                        Text("An app that helps families turn study time into a steady routine with warmth, clarity, and small daily wins. First, the responsible adult sets a 4-digit PIN for parent-only areas.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppTheme.ink.opacity(0.75))
                            .frame(maxWidth: 620)
                    }
                }
            }
            .frame(maxWidth: 760)

            KitsuPrimaryButton(title: "Start setup", action: onStart)

            Spacer()
        }
        .padding(horizontalPadding)
    }

    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .compact ? 16 : 32
    }
}

#Preview {
    WelcomeView(onStart: {})
}
