import SwiftUI

struct ParentPinSetupView: View {
    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var errorMessage: String?
    let onSave: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            DashboardCard {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Create a parent PIN")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppTheme.ink)

                    Text("Before the study journey begins, create a 4-digit PIN for parent-only areas like child management and reward editing.")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(AppTheme.ink.opacity(0.72))

                    pinField(title: "Parent PIN", text: $pin)
                    pinField(title: "Confirm PIN", text: $confirmPin)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.coral)
                    }
                }
            }
            .frame(maxWidth: 620)

            KitsuPrimaryButton(title: "Save PIN") {
                let sanitizedPin = sanitize(pin)
                let sanitizedConfirm = sanitize(confirmPin)

                guard sanitizedPin.count == 4, sanitizedConfirm.count == 4 else {
                    errorMessage = "The PIN must contain exactly 4 digits."
                    return
                }

                guard sanitizedPin == sanitizedConfirm else {
                    errorMessage = "The PINs do not match."
                    return
                }

                errorMessage = nil
                onSave(sanitizedPin)
            }

            Spacer()
        }
        .padding(32)
    }

    private func pinField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            TextField("0000", text: text)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .padding(14)
                .background(AppTheme.cloud)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.sky.opacity(0.35), lineWidth: 2)
                )
                .onChange(of: text.wrappedValue) { _, newValue in
                    text.wrappedValue = sanitize(newValue)
                }
        }
    }

    private func sanitize(_ value: String) -> String {
        String(value.filter(\.isNumber).prefix(4))
    }
}
