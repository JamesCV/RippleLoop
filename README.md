# RippleLoop

A cozy stone-skipping iPhone game built with SwiftUI and SpriteKit. Skip stones across calm water, chain skips, use IMPULSE boosts, and chase your best distance.

## Requirements

- macOS with Xcode 16+
- Apple Developer account (for device testing and App Store release)
- iPhone running iOS 17+ (simulator works for quick iteration)

## Open and Run

1. Open `RippleLoop.xcodeproj` in Xcode.
2. Select the **RippleLoop** scheme.
3. Choose an iPhone simulator or a connected device.
4. Press **Run** (⌘R).

## Controls

- **Swipe** from the lower-left area to set throw power and direction.
- **Right-edge slider** adjusts launch angle (matches the reference game's angle control).
- **IMPULSE** button (top-right) or tap during flight to boost speed (limited uses per run).
- **Tap** after a run ends to throw again.

## Project Structure

```
RippleLoop/
├── RippleLoopApp.swift          # App entry
├── ContentView.swift            # SwiftUI + SpriteView host
├── Game/
│   ├── GameScene.swift          # Main gameplay loop
│   ├── StonePhysics.swift       # Skip physics (unit tested)
│   ├── ParallaxBackground.swift # Procedural sunset world
│   ├── HUDNode.swift            # Distance, speed, results UI
│   ├── AimOverlay.swift         # Swipe arc + angle slider
│   └── GameConstants.swift      # Tunable gameplay values
└── Models/
    ├── GameState.swift
    └── PlayerProgress.swift     # Best distance persistence
```

## Tuning Gameplay

Edit `Game/GameConstants.swift` to adjust gravity, skip angles, impulse strength, and meters scaling without touching scene code.

## Tests

Run unit tests with **⌘U**. `StonePhysicsTests` covers launch power scaling and skip eligibility.

## App Store Checklist

Before submitting:

1. Set **Development Team** in Xcode → Signing & Capabilities for both targets.
2. Change `PRODUCT_BUNDLE_IDENTIFIER` from `com.rippleloop.game` to your own reverse-DNS ID.
3. Add a 1024×1024 app icon in `Assets.xcassets/AppIcon`.
4. Create the app record in [App Store Connect](https://appstoreconnect.apple.com).
5. Archive with **Product → Archive**, then upload via Organizer.
6. Fill in privacy, age rating, screenshots, and description in App Store Connect.

`PrivacyInfo.xcprivacy` is included with no tracking. `ITSAppUsesNonExemptEncryption` is set to `false` in Info.plist.

## Next Features to Build

- Upgrade shop (extra impulses, launch power)
- Biome parallax chunks as distance increases
- Sound design and haptics
- Game Center leaderboards
- iCloud sync for progress

## License

MIT — use and modify freely for your App Store release.
