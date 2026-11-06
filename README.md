# PROJECT ECLIPSE

**Alpha 1.0 — Side-scrolling anime action RPG (in development)**

Standalone browser game, separate from the original Roblox prototype.

## Play
https://arntn08.github.io/project-eclipse-rpg/

## Playable hunters
- **Swordsman** — close-range heavy blade attacks.
- **Mage** — ranged arcane magic and area attacks.
- **Archer** — long-range precision attacks.
- **Assassin** — fast movement, shadow blades and critical-style attacks.

Mage, Archer and Assassin now have distinct canvas-drawn character designs. Swordsman uses the existing animated hunter sprite sheet when it loads, with a built-in fallback.

## Grand Chase-inspired controls

| Input | Action |
|---|---|
| ← / → | Move left / right |
| ↑ | Jump |
| ↓ | Guard and reduce incoming damage |
| Z | Basic attack / combo starter |
| X | Class skill 1 |
| C | Class skill 2 |
| V | Ultimate when the gauge is full |
| Shift | Dash / evade |

Touch controls remain available on phones and tablets, including the joystick and on-screen combat buttons.

## Monsters and encounters
- Shadow Shades, Hounds, Brutes, Wraiths, Slimes and Golems.
- Three rift stages with different atmosphere and enemy strength.
- Eclipse Overlord boss with three escalating combat phases.
- Enemy telegraphs, health bars, hit effects, loot drops and potion rewards.

## Progression
XP and levels, gold, rare and epic weapons/armor, Power Core and Vitality upgrades, Rift Potions, daily defeat quest, achievements, hunter profile, and local browser autosave.

## Save and limitations
Save data is stored in the current browser only; there is no cloud sync yet. This is an early prototype and has not been fully playtested on every device. Use a modern browser and landscape orientation on phones for the best layout.

## Original Roblox prototype
The original Roblox/Rojo prototype remains separate and preserved. The browser game uses root `index.html`, `styles.css`, and `game-v03.js`; `game.js` remains the earlier engine.
