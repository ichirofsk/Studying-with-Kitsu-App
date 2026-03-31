import SwiftUI
import UIKit
import Combine

public struct Unit6View: View {
    @ObservedObject private var viewModel: Unit6ViewModel
    @State private var showCamera = false
    var onResetCoinsForUnit7: () -> Void = {}

    private var isCameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return UIImagePickerController.isSourceTypeAvailable(.camera)
        #endif
    }

    public init(viewModel: Unit6ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                content
            }
            .padding(Unit6Config.cardPadding)
            .frame(maxWidth: 480)
            .background(
                RoundedRectangle(cornerRadius: Unit6Config.cardCornerRadius)
                    .fill(Color.white)
            )
            .padding()
        }
        .sheet(isPresented: $showCamera) {
            if isCameraAvailable {
                Unit6CameraPicker { image in
                    viewModel.setCaptured(image: image)
                    showCamera = false
                }
            } else {
                // Fallback content is empty because we set a mock image instead of presenting
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.step {
        case .nameEntry:
            VStack(alignment: .leading, spacing: 12) {
                Text("Kid name:")
                    .font(.headline)
                    .foregroundColor(.black)
                TextField("Enter name", text: $viewModel.nameInput)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding(10)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(8)

                HStack {
                    Button("Rewrite") {
                        viewModel.rewriteName()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Next") {
                        viewModel.nextAfterName()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

        case .nameConfirmed:
            VStack(alignment: .leading, spacing: 12) {
                Text("Kid name:")
                    .font(.headline)
                    .foregroundColor(.black)
                Text(viewModel.nameInput)
                    .font(.title3)
                    .foregroundColor(.black)

                HStack {
                    Button("Rewrite") {
                        viewModel.rewriteName()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Next") {
                        viewModel.nextAfterName()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

        case .photoCapture:
            VStack(alignment: .center, spacing: 12) {
                Text("Kid photo")
                    .font(.headline)
                    .foregroundColor(.black)

                Button("Open camera") {
                    if isCameraAvailable {
                        showCamera = true
                    } else {
                        // Create a solid black mock image for environments without camera (simulator/preview)
                        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 800))
                        let blackImage = renderer.image { ctx in
                            UIColor.black.setFill()
                            ctx.fill(CGRect(x: 0, y: 0, width: 800, height: 800))
                        }
                        viewModel.setCaptured(image: blackImage)
                    }
                }
                .buttonStyle(.borderedProminent)

                if let img = viewModel.capturedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                HStack {
                    Button("Retake photo") {
                        viewModel.retakePhoto()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.capturedImage == nil)

                    Spacer()

                    Button("Next") {
                        viewModel.nextAfterPhoto()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.capturedImage == nil)
                }
            }

        case .photoConfirmed:
            VStack(alignment: .center, spacing: 12) {
                if let img = viewModel.capturedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.15))
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.gray)
                            .padding(40)
                    }
                    .frame(maxHeight: 260)
                }

                HStack {
                    Button("Retake photo") {
                        viewModel.retakePhoto()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Next") {
                        onResetCoinsForUnit7()
                        // Note: advancing to Unit 7 is handled by higher-level navigation (AppState)
                        viewModel.nextAfterPhoto()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

private struct Unit6PreviewContainer<Content: View>: View {
    @StateObject var vm: Unit6ViewModel
    let content: (Unit6ViewModel) -> Content

    init(_ vm: Unit6ViewModel, @ViewBuilder content: @escaping (Unit6ViewModel) -> Content) {
        _vm = StateObject(wrappedValue: vm)
        self.content = content
    }

    var body: some View {
        content(vm)
    }
}

#Preview("Name Entry") {
    Unit6PreviewContainer(
        Unit6ViewModel(
            onSaveName: { _ in /* preview no-op */ },
            onSavePhoto: { _ in /* preview no-op */ }
        )
    ) { vm in
        Unit6View(viewModel: vm)
    }
}
#Preview("Name Confirmed") {
    let vm = Unit6ViewModel(
        onSaveName: { _ in /* preview no-op */ },
        onSavePhoto: { _ in /* preview no-op */ }
    )
    vm.nameInput = "Alice"
    vm.step = .nameConfirmed
    return Unit6PreviewContainer(vm) { containerVM in
        Unit6View(viewModel: containerVM)
    }
}

#Preview("Photo Confirmed (mock image)") {
    let vm = Unit6ViewModel(
        onSaveName: { _ in /* preview no-op */ },
        onSavePhoto: { _ in /* preview no-op */ }
    )
    // Create a non-optional mock image to avoid preview crashes
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
    let mockImage = renderer.image { ctx in
        UIColor.lightGray.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        // Draw a simple person icon placeholder
        let circleRect = CGRect(x: 50, y: 40, width: 100, height: 100)
        ctx.cgContext.setFillColor(UIColor.white.cgColor)
        ctx.cgContext.fillEllipse(in: circleRect)
        let bodyRect = CGRect(x: 35, y: 130, width: 130, height: 50)
        let bodyPath = UIBezierPath(roundedRect: bodyRect, cornerRadius: 25)
        ctx.cgContext.addPath(bodyPath.cgPath)
        ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
        ctx.cgContext.fillPath()
    }
    vm.setCaptured(image: mockImage)
    vm.step = .photoConfirmed
    return Unit6PreviewContainer(vm) { containerVM in
        Unit6View(viewModel: containerVM)
    }
}

