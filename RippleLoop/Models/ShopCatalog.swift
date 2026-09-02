import Foundation

enum SkillTree: String, CaseIterable, Identifiable {
    case throwSkill
    case skip
    case air
    case surge
    case lake

    var id: String { rawValue }

    var title: String {
        switch self {
        case .throwSkill: return "Throw"
        case .skip: return "Skip"
        case .air: return "Air"
        case .surge: return "Surge"
        case .lake: return "Lake"
        }
    }

    var unlockDistanceMeters: Double {
        switch self {
        case .throwSkill: return 0
        case .skip: return 200
        case .air: return 500
        case .surge: return 1_000
        case .lake: return 2_000
        }
    }

    var upgrades: [UpgradeKind] {
        UpgradeKind.allCases.filter { $0.tree == self }
    }
}

enum UpgradeKind: String, CaseIterable, Identifiable {
    // Throw tree
    case launchPower
    case angleSense
    case dockFooting
    // Skip tree
    case skipForgiveness
    case speedRetention
    case deepSkim
    case rippleRhythm
    case comboMomentum
    // Air tree
    case doubleBounceStamina
    case bounceFloat
    case holdLift
    // Surge tree
    case rippleBoostCapacity
    case rippleBoostPower
    case overdrive
    // Lake tree
    case pearlMagnet
    case rippleFinder

    var id: String { rawValue }

    var category: ShopCategory { .skills }

    var tree: SkillTree {
        switch self {
        case .launchPower, .angleSense, .dockFooting: return .throwSkill
        case .skipForgiveness, .speedRetention, .deepSkim, .rippleRhythm, .comboMomentum: return .skip
        case .doubleBounceStamina, .bounceFloat, .holdLift: return .air
        case .rippleBoostCapacity, .rippleBoostPower, .overdrive: return .surge
        case .pearlMagnet, .rippleFinder: return .lake
        }
    }

    var title: String {
        switch self {
        case .launchPower: return "Launch Power"
        case .angleSense: return "Angle Sense"
        case .dockFooting: return "Dock Footing"
        case .skipForgiveness: return "Skip Forgiveness"
        case .speedRetention: return "Speed Retention"
        case .deepSkim: return "Deep Skim"
        case .rippleRhythm: return "Ripple Rhythm"
        case .comboMomentum: return "Combo Momentum"
        case .doubleBounceStamina: return "Double Bounce"
        case .bounceFloat: return "Bounce Float"
        case .holdLift: return "Hold Lift"
        case .rippleBoostCapacity: return "Boost Tank"
        case .rippleBoostPower: return "Boost Power"
        case .overdrive: return "Overdrive"
        case .pearlMagnet: return "Pearl Magnet"
        case .rippleFinder: return "Ripple Finder"
        }
    }

    var description: String {
        switch self {
        case .launchPower: return "Stronger throws from the dock"
        case .angleSense: return "Longer launch arc preview while aiming"
        case .dockFooting: return "First skip of each run keeps more speed"
        case .skipForgiveness: return "Wider angle window for skips"
        case .speedRetention: return "Keep more speed after each skip"
        case .deepSkim: return "Skip at lower speeds before sinking"
        case .rippleRhythm: return "Longer combo window between skips"
        case .comboMomentum: return "Skip chains restore forward speed"
        case .doubleBounceStamina: return "+1 double bounce per air segment"
        case .bounceFloat: return "Slower fall — more time to read the lake"
        case .holdLift: return "Stronger rise when holding during flight"
        case .rippleBoostCapacity: return "+1 Ripple Boost charge per run"
        case .rippleBoostPower: return "Stronger speed surge when boosting"
        case .overdrive: return "Faster boost cooldown when speed is low"
        case .pearlMagnet: return "Pull pearls from farther away"
        case .rippleFinder: return "More pearls and speed currents spawn"
        }
    }

    var maxLevel: Int {
        switch self {
        case .launchPower, .skipForgiveness, .pearlMagnet, .angleSense, .dockFooting,
             .deepSkim, .rippleRhythm, .holdLift, .rippleBoostCapacity, .rippleBoostPower,
             .speedRetention, .comboMomentum, .overdrive, .rippleFinder:
            return 5
        case .doubleBounceStamina: return 4
        case .bounceFloat: return 3
        }
    }

