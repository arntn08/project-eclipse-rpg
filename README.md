# Project ECLIPSE — Alpha 0.1

A mobile-first anime action RPG for Roblox, inspired by classic anime action RPG combat.

## Current systems
- Swordsman, Mage, and Archer class selection
- Server-validated basic attacks, class skills, and three-hit combo finisher
- Skill cooldowns
- Training arena and respawning practice enemies
- ECLIPSE Gate portal with proximity interaction
- Personal dungeon room for each player
- Three dungeon stages with two waves per stage
- Enemy waves that scale by stage
- Eclipse Overlord boss with a health bar and pulse attack
- Dungeon clear rewards, XP, levels, and gold
- Basic player profile saving through DataStoreService
- Mobile-friendly Attack and Skill controls
- Dungeon progress and boss HUD

## Class abilities
| Class | Skill | Behavior |
|---|---|---|
| Swordsman | Shadow Spin | Area damage |
| Mage | Arcane Nova | Larger area damage |
| Archer | Piercing Shot | High single-target damage |

## Dungeon loop
1. Walk to the blue ECLIPSE Gate in the hub.
2. Use the on-screen prompt to enter your personal dungeon.
3. Clear two waves in each of the three stages.
4. Defeat the Eclipse Overlord in the final wave.
5. Receive completion rewards and return to the hub.

Dungeon enemy strength increases with each stage. The final boss has 450 health and periodically damages players within its attack radius.

## Build and test
This repository is a Rojo project. Roblox Studio is required and runs on supported Windows or macOS computers. Install Rojo, then run:

```sh
rojo serve
```

Connect Roblox Studio using the Rojo plugin. Open the place and test with **Play**. Publish the experience before testing persistent DataStores. Enable **Game Settings → Security → Enable Studio Access to API Services** for Studio DataStore tests.

## Controls
- Desktop: F = basic attack; Q = class skill; E at the portal = enter dungeon.
- Mobile: use the on-screen Attack and Skill buttons; tap the portal prompt to enter.
- Choose Swordsman, Mage, or Archer from the class panel.

## Development status
This is an expanding prototype. The arena, portal, enemies, and boss are currently generated from simple Parts. They are gameplay placeholders, not final anime character models or animated assets. The systems have been committed to GitHub but still require Roblox Studio runtime testing.

## Planned next milestones
1. Enemy movement, attack animations, hit effects, and class animation sets
2. Inventory, equipment, weapon drops, and loot UI
3. More dungeon themes, boss mechanics, and party matchmaking
4. Quest system, save-data expansion, and polished game menus
