import CoreGraphics

enum RunPhase: Equatable {
    case throwing
    case aiming
    case flying
    case sinking
    case finished
}

struct StoneSnapshot {
    var position: CGPoint
    var velocity: CGVector
    var skipCount: Int
    var isActive: Bool
}

struct RunSummary: Equatable {
    let distanceMeters: Double
    let skipCount: Int
    let bestDistanceMeters: Double
    let isNewBest: Bool
    let ripplesEarned: Int
    let pearlsCollected: Int
    let comboPeak: Int
    let biomeReached: String
}
