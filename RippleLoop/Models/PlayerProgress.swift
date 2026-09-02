import Foundation

final class PlayerProgress {
    static let shared = PlayerProgress()

    private let defaults = UserDefaults.standard
    private enum Key {
        static let bestDistance = "ripplerun.bestDistance"
        static let totalRuns = "ripplerun.totalRuns"
        static let ripples = "ripplerun.ripples"
        static let pebbles = "ripplerun.pebbles"
        static let ftueComplete = "ripplerun.ftueComplete"
        static let adContinueUsedThisRun = "ripplerun.adContinueUsed"
        static let dailyFreeContinueUsed = "ripplerun.dailyFreeContinue"
        static let dailyFreeContinueDate = "ripplerun.dailyFreeContinueDate"
        static let upgradePrefix = "ripplerun.upgrade."
    }

    var bestDistanceMeters: Double {
        get { defaults.double(forKey: Key.bestDistance) }
        set { defaults.set(newValue, forKey: Key.bestDistance) }
    }

    var totalRuns: Int {
        get { defaults.integer(forKey: Key.totalRuns) }
        set { defaults.set(newValue, forKey: Key.totalRuns) }
    }

    var ripples: Int {
        get { defaults.integer(forKey: Key.ripples) }
        set { defaults.set(max(0, newValue), forKey: Key.ripples) }
    }

    var pebbles: Int {
        get { defaults.integer(forKey: Key.pebbles) }
        set { defaults.set(max(0, newValue), forKey: Key.pebbles) }
    }

    var ftueComplete: Bool {
        get { defaults.bool(forKey: Key.ftueComplete) }
        set { defaults.set(newValue, forKey: Key.ftueComplete) }
    }

    var adContinueUsedThisRun: Bool {
        get { defaults.bool(forKey: Key.adContinueUsedThisRun) }
        set { defaults.set(newValue, forKey: Key.adContinueUsedThisRun) }
    }

    var launchPowerLevel: Int {
        get { level(for: .launchPower) }
        set { setLevel(newValue, for: .launchPower) }
    }

    var skipForgivenessLevel: Int {
        get { level(for: .skipForgiveness) }
        set { setLevel(newValue, for: .skipForgiveness) }
    }

    var doubleBounceStaminaLevel: Int {
        get { level(for: .doubleBounceStamina) }
        set { setLevel(newValue, for: .doubleBounceStamina) }
    }

    var bounceFloatLevel: Int {
        get { level(for: .bounceFloat) }
        set { setLevel(newValue, for: .bounceFloat) }
    }

    var pearlMagnetLevel: Int {
        get { level(for: .pearlMagnet) }
        set { setLevel(newValue, for: .pearlMagnet) }
    }

    var launchPowerBonus: CGFloat {
        CGFloat(launchPowerLevel) * 0.06
    }

    var skipAngleBonus: CGFloat {
        CGFloat(skipForgivenessLevel) * 0.04
    }

    var doubleBouncesPerSegment: Int {
        1 + doubleBounceStaminaLevel
    }

    var bounceFloatFactor: CGFloat {
        1.0 - CGFloat(bounceFloatLevel) * 0.08
    }

    var pearlMagnetRadius: CGFloat {
        28 + CGFloat(pearlMagnetLevel) * 14
    }

    var continuePebbleCost: Int { 5 }

    var canUseDailyFreeContinue: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let stored = defaults.object(forKey: Key.dailyFreeContinueDate) as? Date ?? .distantPast
        let storedDay = Calendar.current.startOfDay(for: stored)
        if storedDay < today {
            defaults.set(false, forKey: Key.dailyFreeContinueUsed)
            defaults.set(today, forKey: Key.dailyFreeContinueDate)
        }
        return !defaults.bool(forKey: Key.dailyFreeContinueUsed)
    }

    func markDailyFreeContinueUsed() {
        defaults.set(true, forKey: Key.dailyFreeContinueUsed)
        defaults.set(Date(), forKey: Key.dailyFreeContinueDate)
    }

    func level(for upgrade: UpgradeKind) -> Int {
        max(0, min(defaults.integer(forKey: Key.upgradePrefix + upgrade.rawValue), upgrade.maxLevel))
    }

    func setLevel(_ level: Int, for upgrade: UpgradeKind) {
        defaults.set(max(0, min(level, upgrade.maxLevel)), forKey: Key.upgradePrefix + upgrade.rawValue)
    }

    func purchaseUpgrade(_ upgrade: UpgradeKind) -> Bool {
        let current = level(for: upgrade)
        guard current < upgrade.maxLevel else { return false }
        let cost = upgrade.cost(forLevel: current)
        guard ripples >= cost else { return false }
        ripples -= cost
        setLevel(current + 1, for: upgrade)
        return true
    }

    func grantFTUERipplesIfNeeded() {
        guard !ftueComplete else { return }
        ripples += 60
        pebbles += 5
        ftueComplete = true
    }

    func resetRunState() {
        adContinueUsedThisRun = false
    }

    func recordRun(
        distanceMeters: Double,
        skipCount: Int,
        pearlsCollected: Int,
        comboPeak: Int,
        biome: Biome
    ) -> RunSummary {
        totalRuns += 1
        let previousBest = bestDistanceMeters
        let isNewBest = distanceMeters > previousBest
        if isNewBest {
            bestDistanceMeters = distanceMeters
        }

        let distanceBonus = Int(distanceMeters * 0.4)
        let skipBonus = skipCount * 3
        let pearlBonus = pearlsCollected * 2
        let comboBonus = comboPeak * 5
        let earned = max(10, distanceBonus + skipBonus + pearlBonus + comboBonus)
        ripples += earned

        return RunSummary(
            distanceMeters: distanceMeters,
            skipCount: skipCount,
            bestDistanceMeters: bestDistanceMeters,
            isNewBest: isNewBest,
            ripplesEarned: earned,
            pearlsCollected: pearlsCollected,
            comboPeak: comboPeak,
            biomeReached: biome.displayName
        )
    }

    func spendPebblesForContinue() -> Bool {
        guard pebbles >= continuePebbleCost else { return false }
        pebbles -= continuePebbleCost
        return true
    }
}