    func cost(forLevel level: Int) -> Int {
        let base: Int
        switch self {
        case .launchPower: base = 40
        case .angleSense: base = 45
        case .dockFooting: base = 42
        case .skipForgiveness: base = 50
        case .speedRetention: base = 48
        case .deepSkim: base = 52
        case .rippleRhythm: base = 50
        case .comboMomentum: base = 52
        case .doubleBounceStamina: base = 60
        case .bounceFloat: base = 55
        case .holdLift: base = 54
        case .rippleBoostCapacity: base = 55
        case .rippleBoostPower: base = 50
        case .overdrive: base = 58
        case .pearlMagnet: base = 45
        case .rippleFinder: base = 48
        }
        return base + level * 25
    }
}

enum ShopCategory: String, CaseIterable, Identifiable {
    case skills
    case items
    case stones
    case outfits
    case dock
    case blessings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .skills: return "Skills"
        case .items: return "Items"
        case .stones: return "Stones"
        case .outfits: return "Outfits"
        case .dock: return "Dock"
        case .blessings: return "Blessings"
        }
    }

    static var dockTabUnlockDistanceMeters: Double { 800 }
    static var blessingsTabUnlockDistanceMeters: Double { 2_000 }
}

enum ItemTier: Int, Comparable {
    case common = 1
    case uncommon = 2
    case rare = 3

    static func < (lhs: ItemTier, rhs: ItemTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        }
    }
}

enum ShopItemKind: String, CaseIterable, Identifiable {
    // Tier 1 — Common
    case surgePack
    case tailwindDraught
    case glideCharm
    case momentumSeed
    case pearlPouch
    case softLanding
    case morningDew
    // Tier 2 — Uncommon
    case comboKindling
    case logWhisper
    case currentRider
    case skippersTea
    case mistVeil
    // Tier 3 — Rare
    case glassSkim
    case pearlTide
    case deepCurrent
    case secondWind
    case skippersLuck

    var id: String { rawValue }

    var category: ShopCategory { .items }

    var tier: ItemTier {
        switch self {
        case .surgePack, .tailwindDraught, .glideCharm, .momentumSeed,
             .pearlPouch, .softLanding, .morningDew:
            return .common
        case .comboKindling, .logWhisper, .currentRider, .skippersTea, .mistVeil:
            return .uncommon
        case .glassSkim, .pearlTide, .deepCurrent, .secondWind, .skippersLuck:
            return .rare
        }
    }

    var title: String {
        switch self {
        case .surgePack: return "Surge Pack"
        case .tailwindDraught: return "Tailwind Draught"
        case .glideCharm: return "Glide Charm"
        case .momentumSeed: return "Momentum Seed"
        case .pearlPouch: return "Pearl Pouch"
        case .softLanding: return "Soft Landing"
        case .morningDew: return "Morning Dew"
        case .comboKindling: return "Combo Kindling"
        case .logWhisper: return "Log Whisper"
        case .currentRider: return "Current Rider"
        case .skippersTea: return "Skipper's Tea"
        case .mistVeil: return "Mist Veil"
        case .glassSkim: return "Glass Skim"
        case .pearlTide: return "Pearl Tide"
        case .deepCurrent: return "Deep Current"
        case .secondWind: return "Second Wind"
        case .skippersLuck: return "Skipper's Luck"
        }
    }

    var description: String {
        switch self {
        case .surgePack: return "+2 Ripple Boost charges"
        case .tailwindDraught: return "+25% launch speed"
        case .glideCharm: return "Forgiving skip angles"
        case .momentumSeed: return "First skip grants a big speed surge"
        case .pearlPouch: return "2× Ripples from pearls collected"
        case .softLanding: return "First failed skip auto-recovers once"
        case .morningDew: return "Golden Hour biome lasts +200m"
        case .comboKindling: return "Start the run at ×2 combo"
        case .logWhisper: return "Logs drift 30% slower"
        case .currentRider: return "First 3 currents grant +2 boosts each"
        case .skippersTea: return "Boost cooldown −40%"
        case .mistVeil: return "Fewer obstacles for the first 800m"
        case .glassSkim: return "Extra forgiving skip angles all run"
        case .pearlTide: return "More pearls spawn along the lake"
        case .deepCurrent: return "Every current grants +1 boost charge"
        case .secondWind: return "Last Ripple refills all boost charges"
        case .skippersLuck: return "+15% Ripples earned this run"
        }
    }

