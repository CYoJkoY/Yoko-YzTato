# Yoko-YzTato

[![Release](https://img.shields.io/github/v/release/CYoJkoY/Yoko-YzTato?display_name=tag&sort=semver)](https://github.com/CYoJkoY/Yoko-YzTato/releases)
[![License](https://img.shields.io/github/license/CYoJkoY/Yoko-YzTato)](LICENSE)
[![Release Workflow](https://github.com/CYoJkoY/Yoko-YzTato/actions/workflows/release.yml/badge.svg)](https://github.com/CYoJkoY/Yoko-YzTato/actions/workflows/release.yml)

> A content-heavy Brotato expansion built around custom characters, weapons, items, enemies, challenges, maps, effects, and supporting gameplay systems.

Yoko-YzTato is the gameplay/content layer of the Yoko Brotato mod stack. It uses [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader) to register structured content while using script extensions to add behaviors that cannot be expressed through content resources alone.

## What it adds

The repository is organized as a full content expansion rather than a single gameplay tweak. Its current content tree includes:

| Category | Repository location |
| :--- | :--- |
| Characters | `content/characters/` |
| Weapons | `content/weapons/` |
| Items | `content/items/` |
| Enemies / entities | `content/entities/` |
| Challenges | `content/challenges/` |
| Maps / backgrounds | `content/maps/` |
| Projectiles | `content/projectiles/` |
| Particles | `content/particles/` |
| Weapon / item sets | `content/sets/` |
| Structures | `content/structures/` |
| Zones | `content/zones/` |
| Scenes | `content/scenes/` |

The repository also contains multilingual translation resources and a large `NewContentDataDLC1.tres` resource that aggregates content for loading through Yoko-NewContentLoader.

## Gameplay systems

Yoko-YzTato also extends core Brotato scripts to support custom mechanics. The current extension set covers areas including:

- Enemy behavior.
- Player behavior and player-run data.
- Melee and ranged weapon behavior.
- Weapon container behavior.
- Projectile behavior.
- Entity spawning.
- Wave management.
- Shop and upgrade UI behavior.
- Item and weapon service behavior.
- Custom effect implementations and effect lookup support.

This allows the mod to combine ordinary `.tres` content definitions with targeted script extensions when a mechanic needs deeper integration with the base game.

## Installation

### Requirements

Yoko-YzTato declares a dependency on **Yoko-NewContentLoader**. Install both mods before enabling YzTato.

The current Yoko-NewContentLoader manifest targets Mod Loader 6.2.0, so using a compatible 6.2.x Mod Loader stack is recommended for the current release line.

### Install the release

Download the latest `YzTato-*.zip` from [Releases](https://github.com/CYoJkoY/Yoko-YzTato/releases) and place it in the game's `mods` directory used by Godot Mod Loader.

Also install:

```text
NewContentLoader-*.zip
```

from [Yoko-NewContentLoader Releases](https://github.com/CYoJkoY/Yoko-NewContentLoader/releases).

Keep the release files as ZIPs for normal Mod Loader installation.

For development, the expected dependency layout is:

```text
mods-unpacked/
├── Yoko-NewContentLoader/
└── Yoko-YzTato/
```

See the [Godot Mod Loader documentation](https://github.com/GodotModding/godot-mod-loader/wiki) for current mod installation and dependency conventions.

## How the content is loaded

Yoko-YzTato separates content definitions from engine-level behavior:

```text
Yoko-YzTato
├── content/
│   ├── characters/
│   ├── entities/
│   ├── items/
│   ├── weapons/
│   ├── challenges/
│   ├── maps/
│   ├── sets/
│   ├── zones/
│   └── ...
│
├── NewContentDataDLC1.tres
│
└── extensions/
    ├── game script extensions
    └── custom effects / services

             │
             ▼
    Yoko-NewContentLoader
             │
             ▼
       Brotato services
```

`NewContentDataDLC1.tres` references the custom resources and translations, while `mod_main.gd` installs the script extensions needed for additional runtime behavior.

## Project structure

```text
Yoko-YzTato/
├── content/
│   ├── challenges/
│   ├── characters/
│   ├── entities/
│   ├── items/
│   ├── maps/
│   ├── particles/
│   ├── projectiles/
│   ├── scenes/
│   ├── sets/
│   ├── structures/
│   ├── weapons/
│   └── zones/
├── extensions/
├── translations/
├── NewContentDataDLC1.tres
├── manifest.json
└── mod_main.gd
```

## Compatibility

| Component | Current target |
| :--- | :--- |
| Engine | Godot 3.x / GDScript |
| Mod Loader | Manifest declares 6.0.0; the dependency stack currently targets 6.2.0 |
| Dependency | Yoko-NewContentLoader |
| Version | 1.0.0 |

Because Yoko-YzTato depends on Yoko-NewContentLoader, compatibility should be evaluated at the stack level rather than from YzTato's Mod Loader field alone. Use matching releases of both projects.

## Development

The project is intended to be edited as a Brotato Godot 3.x mod. New content generally belongs under `content/` and is represented by Godot resources such as `.tres`; behavior that requires changes to existing game systems belongs under `extensions/`.

The extension list in `mod_main.gd` is the authoritative mapping of engine scripts replaced or extended by this mod. When adding a new extension, keep the path aligned with the target Brotato script and document the affected mechanic close to the registration entry.

Release builds are generated automatically from semantic version tags such as:

```text
v1.0.0
v1.1.0
v2.0.0
```

## Related projects

- [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader) — shared content registration and service-extension infrastructure.
- [Yoko-MoreStatsContainer](https://github.com/CYoJkoY/Yoko-MoreStatsContainer) — independent UI enhancement for paginated stat displays.
- [Yoko-DebugMenu](https://github.com/CYoJkoY/Yoko-DebugMenu) — runtime debugging and testing tools.

## License

This project is licensed under the [MIT License](LICENSE).

## 💰 Support the Author

If this project saves you time or improves your workflow, consider supporting its development.

<div align="center">
  <a href="https://cyojkoy.github.io/Payment/">
    <img src="https://img.shields.io/badge/Support_the_Author-9E8F7E?style=for-the-badge&logo=buy-me-a-coffee&logoColor=BEB8AE" alt="Support the Author">
  </a>
</div>

---

<div align="center">
  <sub>Yoko-YzTato · Brotato content expansion by CYoJkoY</sub>
</div>
