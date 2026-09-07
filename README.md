<div align="center">

# Yoko-YzTato

**A content-heavy Brotato expansion for new characters, weapons, worlds, enemies, and custom gameplay systems.**

<p>
  <a href="https://github.com/CYoJkoY/Yoko-YzTato/releases"><img src="https://img.shields.io/github/v/release/CYoJkoY/Yoko-YzTato?display_name=tag&sort=semver&style=flat-square&label=release" alt="Latest release"></a>
  <a href="https://github.com/CYoJkoY/Yoko-YzTato/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/CYoJkoY/Yoko-YzTato/release.yml?style=flat-square&label=build" alt="Build status"></a>
  <img src="https://img.shields.io/badge/Brotato-1.15.4-478CBF?style=flat-square" alt="Brotato 1.15.4">
  <img src="https://img.shields.io/badge/Mod%20Loader-6.3.0-5965FF?style=flat-square" alt="Mod Loader 6.3.0">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/CYoJkoY/Yoko-YzTato?style=flat-square" alt="MIT License"></a>
</p>

<p>
  <a href="#content">Content</a> ·
  <a href="#runtime-systems">Runtime systems</a> ·
  <a href="#installation">Installation</a> ·
  <a href="#development">Development</a>
</p>

</div>

## What it is

Yoko-YzTato is the content and gameplay layer of the Yoko Brotato mod stack. It combines Godot resource data with focused runtime extensions, using [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader) to register structured content without forcing every content type into custom registration code.

The project is designed around a simple boundary:

```text
Content data → shared registration → targeted runtime extension → Brotato
```

That separation lets a new weapon, character, map, or effect remain inspectable as game data while mechanics that need deeper integration can attach to the Brotato system that owns them.

## Content

The repository organizes content into explicit categories:

| Category | Location |
| :--- | :--- |
| Characters | `content/characters/` |
| Weapons | `content/weapons/` |
| Items | `content/items/` |
| Enemies / entities | `content/entities/` |
| Challenges | `content/challenges/` |
| Maps / backgrounds | `content/maps/` |
| Projectiles | `content/projectiles/` |
| Particles | `content/particles/` |
| Sets | `content/sets/` |
| Structures | `content/structures/` |
| Zones | `content/zones/` |
| Scenes | `content/scenes/` |

`NewContentDataDLC1.tres` aggregates the content resources consumed by the loader. Localization remains under `translations/`.

## Runtime systems

Resource data is not enough for every mechanic, so YzTato adds narrow extensions around Brotato systems.

| Area | Examples |
| :--- | :--- |
| Combat | Melee and ranged weapon behavior, projectiles, hit effects, custom effects |
| Entities | Enemy behavior, targeting, spawning, and entity-specific logic |
| Run / player | Player data and run-state integration |
| Waves | Wave management and entity spawning |
| Shop / upgrades | Shop and upgrade UI behavior, item and weapon service hooks |
| Content services | Item, weapon, effect, and lookup support |

The rule is to extend the owning service rather than create a parallel gameplay system.

## Installation

### Requirements

- Brotato **1.15.4**
- **Brotato Mod Loader 6.3.0**
- [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader)

The dependency on NewContentLoader is declared in `manifest.json`.

### Release installation

1. Install Brotato 1.15.4 and Mod Loader 6.3.0.
2. Install the matching Yoko-NewContentLoader release.
3. Download the latest `YzTato-*.zip` from [Releases](https://github.com/CYoJkoY/Yoko-YzTato/releases).
4. Place the ZIP in the Mod Loader `mods` directory.
5. Launch Brotato and verify that both the dependency and YzTato load correctly.

Keep the release ZIP compressed for normal installation.

### Development layout

```text
mods-unpacked/
├── Yoko-NewContentLoader/
└── Yoko-YzTato/
```

See the [Godot Mod Loader documentation](https://wiki.godotmodding.com/) for current installation conventions.

## How content reaches the game

```text
content/*
   │
   ▼
NewContentDataDLC1.tres
   │
   ▼
Yoko-NewContentLoader
   │
   ▼
Brotato services
   │
   ├── item / weapon pools
   ├── entities / effects
   ├── challenges / zones
   └── translations
```

When resource data alone cannot express a mechanic, the corresponding implementation lives under `extensions/` and hooks into the existing Brotato system rather than replacing it wholesale.

## Development

The main entry point is `mod_main.gd`; content registration is centered around `NewContentDataDLC1.tres`.

For a new feature, keep the responsibilities separated:

```text
New feature
   ├── Resource data    → content/
   ├── Runtime hook     → extensions/
   ├── Registration     → NewContentDataDLC1.tres
   └── Localization     → translations/
```

Changes to shared runtime behavior should be tested with Yoko-NewContentLoader and the complete mod stack because a loader-facing change can affect every dependent project.

## Release pipeline

The release workflow uses semantic version tags and treats `manifest.json` as authoritative.

```text
manifest.json: 1.1.0
        │
        ├── tag v1.1.0  → build allowed
        └── tag v1.2.0  → build rejected
```

The workflow imports Godot resources, preserves generated `.import` data, builds the Mod Loader ZIP, validates the archive, and checks that the packaged manifest matches the release tag.

## Compatibility

| Component | Declared target |
| :--- | :--- |
| Game | **Brotato 1.15.4** |
| Engine | Godot 3.x / GDScript |
| Mod Loader | **6.3.0** |
| Mod version | **1.1.0** |
| Required dependency | Yoko-NewContentLoader |
| License | MIT |

The manifest is the source of truth for compatibility and dependencies.

## Project structure

```text
Yoko-YzTato/
├── .github/workflows/release.yml
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
├── mod_main.gd
├── README.md
└── LICENSE
```

## Related projects

- [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader) — shared content registration and runtime integration.
- [Yoko-MoreStatsContainer](https://github.com/CYoJkoY/Yoko-MoreStatsContainer) — paginated Brotato stats UI.
- [Yoko-DebugMenu](https://github.com/CYoJkoY/Yoko-DebugMenu) — in-game testing and debugging tools.

## Contributing

Useful contributions include new content, concrete bug fixes, compatibility improvements, balance observations, and narrowly scoped runtime changes.

For bug reports, include the Brotato version, Mod Loader version, YzTato version, dependency versions, reproduction steps, and relevant logs or screenshots.

## Support

If YzTato improves your Brotato experience or helps with mod development, support is available through the deployed payment page:

**https://cyojkoy.github.io/Payment/**

## License

Yoko-YzTato is licensed under the [MIT License](LICENSE).

<div align="center">
  <sub>Yoko-YzTato · Brotato content expansion by Yoko</sub>
</div>
