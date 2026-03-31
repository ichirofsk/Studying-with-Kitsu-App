import Foundation
import SwiftUI
import Combine

public final class UserStore: ObservableObject {
    @Published public var name: String
    @Published public var coins: Int
    @Published private var imageData: Data?

    public init(name: String, coins: Int = 0, imageData: Data? = nil) {
        self.name = name
        self.coins = coins
        self.imageData = imageData
    }

    public var capturedImage: Image? {
#if canImport(UIKit)
        if let data = imageData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

    public func addCoins(_ amount: Int) {
        coins += amount
    }

    public func setPhoto(_ imageData: Data?) {
        self.imageData = imageData
    }
}

public struct DailyTaskTracker: Equatable {
    public var isTask1Disabled: Bool
    public var isTask2Disabled: Bool
    public var isTask3Disabled: Bool

    private var bonusGrantedThisDay: Bool
    private var dayIdentifier: DateComponents
    private var bonusEligibleThisDay: Bool = false

    public let perTaskReward: Int
    public let fullCompletionBonus: Int

    public init(isTask1Disabled: Bool = false,
                isTask2Disabled: Bool = false,
                isTask3Disabled: Bool = false,
                bonusGrantedThisDay: Bool = false,
                dayIdentifier: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date()),
                perTaskReward: Int = 7,
                fullCompletionBonus: Int = 3) {
        self.isTask1Disabled = isTask1Disabled
        self.isTask2Disabled = isTask2Disabled
        self.isTask3Disabled = isTask3Disabled
        self.bonusGrantedThisDay = bonusGrantedThisDay
        self.dayIdentifier = dayIdentifier
        self.perTaskReward = perTaskReward
        self.fullCompletionBonus = fullCompletionBonus
    }

    public mutating func ensureCurrent(calendar: Calendar = .current, date: Date = .init()) {
        let currentDayId = calendar.dateComponents([.year, .month, .day], from: date)
        if currentDayId != dayIdentifier {
            isTask1Disabled = false
            isTask2Disabled = false
            isTask3Disabled = false
            bonusGrantedThisDay = false
            bonusEligibleThisDay = false
            dayIdentifier = currentDayId
        }
    }

    public mutating func completeTask1(user: inout UserStore) {
        guard !isTask1Disabled else { return }
        isTask1Disabled = true
        user.addCoins(perTaskReward)
        updateBonusEligibility()
    }

    public mutating func completeTask2(user: inout UserStore) {
        guard !isTask2Disabled else { return }
        isTask2Disabled = true
        user.addCoins(perTaskReward)
        updateBonusEligibility()
    }

    public mutating func completeTask3(user: inout UserStore) {
        guard !isTask3Disabled else { return }
        isTask3Disabled = true
        user.addCoins(perTaskReward)
        updateBonusEligibility()
    }

    private mutating func updateBonusEligibility() {
        if isTask1Disabled && isTask2Disabled && isTask3Disabled && !bonusGrantedThisDay {
            bonusEligibleThisDay = true
        }
    }

    public mutating func grantFullCompletionBonusIfEligible(user: inout UserStore) {
        if bonusEligibleThisDay && !bonusGrantedThisDay {
            bonusGrantedThisDay = true
            bonusEligibleThisDay = false
            user.addCoins(fullCompletionBonus)
        }
    }
}

extension Data {
    #if canImport(UIKit)
    /// Returns a PNG Data representing a black image of given size using UIGraphicsImageRenderer.
    public static func blackPNG(size: CGSize = CGSize(width: 800, height: 800)) -> Data {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        return img.pngData() ?? Data()
    }
    #else
    public static func blackPNG(size: CGSize = CGSize(width: 800, height: 800)) -> Data {
        return Data()
    }
    #endif
}
struct Unit7PlaceholderView: View {
    var onResetCoinsForUnit7: () -> Void = {}

    var body: some View {
        VStack {
            Button("Next") {
                onResetCoinsForUnit7()
                // Note: advancing to Unit 7 is handled by higher-level navigation (AppState)
            }
        }
    }
}

