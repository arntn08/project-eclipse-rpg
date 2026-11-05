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
- Basic Shade enemy AI that pursues and attacks nearby hunters
- Boss and enemy attack warning zones with dodge windows
- Floating damage numbers on successful hits
- Equipped weapon visuals attached to the character's hand
- Mobile hunter vitality bar with live HP updates
- Class energy system with automatic regeneration
- Different energy costs for Swordsman, Mage, and Archer skills
- Class-colored skill effects: expanding area bursts and focused piercing beams
- Live mobile energy meter
- Persistent class-specific skill trees with three upgrade branches
- Gold-funded upgrades with server-side validation and rank caps
- Power Core: increases basic attack damage
- Energy Flow: reduces skill energy costs
- Skill Mastery: increases skill damage
- Mobile skill tree menu with live gold and rank updates
- Level requirements and selling unequipped items

## Starter equipment
- Training Blade: +4 attack
- Novice Armor: +5 defense

## Class skills
| Class | Skill | Energy cost | Cooldown |
|---|---|---:|---:|
| Swordsman | Shadow Spin | 30 | 8s |
| Mage | Arcane Nova | 40 | 10s |
| Archer | Piercing Shot | 25 | 7s |

Energy capacity is 100 and regenerates at 8 per second. Skill use is validated by the server.

## Skill tree upgrades
Each class has its own saved ranks across three branches. Upgrades cost Gold and are capped at Rank 3.

| Branch | Effect per rank | Gold costs |
|---|---|---|
| Power Core | +5% basic attack damage | 100 / 200 / 350 |
| Energy Flow | -5% skill energy cost | 100 / 200 / 350 |
| Skill Mastery | +8% skill damage | 150 / 250 / 400 |

## Build and test
This is a Rojo project. Roblox Studio is required on a supported Windows or macOS computer. Install Rojo, run `rojo serve`, and connect Studio using the Rojo plugin.

Publish the experience before testing persistent DataStores. Enable **Game Settings → Security → Enable Studio Access to API Services** for Studio DataStore tests.

## Controls
- Desktop: F = attack; Q = skill; E at the portal = enter dungeon.
- Mobile: use Attack, Skill, and Inventory buttons; monitor HP and Energy bars; interact with the portal prompt.
- Inventory lets you equip items or sell unequipped items.

## Development status
This is an early prototype. Arena, dungeon, enemies, and boss visuals use placeholder Parts. The source has been committed to GitHub but has not been validated in a Roblox Studio playtest. Enemy movement and attack timing, weapon attachment alignment, warning-zone placement, skill effects, energy regeneration, skill-tree purchases and saved ranks, and mobile HUD layout still require Studio testing. Test all gameplay and saving before public release.

## Next milestones
1. Ultimate transformation and class ultimate abilities
2. Class-specific animation assets and polished weapon models
3. Quests, achievements, and more dungeon themes
4. Party dungeons and multiplayer rewards
5. Character customization and polished environments