    var cost: Int {
        switch self {
        case .surgePack: return 35
        case .tailwindDraught: return 45
        case .glideCharm: return 50
        case .momentumSeed: return 55
        case .pearlPouch: return 30
        case .softLanding: return 40
        case .morningDew: return 38
        case .comboKindling: return 65
        case .logWhisper: return 70
        case .currentRider: return 75
        case .skippersTea: return 68
        case .mistVeil: return 72
        case .glassSkim: return 88
        case .pearlTide: return 92
        case .deepCurrent: return 95
        case .secondWind: return 105
        case .skippersLuck: return 98
        }
    }
}

enum StoneKind: String, CaseIterable, Identifiable {
    case smoothStone
    case slateSkipper
    case sunstone
    case lakeGlass
    case ironSkip
    case moonPebble
    case heartRock

    var id: String { rawValue }

    var category: ShopCategory { .stones }

    var title: String {
        switch self {
        case .smoothStone: return "Smooth Stone"
        case .slateSkipper: return "Slate Skipper"
        case .sunstone: return "Sunstone"
        case .lakeGlass: return "Lake Glass"
        case .ironSkip: return "Iron Skip"
        case .moonPebble: return "Moon Pebble"
        case .heartRock: return "Heart Rock"
        }
    }

    var description: String {
        switch self {
        case .smoothStone: return "Balanced river rock — your faithful starter"
        case .slateSkipper: return "+2% speed kept after each skip"
        case .sunstone: return "+3% launch power"
        case .lakeGlass: return "Wider skip angle window"
        case .ironSkip: return "+1 Ripple Boost charge per run"
        case .moonPebble: return "Longer combo window between skips"
        case .heartRock: return "+1 Ripple per pearl collected"
        }
    }

    var unlockDistanceMeters: Double {
        switch self {
        case .smoothStone: return 0
        case .slateSkipper: return 0
        case .sunstone: return 200
        case .lakeGlass: return 500
        case .ironSkip: return 1_000
        case .moonPebble: return 1_500
        case .heartRock: return 2_000
        }
    }

    var cost: Int {
        switch self {
        case .smoothStone: return 0
        case .slateSkipper: return 45
        case .sunstone: return 55
        case .lakeGlass: return 65
        case .ironSkip: return 80
        case .moonPebble: return 75
        case .heartRock: return 90
        }
    }

    var isDefaultOwned: Bool {
        self == .smoothStone
    }

    var fillHex: String {
        switch self {
        case .smoothStone: return "#D0D0D0"
        case .slateSkipper: return "#6A7080"
        case .sunstone: return "#E8B060"
        case .lakeGlass: return "#88D8E8"
        case .ironSkip: return "#505868"
        case .moonPebble: return "#C8D8F0"
        case .heartRock: return "#E898A8"
        }
    }

    var strokeHex: String {
        switch self {
        case .smoothStone: return "#8C8C8C"
        case .slateSkipper: return "#404858"
        case .sunstone: return "#B87830"
        case .lakeGlass: return "#48A8C8"
        case .ironSkip: return "#303848"
        case .moonPebble: return "#8898B8"
        case .heartRock: return "#C86878"
        }
    }

    func runModifiers() -> StoneRunModifiers {
        var mods = StoneRunModifiers()
        switch self {
        case .smoothStone:
            break
        case .slateSkipper:
            mods.skipRetentionBonus = 0.02
        case .sunstone:
            mods.launchPowerBonus = 0.03
        case .lakeGlass:
            mods.skipAngleBonus = 0.04
        case .ironSkip:
            mods.extraBoostCharges = 1
        case .moonPebble:
            mods.comboWindowBonus = 0.12
        case .heartRock:
            mods.pearlRippleBonus = 1
        }
        return mods
    }
}

