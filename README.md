# Ripple Run

A meditative endless stone-skipping iPhone game. Pebble throws from a cozy dock; you guide the stone with gentle bounces, chain skips across infinite lakes, unlock upgrades, and chase new biomes.

## Requirements

- macOS with Xcode 16+
- Apple Developer account (for device testing, Game Center, and App Store release)
- iPhone running iOS 17+

## Open and Run

1. Open `RippleLoop.xcodeproj` in Xcode.
2. Select the **RippleLoop** scheme.
3. Enable **Game Center** capability (Signing & Capabilities — should auto-apply from entitlements).
4. Choose an iPhone simulator or a connected device.
5. Press **Run** (⌘R).

## Game Center Leaderboards

Create a leaderboard in [App Store Connect](https://appstoreconnect.apple.com) → your app → Game Center:

| Field | Value |
|-------|-------|
| Leaderboard ID | `com.rippleloop.game.bestdistance` |
| Score format | Integer |
| Sort order | High to low |
| Score range | 0 – 999,999 |

Scores represent **best distance in meters**. The app submits after each run and shows **Global** and **Friends** tabs on the dock **Board** screen.

Sign in with a Game Center sandbox account on device/simulator to test.

## Gameplay

- **Dock menu** — Play, Shop, Board (leaderboards), Settings
- **Throw** — Pebble winds up; swipe to set power and angle
- **Flight** — hold to rise, double-tap to bounce over obstacles
- **Skips** — chain skips build combo multiplier with ASMR tones + haptics
- **Biomes** — five distance-based environments
- **Last Ripple** — one free continue per run (no ads/IAP yet)
- **Workbench** — spend Ripples on permanent upgrades

## Sound & Haptics

Procedural skip tones (pitch rises with combo) and UIKit haptics on skips, bounces, pearls, biome shifts, and new bests. Toggle both in **Settings** on the dock.

## Project Structure

```
RippleLoop/
├── Services/           # Game Center, sound, haptics, settings
├── Views/              # SwiftUI screens
├── Game/               # SpriteKit gameplay
└── Models/             # Progress, biomes, upgrades
```

## Tests

Run unit tests with **⌘U**.

## License

MIT
