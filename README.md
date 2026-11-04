# Project ECLIPSE — Alpha 0.1

A mobile-first anime action RPG for Roblox, inspired by classic anime action RPG combat.

## Alpha 0.1 systems
- Swordsman, Mage, and Archer class selection
- Server-validated basic attacks and class skills
- Three-hit combo finisher
- Skill cooldowns and class-specific abilities
- Training enemies with health displays and respawns
- XP, levels, and gold rewards
- Basic profile saving through DataStoreService
- Touch-friendly on-screen Attack and Skill controls

## Class abilities
| Class | Basic attack | Skill |
|---|---|---|
| Swordsman | Balanced close-range hit | Shadow Spin — area damage |
| Mage | Ranged magic hit | Arcane Nova — larger area damage |
| Archer | Precise ranged hit | Piercing Shot — high single-target damage |

## Build
This repository is a Rojo project. Install Roblox Studio on a supported Windows or macOS computer, install Rojo, then run:

```sh
rojo serve
```

Connect Roblox Studio using the Rojo plugin. Open the place, test in Studio, and publish it before testing persistent DataStores. Enable **Game Settings → Security → Enable Studio Access to API Services** for Studio DataStore tests.

## Controls
- Desktop: F = basic attack; Q = class skill.
- Mobile: tap the on-screen Attack and Skill buttons.
- Select a class from the class panel when you join.

## Important
This is an early playable foundation, not a finished game. The arena and enemies currently use simple Parts. Replace them with custom rigs, animations, effects, maps, and sound as development continues.

## Next milestones
1. Dungeon entrances, stage progression, and boss encounters
2. Character rigs and class-specific animations
3. Equipment, inventory, and loot
4. Quests, party play, and polished anime RPG UI
