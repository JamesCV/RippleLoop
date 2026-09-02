import Foundation

final class GameplaySettings: ObservableObject {
    static let shared = GameplaySettings()

    private enum Key {
        static let soundEnabled = "ripplerun.settings.sound"
        static let hapticsEnabled = "ripplerun.settings.haptics"
    }

    private let defaults = UserDefaults.standard

    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Key.soundEnabled) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Key.hapticsEnabled) }
    }

    private init() {
        if defaults.object(forKey: Key.soundEnabled) == nil {
            defaults.set(true, forKey: Key.soundEnabled)
        }
        if defaults.object(forKey: Key.hapticsEnabled) == nil {
            defaults.set(true, forKey: Key.hapticsEnabled)
        }
        soundEnabled = defaults.bool(forKey: Key.soundEnabled)
        hapticsEnabled = defaults.bool(forKey: Key.hapticsEnabled)
    }
}
