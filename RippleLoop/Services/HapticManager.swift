import UIKit

enum HapticManager {
    private static var settings: GameplaySettings { GameplaySettings.shared }

    static func skip(combo: Int = 1) {
        guard settings.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: combo >= 5 ? .medium : .light)
        generator.prepare()
        generator.impactOccurred(intensity: min(1, 0.45 + CGFloat(combo) * 0.05))
    }

    static func bounce() {
        guard settings.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.55)
    }

    static func doubleBounce() {
        guard settings.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    static func pearl() {
        guard settings.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred(intensity: 0.45)
    }

    static func launch() {
        guard settings.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 0.7)
    }

    static func sink() {
        guard settings.hapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.25)
    }

    static func newBest() {
        guard settings.hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func menuTap() {
        guard settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.35)
    }

    static func biomeShift() {
        guard settings.hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.4)
    }
}
