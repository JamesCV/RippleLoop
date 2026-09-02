import CoreGraphics

enum RunPhase: Equatable {
    case aiming
    case flying
    case finished
}

struct StoneSnapshot {
    var position: CGPoint
    var velocity: CGVector
    var skipCount: Int
    var isActive: Bool
}

struct RunSummary {
    let distanceMeters: Double
    let skipCount: Int
    let bestDistanceMeters: Double
    let isNewBest: Bool
}