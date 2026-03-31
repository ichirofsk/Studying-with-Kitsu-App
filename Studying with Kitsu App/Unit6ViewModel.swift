import Foundation
import SwiftUI
import UIKit
import Combine

public enum Unit6Step: Equatable {
    case nameEntry
    case nameConfirmed
    case photoCapture
    case photoConfirmed
}

public struct Unit6Config {
    public static let cardCornerRadius: CGFloat = 12
    public static let cardPadding: CGFloat = 16
}

public final class Unit6ViewModel: ObservableObject {
    @Published public var step: Unit6Step = .nameEntry
    @Published public var nameInput: String = ""
    @Published public var capturedImage: UIImage? = nil
    @Published public var readyToAdvance: Bool = false
    
    public let onSaveName: (String) -> Void
    public let onSavePhoto: (UIImage) -> Void
    
    public init(onSaveName: @escaping (String) -> Void, onSavePhoto: @escaping (UIImage) -> Void) {
        self.onSaveName = onSaveName
        self.onSavePhoto = onSavePhoto
    }
    
    public func confirmName() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        step = .nameConfirmed
    }
    
    public func rewriteName() {
        step = .nameEntry
        nameInput = ""
    }
    
    public func nextAfterName() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSaveName(trimmed)
        step = .photoCapture
    }
    
    public func setCaptured(image: UIImage?) {
        capturedImage = image
        if image != nil {
            step = .photoConfirmed
        }
    }
    
    public func retakePhoto() {
        capturedImage = nil
        step = .photoCapture
    }
    
    public func nextAfterPhoto() {
        if let img = capturedImage {
            onSavePhoto(img)
            readyToAdvance = true
        }
    }
}
