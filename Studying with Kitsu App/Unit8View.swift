import SwiftUI
import UIKit

public struct Unit8View: View {
    @ObservedObject public var viewModel: Unit8ViewModel
    private let onFinished: () -> Void

    @State private var showEditor = false
    @State private var editorTarget: Int? = nil
    @State private var editorText: String = ""
    @State private var editorError: String? = nil
    @FocusState private var editorFocused: Bool

    @State private var notEnoughMessageID: UUID? = nil

    @State private var dialogHintDelayPassed = false
    @State private var dialogHintPulse = false

    public init(viewModel: Unit8ViewModel, onFinished: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.30, blue: 0.35),
                    Color(red: 1.0, green: 0.60, blue: 0.75),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Text("Rewards")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)

                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        rewardRow(
                            title: .constant(viewModel.titles.button1),
                            priceLabel: "Quick reward - 24 coins",
                            isEnabled: true,
                            onTap: {
                                if viewModel.canRedeem1 && viewModel.areButtonsEnabled {
                                    if viewModel.redeemButton1() {
                                        onFinished()
                                    }
                                } else {
                                    showNotEnoughMessage(for: 1)
                                }
                            },
                            showEditPencil: false,
                            editAction: {
                                // Begin editing for button1 when editing is enabled
                                if viewModel.isEditingEnabled {
                                    editorTarget = 1
                                    editorText = viewModel.titles.button1
                                    showEditor = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        editorFocused = true
                                    }
                                }
                            },
                            rowIndex: 1
                        )
                        .highlighted(viewModel.highlightRedeemButton1)

                        rewardRow(
                            title: Binding(
                                get: { viewModel.titles.button2 },
                                set: { _ in }
                            ),
                            priceLabel: "Medium reward - 89 coins",
                            isEnabled: true,
                            onTap: {
                                showNotEnoughMessage(for: 2)
                            },
                            showEditPencil: viewModel.isEditingEnabled,
                            editAction: {
                                showEditor = viewModel.beginEditButton2()
                                if showEditor {
                                    editorTarget = 2
                                    editorText = viewModel.titles.button2
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        editorFocused = true
                                    }
                                }
                            },
                            highlighted: viewModel.highlightEditButton2,
                            editHighlighted: viewModel.highlightEditButton2,
                            rowIndex: 2
                        )

                        rewardRow(
                            title: Binding(
                                get: { viewModel.titles.button3 },
                                set: { _ in }
                            ),
                            priceLabel: "Special reward - 201 coins",
                            isEnabled: true,
                            onTap: {
                                showNotEnoughMessage(for: 3)
                            },
                            showEditPencil: false,
                            editAction: {
                                // No special action specified for button3 pencil
                            },
                            rowIndex: 3
                        )

                        rewardRow(
                            title: Binding(
                                get: { viewModel.titles.button4 },
                                set: { _ in }
                            ),
                            priceLabel: "Surprise reward - 311 coins",
                            isEnabled: true,
                            onTap: {
                                showNotEnoughMessage(for: 4)
                            },
                            showEditPencil: false,
                            editAction: {
                                // No special action specified for button4 pencil
                            },
                            rowIndex: 4
                        )
                    }
                    .padding(.horizontal)
                    Spacer()
                    Button("Back to dashboard") {
                        // Hook up to navigation if needed
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: 240)
                    .disabled(true)
                    .padding(.bottom, 20)
                }
            }

            // Not enough coins messages
            if let activeID = notEnoughMessageID {
                // Find which button to show under? Show under tapped row
                // To show the message below tapped row, we overlay in the List
                // Simplify: show overlay at bottom with offset to approximate location
                // Or, better: show the message below the row in the list by overlaying on list
                // Instead, we'll overlay near the bottom with opacity and fade out after timeout

                // We have no direct location info; approximation: show near bottom of list
                VStack {
                    Spacer()
                    Text("Not enough coins for this reward.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.bottom, 32)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: notEnoughMessageID)
            }

            // Dialog overlay
            if viewModel.dialogPhase != .none {
                ZStack {
                    Color.black.opacity(0.45).ignoresSafeArea()
                        .onTapGesture {
                            viewModel.tapBackground()
                        }

                    dialogView()
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(radius: 12)
                        )
                        .padding(.horizontal, 40)
                        .onTapGesture {
                            viewModel.tapBackground()
                        }
                        .onAppear {
                            dialogHintDelayPassed = false
                            dialogHintPulse = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                    dialogHintPulse.toggle()
                                }
                                dialogHintDelayPassed = true
                            }
                        }
                        .onDisappear {
                            dialogHintDelayPassed = false
                            dialogHintPulse = false
                        }
                }
                .transition(.opacity)
                .animation(.easeInOut, value: viewModel.dialogPhase)
            }

            // Editor dialog for button editing
            if showEditor {
                Color.black.opacity(0.45).ignoresSafeArea()
                    .onTapGesture {
                        // Do nothing on outside tap, must confirm or cancel via buttons
                    }

                VStack(spacing: 16) {
                    TextField("", text: $editorText)
                        .focused($editorFocused)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary))
                        .onChange(of: editorText) { oldValue, newValue in
                            if newValue.count > 25 {
                                editorText = String(newValue.prefix(25))
                                editorError = "You have reached the maximum number of characters."
                            } else {
                                editorError = nil
                            }
                        }

                    HStack {
                        Spacer()
                        Text("\(editorText.count)/25")
                            .font(.footnote)
                            .foregroundColor(editorError == nil ? .secondary : .red)
                    }

                    if let error = editorError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    HStack(spacing: 20) {
                        Button("Clear") {
                            editorText = ""
                            editorError = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                editorFocused = true
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("Confirm") {
                            let trimmed = editorText.trimmingCharacters(in: .whitespacesAndNewlines)
                            let finalTitle = String(trimmed.prefix(25))
                            switch editorTarget {
                            case 2:
                                viewModel.confirmEditButton2(newTitle: finalTitle)
                                viewModel.highlightEditButton2 = false
                            case 1:
                                viewModel.titles.button1 = finalTitle
                            case 3:
                                viewModel.titles.button3 = finalTitle
                            case 4:
                                viewModel.titles.button4 = finalTitle
                            default:
                                break
                            }
                            showEditor = false
                            editorError = nil
                            editorText = ""
                            editorTarget = nil
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(editorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 20)
                )
                .padding(40)
                .transition(.scale)
                .animation(.easeInOut, value: showEditor)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(viewModel.currentDateString)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 4) {
                Text("\(viewModel.user.coins)")
                    .fontWeight(.semibold)
                let bodySize = UIFont.preferredFont(forTextStyle: .body).pointSize
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: bodySize, height: bodySize)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding([.top, .horizontal])
    }

    @ViewBuilder
    private func rewardRow(
        title: Binding<String>,
        priceLabel: String,
        isEnabled: Bool,
        onTap: @escaping () -> Void,
        showEditPencil: Bool,
        editAction: (() -> Void)? = nil,
        highlighted: Bool = false,
        editHighlighted: Bool = false,
        rowIndex: Int = 0
    ) -> some View {
        VStack(spacing: 4) {
            VStack(alignment: .center, spacing: 8) {
                Button {
                    if isEnabled {
                        onTap()
                    }
                } label: {
                    HStack {
                        Text(title.wrappedValue)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(priceLabel)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isEnabled ? Color.black : Color.gray, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .highlighted(highlighted)
                .frame(maxWidth: .infinity)

                HStack {
                    Button {
                        if let editAction = editAction { editAction() }
                    } label: {
                        Label("Edit reward", systemImage: "pencil")
                            .font(.body)
                    }
                    .buttonStyle(.bordered)
                    .highlighted(editHighlighted)
                    .disabled(!viewModel.isEditingEnabled || editAction == nil)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            if notEnoughMessageID != nil && !isEnabled {
                // Show message only below the tapped row
                // We'll show the message only below rows 2,3,4 if their notEnoughMessageID matches their button number
                // We mark the message with UUID, so we can't map to Int reliably.
                // Instead, show only one message below the tapped row by filtering in showNotEnoughMessage.

                // This is handled in the main overlay to show only one message.
                // So no text here.
                EmptyView()
            }
        }
    }

    private func showNotEnoughMessage(for button: Int) {
        notEnoughMessageID = UUID()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                notEnoughMessageID = nil
            }
        }
    }

    @ViewBuilder
    private func dialogView() -> some View {
        VStack(spacing: 16) {
            Text(dialogText())
                .font(.body)
                .multilineTextAlignment(.center)

            if dialogHintDelayPassed {
                Text(dialogHintText())
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .opacity(dialogHintPulse ? 0.25 : 1)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: dialogHintPulse)
            }
        }
        .padding()
    }

    private func dialogText() -> String {
        switch viewModel.dialogPhase {
        case .introFirst(let step):
            return "This is where the family turns effort into rewards. Decide with \(viewModel.user.name) which prizes make sense to celebrate the study routine."
        case .introSecond:
            return "First, personalize the medium reward so it reflects something that motivates the child."
        case .postEdit(let step):
            switch step {
            case 0:
                return "Perfect. Personalized rewards make the agreement clearer for the family and more motivating for the child."
            case 1:
                return "Now imagine that \(viewModel.user.name) collected enough coins to exchange for a reward. Redeem one to complete this step."
            default:
                return ""
            }
        default:
            return ""
        }
    }

    private func dialogHintText() -> String {
        switch viewModel.dialogPhase {
        case .introFirst(let step):
            switch step {
            case 0: return "Tap anywhere to continue"
            case 1: return "Tap anywhere to close"
            default: return ""
            }
        case .introSecond:
            return "Tap anywhere to close"
        case .postEdit(let step):
            switch step {
            case 0: return "Tap anywhere to continue"
            case 1: return "Tap anywhere to close"
            default: return ""
            }
        default:
            return ""
        }
        
    }
}

// Highlighted modifier copied from Unit7
fileprivate struct Highlighted: ViewModifier {
    @State private var pulse = false
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.accentColor.opacity(pulse ? 1.0 : 0.6), radius: 22, x: 0, y: 0)
            .shadow(color: Color.accentColor.opacity(pulse ? 0.45 : 0.25), radius: 40, x: 0, y: 0)
            .shadow(color: Color.accentColor.opacity(pulse ? 0.25 : 0.15), radius: 70, x: 0, y: 0)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulse)
            .onAppear {
                pulse = true
            }
            .onDisappear {
                pulse = false
            }
    }
}

fileprivate struct ModifierEmpty: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
fileprivate extension View {
    @ViewBuilder
    func highlighted(_ flag: Bool) -> some View {
        if flag {
            self.modifier(Highlighted())
        } else {
            self
        }
    }
}
