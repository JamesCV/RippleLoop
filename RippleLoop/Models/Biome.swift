import SpriteKit

enum Biome: CaseIterable {
    case goldenHour
    case mistMorning
    case glassTwilight
    case stillArctic
    case emberDeep

    var displayName: String {
        switch self {
        case .goldenHour: return "Golden Hour"
        case .mistMorning: return "Mist Morning"
        case .glassTwilight: return "Glass Twilight"
        case .stillArctic: return "Still Arctic"
        case .emberDeep: return "Ember Deep"
        }
    }

    var distanceThresholdMeters: Double {
        switch self {
        case .goldenHour: return 0
        case .mistMorning: return 600
        case .glassTwilight: return 1500
        case .stillArctic: return 3000
        case .emberDeep: return 5000
        }
    }

    var skyTop: String {
        switch self {
        case .goldenHour: return "#C9A7E8"
        case .mistMorning: return "#B8C9BE"
        case .glassTwilight: return "#7B5EA7"
        case .stillArctic: return "#A8C8E8"
        case .emberDeep: return "#4A2840"
        }
    }

    var skyBottom: String {
        switch self {
        case .goldenHour: return "#F5C4A8"
        case .mistMorning: return "#D8E4DC"
        case .glassTwilight: return "#E878A8"
        case .stillArctic: return "#D0E8F8"
        case .emberDeep: return "#8B4040"
        }
    }

    var waterDeep: String {
        switch self {
        case .goldenHour: return "#3E8798"
        case .mistMorning: return "#4A7A82"
        case .glassTwilight: return "#2A5878"
        case .stillArctic: return "#5A98B8"
        case .emberDeep: return "#2A3848"
        }
    }

    var waterShallow: String {
        switch self {
        case .goldenHour: return "#6AB4C4"
        case .mistMorning: return "#7AA8B0"
        case .glassTwilight: return "#4AE8C8"
        case .stillArctic: return "#A0D8F0"
        case .emberDeep: return "#E87850"
        }
    }

    var rockTan: String { "#C9A574" }
    var grassGreen: String {
        switch self {
        case .stillArctic: return "#8AB8C8"
        case .emberDeep: return "#6A5040"
        default: return "#5FAF6A"
        }
    }

    static func forDistance(_ meters: Double) -> Biome {
        var current = Biome.goldenHour
        for biome in Biome.allCases where meters >= biome.distanceThresholdMeters {
            current = biome
        }
        return current
    }
}
