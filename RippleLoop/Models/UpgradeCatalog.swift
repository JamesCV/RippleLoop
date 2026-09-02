import Foundation

enum UpgradeKind: String, CaseIterable, Identifiable {
    case launchPower
    case skipForgiveness
    case doubleBounceStamina
    case bounceFloat
    case pearlMagnet

    var id: String { rawValue }

    var title: String {
        switch self {
        case .launchPower: return "Launch Power"
        case .skipForgiveness: return "Skip Forgiveness"
        case .doubleBounceStamina: return "Double Bounce"
        case .bounceFloat: return "Bounce Float"
        case .pearlMagnet: return "Pearl Magnet"
        }
    }

    var description: String {
        switch self {
        case .launchPower: return "Stronger throws from the dock"
        case .skipForgiveness: return "Wider angle window for skips"
        case .doubleBounceStamina: return "+1 double bounce per air segment"
        case .bounceFloat: return "Slower fall — more time to read the lake"
        case .pearlMagnet: return "Pull pearls from farther away"
        }
    }

    var maxLevel: Int {
        switch self {
        case .launchPower, .skipForgiveness, .pearlMagnet: return 5
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
        }
        return base + level * 25
    }
}
