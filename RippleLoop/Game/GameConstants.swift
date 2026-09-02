import CoreGraphics

enum GameConstants {
    static let sceneWidth: CGFloat = 390
    static let sceneHeight: CGFloat = 844

    static let gravity: CGFloat = 820
    static let waterSurfaceY: CGFloat = 210
    static let launchX: CGFloat = 72
    static let dockY: CGFloat = waterSurfaceY + 42

    static let minSkipSpeed: CGFloat = 85
    static let maxSkipEntryAngle: CGFloat = 0.42
    static let skipVerticalBoost: CGFloat = 0.72
    static let skipHorizontalRetention: CGFloat = 0.94
    static let airDrag: CGFloat = 0.9994

    static let bounceLiftForce: CGFloat = 520
    static let doubleBounceForce: CGFloat = 680
    static let doubleBounceWindow: TimeInterval = 0.42
    static let bounceHoldMultiplier: CGFloat = 1.35
    static let slowMoDuration: TimeInterval = 0.28
    static let slowMoFactor: CGFloat = 0.45

    static let metersPerPoint: CGFloat = 0.012
    static let worldSegmentWidth: CGFloat = 520
    static let spawnAheadDistance: CGFloat = 900
    static let despawnBehindDistance: CGFloat = 400

    static let comboWindowSeconds: TimeInterval = 2.2
    static let sinkDuration: TimeInterval = 1.8
    static let throwAnimationDuration: TimeInterval = 0.55

    static let rippleBoostSpeed: CGFloat = 240
    static let rippleBoostLift: CGFloat = 180
    static let rippleBoostCooldown: TimeInterval = 0.45
    static let minSpeedBeforeSinkWarning: CGFloat = 70
    static let speedCurrentBurst: CGFloat = 160

    static let skyTop = "#C9A7E8"
    static let skyBottom = "#F5C4A8"
    static let waterDeep = "#3E8798"
    static let waterShallow = "#6AB4C4"
    static let rockTan = "#C9A574"
    static let grassGreen = "#5FAF6A"
}
