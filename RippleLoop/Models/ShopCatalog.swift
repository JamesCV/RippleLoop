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

    var id: String { rawValue }

    var title: String {
        switch self {
        case .skills: return "Skills"
        case .items: return "Items"
        }
    }
}

enum ItemTier: Int, Comparable {
    case common = 1
    case uncommon = 2

    static func < (lhs: ItemTier, rhs: ItemTier) -> Bool {
        lhs.rawValue < rhs.rawValue
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

    var id: String { rawValue }

    var category: ShopCategory { .items }

    var tier: ItemTier {
        switch self {
        case .surgePack, .tailwindDraught, .glideCharm, .momentumSeed,
             .pearlPouch, .softLanding, .morningDew:
            return .common
        case .comboKindling, .logWhisper, .currentRider, .skippersTea, .mistVeil:
            return .uncommon
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
        }
    }
}

enum LoadoutSlots {
    static func maxSlots(bestDistance: Double) -> Int {
        bestDistance >= 500 ? 2 : 1
    }
}
