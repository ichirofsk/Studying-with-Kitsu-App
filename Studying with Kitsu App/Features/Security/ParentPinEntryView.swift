import SwiftUI

struct ParentPinEntryView: View {
    @ObservedObject var securityStore: ParentSecurityStore
    let title: String
    let message: String
    let onSuccess: () -> Void
    let onCancel: () -> Void

    @State private var pin = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            DashboardCard {
                VStack(alignment: .leading, spacing: 18) {
                    Text(title)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    Text(message)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(AppTheme.ink.opacity(0.72))

                    TextField("Enter 4 digits", text: $pin)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .padding(14)
                        .background(AppTheme.cloud)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.sky.opacity(0.35), lineWidth: 2)
                        )
                        .onChange(of: pin) { _, newValue in
                            pin = String(newValue.filter(\.isNumber).prefix(4))
                        }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.coral)
                    }

                    HStack(spacing: 12) {
                        Button("Cancel") {
                            onCancel()
                        }
                        .buttonStyle(.bordered)

                        KitsuPrimaryButton(title: "Unlock") {
                            if securityStore.verifyPIN(pin) {
                                errorMessage = nil
                                onSuccess()
                            } else {
                                errorMessage = "Incorrect PIN."
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 620)

            Spacer()
        }
        .padding(32)
    }
}
