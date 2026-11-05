# PROJECT ECLIPSE

**Alpha 0.3 — Standalone mobile browser action RPG (in development)**

Project ECLIPSE is a touchscreen-friendly, side-scrolling anime action RPG that runs in a modern mobile or desktop browser. It is a standalone website game, separate from the original Roblox prototype.

## Play the browser version

Once GitHub Pages is enabled and deployment succeeds:

**https://arntn08.github.io/project-eclipse-rpg/**

Open the link in Chrome or another modern browser. Choose a class and tap **Enter the Rift**. Landscape mode is recommended on phones and tablets.

## Alpha 0.3 features

- Choose Swordsman, Mage, or Archer, each with different stats, movement speed, skills, and ultimate attacks.
- Side-scrolling dungeon environment with parallax scenery.
- Canvas-drawn hunter and enemy characters, attack effects, hit effects, and boss telegraphs.
- Touch joystick plus Attack, Skill, Ultimate, and Dash buttons.
- Three enemy stages followed by the Eclipse Overlord.
- XP, leveling, gold, equipment purchases, Power Core upgrades, quests, and hunter profile.
- Local browser save; Alpha 0.2 save data is read as a migration fallback.

## Controls

| Action | Mobile / Tablet | Keyboard |
|---|---|---|
| Move | On-screen joystick | WASD / Arrow keys |
| Basic attack | ATTACK | F / Space |
| Class skill | SKILL | Q |
| Ultimate | ULT | E |
| Dash | DASH | Shift |
| Menus | Bottom navigation | Touch/click |

## Animated hunter artwork

The Alpha 0.3 renderer now supports a 4×4 animated anime hunter sprite sheet. The game loads it from the repository-root file `eclipse-hunter.webp`; if that file is not present yet, it automatically falls back to the built-in canvas character.

To enable the new artwork, upload the supplied `eclipse-hunter.webp` file to the repository root (same level as `index.html`) and commit it. The rows are idle, run, attack, and skill/ultimate animations, with four frames per row.

## Save data

Progress is stored in browser localStorage on the current browser and device. It does not yet sync between devices or use a cloud account. Clearing site data can erase progress.

## Development status

Alpha 0.3 is an early playable prototype, not a finished commercial game. The characters and environments are currently drawn with canvas code rather than finished sprite sheets or external art assets. Gameplay, balance, touch behavior, and performance still require real-device testing.

## Original Roblox prototype

The `src/` directory and `default.project.json` preserve the earlier Roblox/Rojo prototype. The standalone browser game uses the root `index.html`, `styles.css`, and `game-v03.js` files. The previous `game.js` is retained as the Alpha 0.2 source.

## Roadmap

1. Replace canvas-drawn placeholders with animated anime sprite sheets.
2. Add richer combo chains, dodge timing, enemy variants, and boss phases.
3. Expand dungeon maps, equipment, loot, quests, and character progression.
4. Add sound, settings, accessibility, and improved save management.
5. Explore a future 3D evolution while preserving the ECLIPSE identity.
