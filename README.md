# PROJECT ECLIPSE

**Alpha 0.9 — Expanded standalone mobile browser action RPG (in development)**

Project ECLIPSE is a touchscreen-friendly side-scrolling anime action RPG. It is a standalone browser game and remains separate from the original Roblox prototype.

## Play
https://arntn08.github.io/project-eclipse-rpg/

Open in a modern browser, choose Swordsman, Mage, or Archer, then enter the Rift. Landscape mode is recommended on phones and tablets.

## Current features
- Three selectable classes with distinct stats, class-colored combat presentation, weapon/aura overlays, and class skills/ultimates.
- 4×4 hunter sprite sheet support (eclipse-hunter.webp) with canvas fallback if the image is unavailable.
- Touch joystick, Attack, Skill, Ultimate, and Dash; keyboard controls are also supported.
- Three themed rift stages, enemy variants, elite-style brute encounters, and the Eclipse Overlord with escalating combat phases.
- XP, leveling, gold, equipment purchases, rare/epic gear, Power Core and Vitality upgrades, and consumable Rift Potions.
- Daily defeat quest with local-date rollover, achievement milestones, combat records, and hunter profile.
- Settings panel with sound-effect toggle and control/display tips.
- Browser localStorage autosave and migration fallback for earlier Alpha 0.2 data.

## Controls

| Action | Touch | Keyboard |
|---|---|---|
| Move | On-screen joystick | WASD / Arrow keys |
| Basic attack | ATTACK | F / Space |
| Class skill | SKILL | Q |
| Ultimate | ULT | E |
| Dash | DASH | Shift |
| Menus | Bottom navigation | Touch/click |

## Sprite artwork
The game loads eclipse-hunter.webp from the repository root. The 4×4 sheet is expected to contain idle, run, attack, and skill/ultimate rows, four frames per row. If unavailable, the game uses its built-in canvas fallback. The current sprite depicts the hunter base character; Mage and Archer receive class-specific visual effects and weapon silhouettes rather than separate full sprite sheets.

## Save data and limitations
Progress is stored locally in the current browser. It does not sync across devices and clearing browser site data may erase it. Daily quest progress rolls over using the device's local date. Sound effects are synthesized in-browser and can be muted in Settings.

This remains an early prototype. It has not been verified through a complete real-device playtest after this update. Please test combat, touch controls, purchases, save/load, and boss completion on the live Pages deployment.

## Original Roblox prototype
The original Roblox/Rojo prototype is preserved separately. The browser game uses root index.html, styles.css, and game-v03.js; game.js remains the earlier Alpha 0.2 source.

## Roadmap
Future work: separate Mage and Archer sprite sheets, more dungeon maps and bosses, cloud saves, richer sound/music, accessibility options, and eventual 3D evolution.
