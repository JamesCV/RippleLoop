import Foundation

final class PlayerProgress {
    static let shared = PlayerProgress()

    private let defaults = UserDefaults.standard
    private enum Key {
        static let bestDistance = "rippleloop.bestDistance"
        static let totalRuns = "rippleloop.totalRuns"
        static let impulseUpgrade = "rippleloop.impulseUpgrade"
    }

    var bestDistanceMeters: Double {
        get { defaults.double(forKey: Key.bestDistance) }
        set { defaults.set(newValue, forKey: Key.bestDistance) }
    }

    var totalRuns: Int {
        get { defaults.integer(forKey: Key.totalRuns) }
        set { defaults.set(newValue, forKey: Key.totalRuns) }
    }

    var impulseUpgradeLevel: Int {
        get { max(0, defaults.integer(forKey: Key.impulseUpgrade)) }
        set { defaults.set(newValue, forKey: Key.impulseUpgrade) }
    }

    var maxImpulses: Int {
        GameConstants.maxImpulsesPerRun + impulseUpgradeLevel
    }

    func recordRun(distanceMeters: Double) -> RunSummary {
        totalRuns += 1
        let previousBest = bestDistanceMeters
        let isNewBest = distanceMeters > previousBest
        if isNewBest {
            bestDistanceMeters = distanceMeters
        }
        return RunSummary(
            distanceMeters: distanceMeters,
            skipCount: 0,
            bestDistanceMeters: bestDistanceMeters,
            isNewBest: isNewBest
        )
    }
}