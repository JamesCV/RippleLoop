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
        static let itemPrefix = "ripplerun.item."
        static let equippedItem = "ripplerun.equippedItem"
        static let equippedItems = "ripplerun.equippedItems"
        static let stonePrefix = "ripplerun.stone."
        static let equippedStone = "ripplerun.equippedStone"
        static let outfitPrefix = "ripplerun.outfit."
        static let equippedOutfit = "ripplerun.equippedOutfit"
        static let dockUpgradePrefix = "ripplerun.dock."
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

    var maxLoadoutSlots: Int {
        LoadoutSlots.maxSlots(bestDistance: bestDistanceMeters)
    }

    var equippedStone: StoneKind {
        get {
            guard let raw = defaults.string(forKey: Key.equippedStone),
                  let stone = StoneKind(rawValue: raw) else {
                return .smoothStone
            }
            return ownsStone(stone) ? stone : .smoothStone
        }
        set {
            guard ownsStone(newValue) else { return }
            defaults.set(newValue.rawValue, forKey: Key.equippedStone)
        }
    }

    var equippedOutfit: PebbleOutfitKind {
        get {
            guard let raw = defaults.string(forKey: Key.equippedOutfit),
                  let outfit = PebbleOutfitKind(rawValue: raw) else {
                return .defaultHood
            }
            return ownsOutfit(outfit) ? outfit : .defaultHood
        }
        set {
            guard ownsOutfit(newValue) else { return }
            defaults.set(newValue.rawValue, forKey: Key.equippedOutfit)
        }
    }

    var stoneRunModifiers: StoneRunModifiers {
        equippedStone.runModifiers()
    }

    var dockRunModifiers: DockRunModifiers {
        var mods = DockRunModifiers()
        let rippleLevel = dockLevel(for: .rippleCrate)
        mods.rippleEarnMultiplier = 1 + Double(rippleLevel) * 0.05

        let launchLevel = dockLevel(for: .launchRail)
        mods.launchPowerBonus = CGFloat(launchLevel) * 0.015

        let boostLevel = dockLevel(for: .boostKeg)
        mods.extraBoostCharges = (boostLevel >= 2 ? 1 : 0) + (boostLevel >= 4 ? 1 : 0)

        let benchLevel = dockLevel(for: .restBench)
        mods.continueSpeedBonus = CGFloat(benchLevel) * 50

        let lanternLevel = dockLevel(for: .lanternRow)
        mods.lastRippleCountdownBonus = lanternLevel * 2

        let chimeLevel = dockLevel(for: .windChimes)
        mods.comboWindowBonus = TimeInterval(chimeLevel) * 0.05

        return mods
    }

    var dockTier: DockTier {
        let total = DockUpgradeKind.allCases.reduce(0) { $0 + dockLevel(for: $1) }
        let maxTotal = DockUpgradeKind.allCases.reduce(0) { $0 + $1.maxLevel }
        return DockTier.from(totalLevels: total, maxLevels: maxTotal)
    }

    var lastRippleCountdownSeconds: Int {
        5 + dockRunModifiers.lastRippleCountdownBonus
    }

    var equippedItemsForNextRun: [ShopItemKind?] {
        get {
            migrateLegacyEquippedItemIfNeeded()
            let stored = defaults.stringArray(forKey: Key.equippedItems) ?? []
            var slots = stored.map { ShopItemKind(rawValue: $0) }
            while slots.count < maxLoadoutSlots {
                slots.append(nil)
            }
            return Array(slots.prefix(maxLoadoutSlots))
        }
        set {
            let raw = newValue.prefix(maxLoadoutSlots).map { $0?.rawValue ?? "" }
            defaults.set(raw, forKey: Key.equippedItems)
        }
    }

    @available(*, deprecated, message: "Use equippedItemsForNextRun")
    var equippedItemForNextRun: ShopItemKind? {
        get { equippedItemsForNextRun.first ?? nil }
        set {
            var slots = equippedItemsForNextRun
            if slots.isEmpty {
                slots = [newValue]
            } else {
                slots[0] = newValue
            }
            equippedItemsForNextRun = slots
        }
    }

    var launchPowerLevel: Int { level(for: .launchPower) }
    var angleSenseLevel: Int { level(for: .angleSense) }
    var dockFootingLevel: Int { level(for: .dockFooting) }
    var skipForgivenessLevel: Int { level(for: .skipForgiveness) }
    var speedRetentionLevel: Int { level(for: .speedRetention) }
    var deepSkimLevel: Int { level(for: .deepSkim) }
    var rippleRhythmLevel: Int { level(for: .rippleRhythm) }
    var comboMomentumLevel: Int { level(for: .comboMomentum) }
    var doubleBounceStaminaLevel: Int { level(for: .doubleBounceStamina) }
    var bounceFloatLevel: Int { level(for: .bounceFloat) }
    var holdLiftLevel: Int { level(for: .holdLift) }
    var rippleBoostCapacityLevel: Int { level(for: .rippleBoostCapacity) }
    var rippleBoostPowerLevel: Int { level(for: .rippleBoostPower) }
    var overdriveLevel: Int { level(for: .overdrive) }
    var pearlMagnetLevel: Int { level(for: .pearlMagnet) }
    var rippleFinderLevel: Int { level(for: .rippleFinder) }

    var launchPowerBonus: CGFloat { CGFloat(launchPowerLevel) * 0.06 }
    var skipAngleBonus: CGFloat { CGFloat(skipForgivenessLevel) * 0.04 }
    var doubleBouncesPerSegment: Int { 1 + doubleBounceStaminaLevel }
    var bounceFloatFactor: CGFloat { 1.0 - CGFloat(bounceFloatLevel) * 0.08 }
    var pearlMagnetRadius: CGFloat { 28 + CGFloat(pearlMagnetLevel) * 14 }

    var rippleBoostsPerRun: Int { 2 + rippleBoostCapacityLevel }
    var rippleBoostStrength: CGFloat { 1.0 + CGFloat(rippleBoostPowerLevel) * 0.12 }
    var skipSpeedRetentionBonus: CGFloat { CGFloat(speedRetentionLevel) * 0.012 }
    var comboMomentumFactor: CGFloat { CGFloat(comboMomentumLevel) * 0.018 }

    var angleArcPreviewSteps: Int { 4 + angleSenseLevel * 3 }
    var dockFootingRetentionBonus: CGFloat { CGFloat(dockFootingLevel) * 0.018 }
    var deepSkimMinSpeedReduction: CGFloat { CGFloat(deepSkimLevel) * 6 }
    var comboWindowBonus: TimeInterval { TimeInterval(rippleRhythmLevel) * 0.18 }
    var holdLiftMultiplier: CGFloat { 1 + CGFloat(holdLiftLevel) * 0.1 }
    var overdriveCooldownBonus: CGFloat { CGFloat(overdriveLevel) * 0.08 }
    var rippleFinderSpawnBonus: CGFloat { CGFloat(rippleFinderLevel) * 0.05 }

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

    func isSkillTreeUnlocked(_ tree: SkillTree) -> Bool {
        bestDistanceMeters >= tree.unlockDistanceMeters
    }

    func isDockTabUnlocked() -> Bool {
        bestDistanceMeters >= ShopCategory.dockTabUnlockDistanceMeters
    }

    func dockLevel(for upgrade: DockUpgradeKind) -> Int {
        max(0, min(defaults.integer(forKey: Key.dockUpgradePrefix + upgrade.rawValue), upgrade.maxLevel))
    }

    func setDockLevel(_ level: Int, for upgrade: DockUpgradeKind) {
        defaults.set(max(0, min(level, upgrade.maxLevel)), forKey: Key.dockUpgradePrefix + upgrade.rawValue)
    }

    func purchaseDockUpgrade(_ upgrade: DockUpgradeKind) -> Bool {
        guard isDockTabUnlocked() else { return false }
        let current = dockLevel(for: upgrade)
        guard current < upgrade.maxLevel else { return false }
        let cost = upgrade.cost(forLevel: current)
        guard ripples >= cost else { return false }
        ripples -= cost
        setDockLevel(current + 1, for: upgrade)
        return true
    }

    func level(for upgrade: UpgradeKind) -> Int {
        max(0, min(defaults.integer(forKey: Key.upgradePrefix + upgrade.rawValue), upgrade.maxLevel))
    }

    func setLevel(_ level: Int, for upgrade: UpgradeKind) {
        defaults.set(max(0, min(level, upgrade.maxLevel)), forKey: Key.upgradePrefix + upgrade.rawValue)
    }

    func itemCount(_ item: ShopItemKind) -> Int {
        max(0, defaults.integer(forKey: Key.itemPrefix + item.rawValue))
    }

    func setItemCount(_ count: Int, for item: ShopItemKind) {
        defaults.set(max(0, count), forKey: Key.itemPrefix + item.rawValue)
    }

    func purchaseUpgrade(_ upgrade: UpgradeKind) -> Bool {
        guard isSkillTreeUnlocked(upgrade.tree) else { return false }
        let current = level(for: upgrade)
        guard current < upgrade.maxLevel else { return false }
        let cost = upgrade.cost(forLevel: current)
        guard ripples >= cost else { return false }
        ripples -= cost
        setLevel(current + 1, for: upgrade)
        return true
    }

    func purchaseItem(_ item: ShopItemKind) -> Bool {
        guard ripples >= item.cost else { return false }
        ripples -= item.cost
        setItemCount(itemCount(item) + 1, for: item)
        return true
    }

    func ownsStone(_ stone: StoneKind) -> Bool {
        if stone.isDefaultOwned { return true }
        return defaults.bool(forKey: Key.stonePrefix + stone.rawValue)
    }

    func purchaseStone(_ stone: StoneKind) -> Bool {
        guard stone != .smoothStone else { return false }
        guard bestDistanceMeters >= stone.unlockDistanceMeters else { return false }
        guard !ownsStone(stone) else { return false }
        guard ripples >= stone.cost else { return false }
        ripples -= stone.cost
        defaults.set(true, forKey: Key.stonePrefix + stone.rawValue)
        return true
    }

    func equipStone(_ stone: StoneKind) {
        guard ownsStone(stone) else { return }
        equippedStone = stone
    }

    func ownsOutfit(_ outfit: PebbleOutfitKind) -> Bool {
        if outfit.isDefaultOwned { return true }
        return defaults.bool(forKey: Key.outfitPrefix + outfit.rawValue)
    }

    func purchaseOutfit(_ outfit: PebbleOutfitKind) -> Bool {
        guard outfit != .defaultHood else { return false }
        guard bestDistanceMeters >= outfit.unlockDistanceMeters else { return false }
        guard !ownsOutfit(outfit) else { return false }
        guard ripples >= outfit.cost else { return false }
        ripples -= outfit.cost
        defaults.set(true, forKey: Key.outfitPrefix + outfit.rawValue)
        return true
    }

    func equipOutfit(_ outfit: PebbleOutfitKind) {
        guard ownsOutfit(outfit) else { return }
        equippedOutfit = outfit
    }

    func equippedItem(in slot: Int) -> ShopItemKind? {
        guard slot >= 0, slot < equippedItemsForNextRun.count else { return nil }
        return equippedItemsForNextRun[slot]
    }

    func equipItem(_ item: ShopItemKind?, slot: Int) {
        guard slot >= 0, slot < maxLoadoutSlots else { return }
        if let item, itemCount(item) <= 0 { return }

        var slots = equippedItemsForNextRun
        while slots.count < maxLoadoutSlots {
            slots.append(nil)
        }

        if let item {
            for index in slots.indices where index != slot && slots[index] == item {
                slots[index] = nil
            }
        }

        slots[slot] = item
        equippedItemsForNextRun = slots
    }

    func clearLoadout() {
        equippedItemsForNextRun = Array(repeating: nil, count: maxLoadoutSlots)
    }

    func consumeEquippedItemsIfNeeded() -> RunItemModifiers {
        var modifiers = RunItemModifiers()
        var slots = equippedItemsForNextRun
        var consumedAny = false

        for index in slots.indices {
            guard let item = slots[index] else { continue }
            guard itemCount(item) > 0 else {
                slots[index] = nil
                continue
            }

            setItemCount(itemCount(item) - 1, for: item)
            modifiers.apply(item)
            slots[index] = nil
            consumedAny = true
        }

        if consumedAny {
            equippedItemsForNextRun = slots
        }

        return modifiers
    }

    func grantFTUERipplesIfNeeded() {
        guard !ftueComplete else { return }
        ripples += 80
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
        biome: Biome,
        pearlRippleMultiplier: Int = 1,
        pearlRippleBonus: Int = 0,
        rippleEarnMultiplier: Double = 1
    ) -> RunSummary {
        totalRuns += 1
        let previousBest = bestDistanceMeters
        let isNewBest = distanceMeters > previousBest
        if isNewBest {
            bestDistanceMeters = distanceMeters
        }

        let distanceBonus = Int(distanceMeters * 0.4)
        let skipBonus = skipCount * 3
        let pearlBonus = pearlsCollected * max(1, pearlRippleMultiplier) * (2 + max(0, pearlRippleBonus))
        let comboBonus = comboPeak * 5
        let baseEarned = max(10, distanceBonus + skipBonus + pearlBonus + comboBonus)
        let earned = max(10, Int(Double(baseEarned) * max(1, rippleEarnMultiplier) * dockRunModifiers.rippleEarnMultiplier))
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

    private func migrateLegacyEquippedItemIfNeeded() {
        guard defaults.stringArray(forKey: Key.equippedItems) == nil else { return }
        guard let legacy = defaults.string(forKey: Key.equippedItem), !legacy.isEmpty else { return }
        defaults.set([legacy], forKey: Key.equippedItems)
        defaults.removeObject(forKey: Key.equippedItem)
    }
}
