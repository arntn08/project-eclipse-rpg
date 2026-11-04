# Project ECLIPSE — Alpha 0.1

A mobile-first anime action RPG for Roblox, inspired by classic side-scrolling anime RPG combat.

## Alpha 0.1 foundation
- Swordsman, Mage, and Archer class selection
- Server-validated basic attacks
- Simple training enemies with health
- XP, levels, and gold rewards
- Basic profile saving through DataStoreService
- Touch-friendly on-screen attack controls

## Build
This repository is a Rojo project. Install Roblox Studio on a supported Windows or macOS computer, install Rojo, then run:

```sh
rojo serve
```

Connect Roblox Studio using the Rojo plugin. Open the place, test in Studio, and publish it before testing persistent DataStores. Enable **Game Settings → Security → Enable Studio Access to API Services** for Studio DataStore tests.

## Important
This is an early playable foundation, not a finished game. The first enemies and arena are generated from simple Parts. Replace them with custom rigs, animations, effects, maps, and sound as development continues.

## Controls
- Desktop: click/tap the on-screen Attack button or press F.
- Mobile: tap the on-screen Attack button.
- Select a class from the class panel when you join.

## Next milestones
1. Character rigs and class-specific animations
2. Skills, cooldowns, and ultimate attacks
3. Dungeon stages, portals, and bosses
4. Equipment, inventory, and loot
5. Quests, party play, and polished anime UI
