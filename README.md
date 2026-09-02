# Ripple Run

A meditative endless stone-skipping iPhone game. Pebble throws from a cozy dock; you guide the stone with gentle bounces, chain skips across infinite lakes, unlock upgrades, and chase new biomes.

## Requirements

- macOS with Xcode 16+
- Apple Developer account (for device testing and App Store release)
- iPhone running iOS 17+

## Open and Run

1. Open `RippleLoop.xcodeproj` in Xcode.
2. Select the **RippleLoop** scheme.
3. Choose an iPhone simulator or a connected device.
4. Press **Run** (⌘R).

## Gameplay

- **Dock menu** — cozy home screen with Play, Shop, and stats.
- **Throw** — Pebble winds up; swipe to set power and angle.
- **Flight** — hold to rise, release to fall (Jetpack-style vertical control).
- **Double bounce** — two quick taps for extra height (limited per air segment).
- **Skips** — chain water skips to build combo multiplier.
- **Pearls** — collect during runs for bonus Ripples.
- **Biomes** — Golden Hour → Mist Morning → Glass Twilight → Still Arctic → Ember Deep.
- **Last Ripple** — on death, watch an ad, spend Pebbles, or use a daily continue.
- **Workbench** — spend Ripples on permanent upgrades between runs.

## Controls

- **Swipe** from the lower-left to aim Pebble's throw.
- **Right-edge slider** adjusts launch angle.
- **Hold** during flight to rise gently.
- **Double-tap** for a double bounce over obstacles.
- Collect pearls in low / mid / high lanes.

## Project Structure

```
RippleLoop/
├── Views/              # SwiftUI dock, shop, results, continue flow
├── Game/               # SpriteKit scenes, Pebble, physics, spawner
├── Models/             # Biomes, upgrades, progress, session state
└── RippleLoopTests/    # Physics unit tests
```

## Monetization (planned)

- Free with rewarded ads (continue, bonus Ripples).
- IAP: Pebble packs, Remove Ads, Skip Pass, cosmetics.
- Continue/resurrection is the primary paid moment.

## Tests

Run unit tests with **⌘U**. `StonePhysicsTests` covers launch, skip, and bounce physics.

## License

MIT
