# Project ECLIPSE

**Alpha 0.2 — Standalone mobile browser RPG (in development)**

Project ECLIPSE is being developed as a touchscreen-friendly anime action RPG that runs in a modern mobile or desktop browser. The playable web version is separate from the original Roblox prototype.

## Play the browser version

Once GitHub Pages deployment is enabled and the first deployment succeeds, play at:

**https://arntn08.github.io/project-eclipse-rpg/**

Open the link in Chrome or another modern browser on Android, iPhone, tablet, or desktop. Tap **Enter the Rift**, choose a class, move with the on-screen joystick, and use Attack, Skill, and Ultimate.

## Alpha 0.2 gameplay

- Choose Swordsman, Mage, or Archer.
- Move around the arena using touchscreen joystick or WASD/arrow keys.
- Fight Rift Shades and stronger enemies.
- Use class-specific skills and charge your ultimate through combat.
- Clear three areas and challenge the Eclipse Overlord.
- Earn XP and Gold, level up, buy equipment, and upgrade Power Core.
- Check quests, gear, skills, and hunter profile.
- Local progress is stored in the browser on the device.

## Controls

| Action | Mobile / Tablet | Keyboard |
|---|---|---|
| Move | On-screen joystick | WASD / Arrow keys |
| Basic attack | ATTACK | F / Space |
| Class skill | SKILL | Q |
| Ultimate | ULT | E |
| Menus | Bottom navigation | Touch/click |

## Save data

Alpha 0.2 uses browser localStorage. Progress is saved on the current browser and device. Clearing browser site data or switching browsers/devices may erase or not transfer this save. Cloud accounts and cross-device saving are not implemented yet.

## Development status

This is an early playable prototype, not a finished commercial game. The arena uses canvas-drawn placeholder characters and enemies. Combat, touch controls, boss progression, and save behavior still need real-device testing and balancing. Report bugs with your device/browser and what happened.

## Original Roblox prototype

The `src/` directory and `default.project.json` preserve the earlier Roblox/Rojo prototype. Those files are not used by the browser game. The browser version lives in the root `index.html`, `styles.css`, and `game.js` files and deploys through GitHub Pages.

## Roadmap

1. Improve character sprites, animations, and combat feedback.
2. Add more dungeon maps, enemy types, boss phases, and loot.
3. Expand inventory, equipment, quests, and skill trees.
4. Add audio, settings, accessibility, and better save management.
5. Evolve the game toward a 3D version while retaining the ECLIPSE identity.
