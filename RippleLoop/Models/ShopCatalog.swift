import Foundation

enum UpgradeKind: String, CaseIterable, Identifiable {
    case launchPower
    case skipForgiveness
    case doubleBounceStamina
    case bounceFloat
    case pearlMagnet
    case rippleBoostCapacity
    case rippleBoostPower
    case speedRetention
    case comboMomentum

    var id: String { rawValue }

    var category: ShopCategory { .skills }

    var title: String {
        switch self {
        case .launchPower: return "Launch Power"
        case .skipForgiveness: return "Skip Forgiveness"
        case .doubleBounceStamina: return "Double Bounce"
        case .bounceFloat: return "Bounce Float"
        case .pearlMagnet: return "Pearl Magnet"
        case .rippleBoostCapacity: return "Boost Tank"
        case .rippleBoostPower: return "Boost Power"
        case .speedRetention: return "Speed Retention"
        case .comboMomentum: return "Combo Momentum"
        }
    }

    var description: String {
        switch self {
        case .launchPower: return "Stronger throws from the dock"
        case .skipForgiveness: return "Wider angle window for skips"
        case .doubleBounceStamina: return "+1 double bounce per air segment"
        case .bounceFloat: return "Slower fall — more time to read the lake"
        case .pearlMagnet: return "Pull pearls from farther away"
        case .rippleBoostCapacity: return "+1 Ripple Boost charge per run"
        case .rippleBoostPower: return "Stronger speed surge when boosting"
        case .speedRetention: return "Keep more speed after each skip"
        case .comboMomentum: return "Skip chains restore forward speed"
        }
    }

    var maxLevel: Int {
        switch self {
        case .launchPower, .skipForgiveness, .pearlMagnet,
             .rippleBoostCapacity, .rippleBoostPower, .speedRetention, .comboMomentum:
            return 5
        case .doubleBounceStamina: return 4
        case .bounceFloat: return 3
        }
    }

    func cost(forLevel level: Int) -> Int {
        let base: Int
        switch self {
        case .launchPower: base = 40
        case .skipForgiveness: base = 50
        case .doubleBounceStamina: base = 60
        case .bounceFloat: base = 55
        case .pearlMagnet: base = 45
        case .rippleBoostCapacity: base = 55
        case .rippleBoostPower: base = 50
        case .speedRetention: base = 48
        case .comboMomentum: base = 52
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

enum ShopItemKind: String, CaseIterable, Identifiable {
    case surgePack
    case tailwindDraught
    case glideCharm
    case momentumSeed

    var id: String { rawValue }

    var category: ShopCategory { .items }

    var title: String {
        switch self {
        case .surgePack: return "Surge Pack"
        case .tailwindDraught: return "Tailwind Draught"
        case .glideCharm: return "Glide Charm"
        case .momentumSeed: return "Momentum Seed"
        }
    }

    var description: String {
        switch self {
        case .surgePack: return "+2 Ripple Boost charges on your next run"
        case .tailwindDraught: return "+25% launch speed on your next run"
        case .glideCharm: return "Forgiving skips for one run"
        case .momentumSeed: return "First skip grants a big speed surge"
        }
    }

    var cost: Int {
        switch self {
        case .surgePack: return 35
        case .tailwindDraught: return 45
        case .glideCharm: return 50
        case .momentumSeed: return 55
        }
    }
}

struct RunItemModifiers {
    var extraBoostCharges = 0
    var launchSpeedMultiplier: CGFloat = 1
    var extraSkipForgiveness: CGFloat = 0
    var momentumSeedActive = false
    var momentumSeedUsed = false
}
