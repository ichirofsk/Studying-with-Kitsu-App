import Foundation
import SwiftUI

public enum MiniGame1Phase: Equatable {
    case focusAnimation
    case dialogue(index: Int) // 0..2
    case playing
    case finished // reached when qtdFolhas == 0; do not navigate here
}

public struct MiniGame1Config {
    public static let initialLeaves: Int = 60
    public static let leavesStep: Int = 15
    public static let micTickSeconds: TimeInterval = 1.0
    public static let fadeOutDelay: TimeInterval = 1.5
}

public struct MiniGame1Dialogue {
    public static let items: [String] = [
        "The kid wanna study, but is surrounded by the cloud of helplessness.",
        "We have to take him away from it.",
        "Blow the microfone until the cloud leave him!"
    ]

    public static let initialImageNames: [String] = [
        "kitsuworried",
        "kitsuworried",
        "kitsuhappy1"
    ]

    public static let swappedImageNames: [String] = [
        "kitsuworried1",
        "kitsuworried1",
        "kitsuhappy1"
    ]
}

public enum MiniGame1LeavesStage: Int, CaseIterable {
    case s60 = 60
    case s45 = 45
    case s30 = 30
    case s15 = 15
    case s0  = 0

    public var imageName: String {
        switch self {
        case .s60: return "m1"
        case .s45: return "img2"
        case .s30: return "img3"
        case .s15: return "img4"
        case .s0:  return "img5"
        }
    }
}

public func stageForLeaves(_ leaves: Int) -> MiniGame1LeavesStage {
    if leaves <= 0 { return .s0 }
    if leaves <= 15 { return .s15 }
    if leaves <= 30 { return .s30 }
    if leaves <= 45 { return .s45 }
    return .s60
}

