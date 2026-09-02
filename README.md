<p align="center">
  <strong>Ripple Run</strong><br>
  <em>Skip the endless lake.</em>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey?style=flat-square" alt="iOS 17+"></a>
  <a href="#"><img src="https://img.shields.io/badge/built%20with-SwiftUI%20%2B%20SpriteKit-orange?style=flat-square" alt="SwiftUI + SpriteKit"></a>
  <a href="#"><img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="MIT License"></a>
</p>

---

Throw once. Bounce forever.

**Ripple Run** is a meditative endless stone-skipper for iPhone — part cozy lake journal, part “one more try” arcade classic. Pebble throws from a wooden dock. You guide the stone across glassy water, chain skips into the sunset, boost through golden currents, and see how far the lake goes.

Calm on the surface. Addictive underneath.

<p align="center">
  <code>🪨  swipe · skip · boost · repeat</code>
</p>

---

## Why you'll keep skipping

**It feels good.**  
Every skip lands with a soft plink that rises as your combo builds. Gentle haptics. No chaos — just flow.

**It’s easy to start, hard to put down.**  
Swipe to throw. Hold to rise. Double-tap to bounce over logs. Hit **BOOST** when momentum fades. One more run takes three seconds.

**The lake keeps changing.**  
Golden Hour → Mist Morning → Glass Twilight → Still Arctic → Ember Deep. The farther you go, the more the world shifts.

**You always grow stronger.**  
Earn **Ripples** every run. Upgrade permanent **Skills** at the dock. Equip **Items** before your next throw. Come back stronger even when you sink.

**Compete without the stress.**  
Game Center **Global** and **Friends** leaderboards track your best distance in meters. Quiet bragging rights.

---

## How it plays

| Moment | What you do |
|--------|-------------|
| **The Dock** | Cozy home screen — Play, Shop, Leaderboard, Settings |
| **The Throw** | Pebble winds up; swipe for power, slider for angle |
| **The Flight** | Hold to float, double-tap to bounce, **BOOST** to surge |
| **The Skip** | Chain clean water hits to keep speed and build combo |
| **The Lake** | Collect pearls, ride golden speed currents, thread past logs |
| **The Sink** | One free **Last Ripple** continue — or let go peacefully |
| **The Return** | Spend Ripples, equip an item, skip again |

---

## Dock Shop

Build your run between sessions.

### Skills · permanent upgrades
Launch Power · Skip Forgiveness · Double Bounce · Bounce Float · Pearl Magnet · **Boost Tank** · **Boost Power** · **Speed Retention** · **Combo Momentum**

### Items · equip one for your next run
**Surge Pack** — extra boosts · **Tailwind Draught** — faster launch · **Glide Charm** — forgiving skips · **Momentum Seed** — explosive first skip

---

## Sound & haptics

Ripple Run is designed to feel like ASMR with stakes.

- Skip tones that climb with your combo  
- Soft taps on bounces, pearls, and biome shifts  
- A satisfying surge when you **BOOST**  
- Toggle sound and haptics anytime in Settings  

---

## Screenshots

> Coming soon — golden-hour dock, neon dusk skips, leaderboard flex.

<!-- Replace with App Store screenshots when ready:
<p align="center">
  <img src="docs/screenshots/dock.png" width="220" alt="Dock">
  <img src="docs/screenshots/gameplay.png" width="220" alt="Gameplay">
  <img src="docs/screenshots/shop.png" width="220" alt="Shop">
</p>
-->

---

## For developers

Native iOS game built with **SwiftUI**, **SpriteKit**, and **Game Center**.

### Requirements
- macOS · Xcode 16+  
- iPhone · iOS 17+  
- Apple Developer account (device testing & Game Center)

### Run locally

```bash
git clone https://github.com/JamesCV/RippleLoop.git
cd RippleLoop
open RippleLoop.xcodeproj
```

1. Select the **RippleLoop** scheme  
2. Confirm **Game Center** capability is enabled (entitlements included)  
3. Run on simulator or device (**⌘R**)

### Game Center setup

Create a leaderboard in [App Store Connect](https://appstoreconnect.apple.com):

| Field | Value |
|-------|-------|
| Leaderboard ID | `com.rippleloop.game.bestdistance` |
| Score format | Integer · High to low |
| Unit | Best distance (meters) |

### Project layout

```
RippleLoop/
├── Services/     # Game Center, sound, haptics
├── Views/        # Dock, shop, results, leaderboard
├── Game/         # Physics, biomes, Pebble, spawner
└── Models/       # Progress, shop catalog, session
```

Run tests: **⌘U**

---

## Roadmap

- [ ] App Store launch  
- [ ] Screenshots & preview video  
- [ ] Seasonal dock themes  
- [ ] Shareable skip replay clips  

---

<p align="center">
  <strong>Ripple Run</strong> — the lake never ends.<br>
  Made with calm and curiosity.
</p>

<p align="center">
  MIT License · <a href="https://github.com/JamesCV/RippleLoop">github.com/JamesCV/RippleLoop</a>
</p>