struct StoneRunModifiers {
    var launchPowerBonus: CGFloat = 0
    var skipRetentionBonus: CGFloat = 0
    var skipAngleBonus: CGFloat = 0
    var extraBoostCharges: Int = 0
    var comboWindowBonus: TimeInterval = 0
    var pearlRippleBonus: Int = 0
}

enum PebbleOutfitKind: String, CaseIterable, Identifiable {
    case defaultHood
    case rainSlicker
    case cozyScarf
    case starryCloak
    case arcticWrap
    case emberVest

    var id: String { rawValue }

    var category: ShopCategory { .outfits }

    var title: String {
        switch self {
        case .defaultHood: return "Dock Hoodie"
        case .rainSlicker: return "Rain Slicker"
        case .cozyScarf: return "Cozy Scarf"
        case .starryCloak: return "Starry Cloak"
        case .arcticWrap: return "Arctic Wrap"
        case .emberVest: return "Ember Vest"
        }
    }

    var description: String {
        switch self {
        case .defaultHood: return "Classic dock look — always cozy"
        case .rainSlicker: return "Bright yellow for misty mornings"
        case .cozyScarf: return "Warm red scarf for chilly throws"
        case .starryCloak: return "Purple cloak for twilight runs"
        case .arcticWrap: return "Frost-blue wrap for deep lakes"
        case .emberVest: return "Ember-orange vest for the deep run"
        }
    }

    var unlockDistanceMeters: Double {
        switch self {
        case .defaultHood: return 0
        case .rainSlicker: return 0
        case .cozyScarf: return 200
        case .starryCloak: return 1_000
        case .arcticWrap: return 3_000
        case .emberVest: return 5_000
        }
    }

    var cost: Int {
        switch self {
        case .defaultHood: return 0
        case .rainSlicker: return 40
        case .cozyScarf: return 50
        case .starryCloak: return 70
        case .arcticWrap: return 85
        case .emberVest: return 95
        }
    }

    var isDefaultOwned: Bool {
        self == .defaultHood
    }

    var bodyHex: String {
        switch self {
        case .defaultHood: return "#3A4858"
        case .rainSlicker: return "#C8A830"
        case .cozyScarf: return "#3A4858"
        case .starryCloak: return "#4A3868"
        case .arcticWrap: return "#5888A8"
        case .emberVest: return "#884838"
        }
    }

    var hoodHex: String {
        switch self {
        case .defaultHood: return "#4A5868"
        case .rainSlicker: return "#E8C840"
        case .cozyScarf: return "#4A5868"
        case .starryCloak: return "#6858A0"
        case .arcticWrap: return "#78A8C8"
        case .emberVest: return "#A85840"
        }
    }

    var accentHex: String? {
        switch self {
        case .cozyScarf: return "#D84848"
        case .starryCloak: return "#FFD878"
        default: return nil
        }
    }
}

struct RunItemModifiers {
    var extraBoostCharges = 0
    var launchSpeedMultiplier: CGFloat = 1
    var extraSkipForgiveness: CGFloat = 0
    var momentumSeedActive = false
    var momentumSeedUsed = false

    var pearlRippleMultiplier: Int = 1
    var softLandingAvailable = false
    var softLandingUsed = false
    var morningDewActive = false
    var startingCombo: Int = 1
    var logSpeedMultiplier: CGFloat = 1
    var currentRiderRemaining = 0
    var boostCooldownMultiplier: CGFloat = 1
    var mistVeilActive = false
    var mistVeilDistanceRemaining: Double = 0

    var pearlSpawnMultiplier: Double = 1
    var deepCurrentExtraBoost = false
    var secondWindActive = false
    var rippleEarnMultiplier: Double = 1

