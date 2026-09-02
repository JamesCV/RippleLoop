import CoreGraphics

enum GameConstants {
    static let sceneWidth: CGFloat = 390
    static let sceneHeight: CGFloat = 844

    static let gravity: CGFloat = 920
    static let waterSurfaceY: CGFloat = 210
    static let launchX: CGFloat = 72

    static let minSkipSpeed: CGFloat = 95
    static let maxSkipEntryAngle: CGFloat = 0.42
    static let skipVerticalBoost: CGFloat = 0.68
    static let skipHorizontalRetention: CGFloat = 0.94
    static let airDrag: CGFloat = 0.9992

    static let impulseBoostSpeed: CGFloat = 210
    static let maxImpulsesPerRun = 4
    static let impulseCooldown: TimeInterval = 0.35

    static let metersPerPoint: CGFloat = 0.012
    static let worldSegmentWidth: CGFloat = 520

    static let skyTop = "#C9A7E8"
    static let skyBottom = "#F5C4A8"
    static let waterDeep = "#3E8798"
    static let waterShallow = "#6AB4C4"
    static let rockTan = "#C9A574"
    static let grassGreen = "#5FAF6A"
}