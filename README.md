# Project ECLIPSE — Alpha 0.1

A mobile-first anime action RPG for Roblox.

## Current gameplay systems
- Swordsman, Mage, and Archer classes
- Server-validated basic attacks, skills, and three-hit combos
- Training arena and practice enemies
- Personal three-stage dungeon with enemy waves
- Eclipse Overlord boss encounter
- XP, levels, gold, and player profile saving
- Mobile Attack and Skill controls
- Inventory with Weapon and Armor slots
- Common, Rare, and Epic equipment
- Dungeon enemy and boss loot drops
- Equipment bonuses applied to combat damage
- Level requirements and selling unequipped items

## Starter equipment
- Training Blade: +4 attack
- Novice Armor: +5 defense

## Class skills
| Class | Skill |
|---|---|
| Swordsman | Shadow Spin |
| Mage | Arcane Nova |
| Archer | Piercing Shot |

## Build and test
This is a Rojo project. Roblox Studio is required on a supported Windows or macOS computer. Install Rojo, run `rojo serve`, and connect Studio using the Rojo plugin.

Publish the experience before testing persistent DataStores. Enable **Game Settings → Security → Enable Studio Access to API Services** for Studio DataStore tests.

## Controls
- Desktop: F = attack; Q = skill; E at the portal = enter dungeon.
- Mobile: use Attack, Skill, and Inventory buttons; interact with the portal prompt.
- Inventory lets you equip items or sell unequipped items.

## Development status
This is an early prototype. Arena, dungeon, enemies, and boss visuals use placeholder Parts. The source has been committed to GitHub but has not been validated in a Roblox Studio playtest. Test all gameplay and saving before public release.

## Next milestones
1. Character rigs, class animations, and combat effects
2. Enemy AI and boss telegraphs
3. Quests, achievements, and more dungeon themes
4. Party dungeons and multiplayer rewards
5. Polished character and progression menus