    mutating func apply(_ item: ShopItemKind) {
        switch item {
        case .surgePack:
            extraBoostCharges += 2
        case .tailwindDraught:
            launchSpeedMultiplier *= 1.25
        case .glideCharm:
            extraSkipForgiveness += 0.08
        case .momentumSeed:
            momentumSeedActive = true
        case .pearlPouch:
            pearlRippleMultiplier = 2
        case .softLanding:
            softLandingAvailable = true
        case .morningDew:
            morningDewActive = true
        case .comboKindling:
            startingCombo = max(startingCombo, 2)
        case .logWhisper:
            logSpeedMultiplier = 0.7
        case .currentRider:
            currentRiderRemaining = 3
        case .skippersTea:
            boostCooldownMultiplier = 0.6
        case .mistVeil:
            mistVeilActive = true
            mistVeilDistanceRemaining = 800
        case .glassSkim:
            extraSkipForgiveness += 0.06
        case .pearlTide:
            pearlSpawnMultiplier = 1.4
        case .deepCurrent:
            deepCurrentExtraBoost = true
        case .secondWind:
            secondWindActive = true
        case .skippersLuck:
            rippleEarnMultiplier = 1.15
        }
    }
}

enum LoadoutSlots {
    static func maxSlots(bestDistance: Double) -> Int {
        if bestDistance >= 1_500 { return 3 }
        if bestDistance >= 500 { return 2 }
        return 1
    }
}

enum DockUpgradeKind: String, CaseIterable, Identifiable {
    case rippleCrate
    case launchRail
    case boostKeg
    case restBench
    case lanternRow
    case windChimes

    var id: String { rawValue }

    var category: ShopCategory { .dock }

    var title: String {
        switch self {
        case .rippleCrate: return "Ripple Crate"
        case .launchRail: return "Launch Rail"
        case .boostKeg: return "Boost Keg"
        case .restBench: return "Rest Bench"
        case .lanternRow: return "Lantern Row"
        case .windChimes: return "Wind Chimes"
        }
    }

    var description: String {
        switch self {
        case .rippleCrate: return "+5% Ripples earned from every run"
        case .launchRail: return "+1.5% launch power from the dock"
        case .boostKeg: return "+1 boost charge at levels 2 and 4"
        case .restBench: return "Last Ripple restores more forward speed"
        case .lanternRow: return "+2s on the Last Ripple countdown"
        case .windChimes: return "Longer combo window between skips"
        }
    }

    var maxLevel: Int {
        switch self {
        case .rippleCrate, .launchRail, .windChimes: return 5
        case .boostKeg: return 4
        case .restBench, .lanternRow: return 3
        }
    }

    func cost(forLevel level: Int) -> Int {
        let base: Int
        switch self {
        case .rippleCrate: base = 65
        case .launchRail: base = 60
        case .boostKeg: base = 72
        case .restBench: base = 68
        case .lanternRow: base = 58
        case .windChimes: base = 62
        }
        return base + level * 32
    }
}

struct DockRunModifiers {
    var rippleEarnMultiplier: Double = 1
    var launchPowerBonus: CGFloat = 0
    var extraBoostCharges: Int = 0
    var continueSpeedBonus: CGFloat = 0
    var lastRippleCountdownBonus: Int = 0
    var comboWindowBonus: TimeInterval = 0
}

enum DockTier: Int, CaseIterable {
    case weathered
    case sturdy
    case lantern
    case golden

    var title: String {
        switch self {
        case .weathered: return "Weathered Dock"
        case .sturdy: return "Sturdy Dock"
        case .lantern: return "Lantern Dock"
        case .golden: return "Golden Dock"
        }
    }

    var plankHex: String {
        switch self {
        case .weathered: return "#8B6914"
        case .sturdy: return "#9B7924"
        case .lantern: return "#AB8934"
        case .golden: return "#C8A050"
        }
    }

    var strokeHex: String {
        switch self {
        case .weathered: return "#6B5010"
        case .sturdy: return "#7B6020"
        case .lantern: return "#8B7030"
        case .golden: return "#A88840"
        }
    }

    static func from(totalLevels: Int, maxLevels: Int) -> DockTier {
        guard maxLevels > 0 else { return .weathered }
        let ratio = Double(totalLevels) / Double(maxLevels)
        if ratio >= 0.85 { return .golden }
        if ratio >= 0.55 { return .lantern }
        if ratio >= 0.25 { return .sturdy }
        return .weathered
    }
}

enum BlessingKind: String, CaseIterable, Identifiable {
    case stillWaters
    case gildedCurrents
    case skippersGrace
    case moonlitPearls
    case calmBreeze
    case lakesFavor
    case rippleEcho

    var id: String { rawValue }

    var category: ShopCategory { .blessings }

    var title: String {
        switch self {
        case .stillWaters: return "Still Waters"
        case .gildedCurrents: return "Gilded Currents"
        case .skippersGrace: return "Skipper's Grace"
        case .moonlitPearls: return "Moonlit Pearls"
        case .calmBreeze: return "Calm Breeze"
        case .lakesFavor: return "Lake's Favor"
        case .rippleEcho: return "Ripple Echo"
        }
    }

    var description: String {
        switch self {
        case .stillWaters: return "No logs for the first 600m"
        case .gildedCurrents: return "Speed currents spawn more often"
        case .skippersGrace: return "Preserve combo once if a chain breaks"
        case .moonlitPearls: return "More pearls with a gentle pull"
        case .calmBreeze: return "Stronger bounces and hold lift"
        case .lakesFavor: return "+8% Ripples earned this run"
        case .rippleEcho: return "Wider double-bounce timing window"
        }
    }

    var unlockDistanceMeters: Double {
        switch self {
        case .stillWaters, .gildedCurrents: return 2_000
        case .skippersGrace, .moonlitPearls: return 2_500
        case .calmBreeze: return 3_000
        case .lakesFavor: return 3_500
        case .rippleEcho: return 5_000
        }
    }

    var cost: Int {
        switch self {
        case .stillWaters: return 120
        case .gildedCurrents: return 125
        case .skippersGrace: return 118
        case .moonlitPearls: return 115
        case .calmBreeze: return 122
        case .lakesFavor: return 135
        case .rippleEcho: return 145
        }
    }

    var accentHex: String {
        switch self {
        case .stillWaters: return "#88C8E8"
        case .gildedCurrents: return "#FFD878"
        case .skippersGrace: return "#9BE7A8"
        case .moonlitPearls: return "#C9A7E8"
        case .calmBreeze: return "#A8D8F0"
        case .lakesFavor: return "#E8B060"
        case .rippleEcho: return "#E878A8"
        }
    }
}

struct BlessingRunModifiers {
    var stillWatersActive = false
    var stillWatersDistanceRemaining: Double = 0
    var logSpawnMultiplier: Double = 1
    var currentSpawnMultiplier: Double = 1
    var comboGraceAvailable = false
    var comboGraceUsed = false
    var pearlSpawnMultiplier: Double = 1
    var pearlDriftRadius: CGFloat = 0
    var bounceLiftMultiplier: CGFloat = 1
    var holdLiftMultiplier: CGFloat = 1
    var rippleEarnMultiplier: Double = 1
    var doubleBounceWindowBonus: TimeInterval = 0

    mutating func apply(_ blessing: BlessingKind) {
        switch blessing {
        case .stillWaters:
            stillWatersActive = true
            stillWatersDistanceRemaining = 600
            logSpawnMultiplier = 0
        case .gildedCurrents:
            currentSpawnMultiplier *= 1.35
        case .skippersGrace:
            comboGraceAvailable = true
        case .moonlitPearls:
            pearlSpawnMultiplier *= 1.25
            pearlDriftRadius = max(pearlDriftRadius, 22)
        case .calmBreeze:
            bounceLiftMultiplier *= 1.12
            holdLiftMultiplier *= 1.12
        case .lakesFavor:
            rippleEarnMultiplier *= 1.08
        case .rippleEcho:
            doubleBounceWindowBonus += 0.15
        }
    }

    static func fromEquipped(_ blessings: [BlessingKind]) -> BlessingRunModifiers {
        var modifiers = BlessingRunModifiers()
        for blessing in blessings {
            modifiers.apply(blessing)
        }
        return modifiers
    }
}

enum BlessingLoadoutSlots {
    static func maxSlots(bestDistance: Double) -> Int {
        guard bestDistance >= ShopCategory.blessingsTabUnlockDistanceMeters else { return 0 }
        return bestDistance >= 4_000 ? 2 : 1
    }
}
