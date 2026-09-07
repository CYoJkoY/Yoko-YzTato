<div align="center">
  <h1>Yoko-YzTato</h1>
  <p><strong>A content-first Brotato expansion built around new content and focused runtime extensions.</strong></p>
  <p>Characters · Weapons · Items · Enemies · Worlds · Systems</p>

  <p>
    <a href="https://github.com/CYoJkoY/Yoko-YzTato/releases"><img src="https://img.shields.io/github/v/release/CYoJkoY/Yoko-YzTato?display_name=tag&sort=semver&style=flat-square&label=release" alt="Latest release"></a>
    <a href="https://github.com/CYoJkoY/Yoko-YzTato/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/CYoJkoY/Yoko-YzTato/release.yml?style=flat-square&label=build" alt="Build status"></a>
    <img src="https://img.shields.io/badge/Brotato-1.15.4-478CBF?style=flat-square" alt="Brotato 1.15.4">
    <img src="https://img.shields.io/badge/Mod%20Loader-6.3.0-5965FF?style=flat-square" alt="Mod Loader 6.3.0">
    <a href="LICENSE"><img src="https://img.shields.io/github/license/CYoJkoY/Yoko-YzTato?style=flat-square" alt="MIT License"></a>
  </p>

  <p><a href="#content-map">Content</a> · <a href="#runtime-model">Runtime</a> · <a href="#installation">Install</a> · <a href="#development">Develop</a></p>
</div>

> **Core boundary:** structured Godot resources describe content; `Yoko-NewContentLoader` handles shared registration; `extensions/` contains only behavior that needs deeper Brotato integration.

## What it is

Yoko-YzTato is a large Brotato content expansion for the Yoko mod stack. It combines resource-driven content with focused runtime extensions instead of turning every new mechanic into custom registration code.

```text
content data
    │
    ▼
NewContentDataDLC1.tres
    │
    ▼
Yoko-NewContentLoader
    │
    ▼
Brotato services ← targeted extensions
```

This separation keeps content inspectable in Godot while allowing complex mechanics to hook into the subsystem that owns them.

## Content map

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
| Sets | `content/sets/` |
| Structures | `content/structures/` |
| Zones | `content/zones/` |
| Scenes | `content/scenes/` |
| Localization | `translations/` |

`NewContentDataDLC1.tres` is the aggregate content resource consumed by the loader.

## Runtime model

Resource data handles most content. Runtime extensions are reserved for behavior that needs access to Brotato services.

| Area | Examples |
| :--- | :--- |
| Combat | Weapon behavior, projectiles, hit effects, custom effects |
| Entities | Enemy behavior, targeting, spawning, special entities |
| Run / player | Player data and run-state integration |
| Waves | Wave logic and entity spawning |
| Shop / upgrades | Shop and upgrade hooks, item and weapon services |
| Content services | Lookups and shared item, weapon, and effect support |

The architectural rule is simple: extend the owner of the behavior instead of creating a parallel gameplay system.

## Installation

### Requirements

- Brotato **1.15.4**
- **Brotato Mod Loader 6.3.0**
- [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader)

The dependency is declared in `manifest.json`.

### Release installation

1. Install Brotato 1.15.4 and Mod Loader 6.3.0.
2. Install the matching Yoko-NewContentLoader release.
3. Download the latest `YzTato-*.zip` from [Releases](https://github.com/CYoJkoY/Yoko-YzTato/releases).
4. Place the ZIP in the Mod Loader `mods` directory.
5. Launch Brotato and confirm both the dependency and YzTato load successfully.

Keep the release ZIP compressed for normal installation.

### Development layout

```text
mods-unpacked/
├── Yoko-NewContentLoader/
└── Yoko-YzTato/
```

See the [Godot Mod Loader documentation](https://wiki.godotmodding.com/) for current conventions.

## Content flow

```text
content/*
   │
   ▼
NewContentDataDLC1.tres
   │
   ▼
Yoko-NewContentLoader
   │
   ├── items / weapons
   ├── entities / effects
   ├── challenges / zones
   └── translations
           │
           ▼
     Brotato runtime
```

When a mechanic cannot be expressed through resources alone, its narrow implementation belongs in `extensions/`.

## Development

`mod_main.gd` is the runtime entry point and `NewContentDataDLC1.tres` is the central DLC content registration resource.

For a new feature, keep responsibilities explicit:

```text
New feature
   ├── Resource data   → content/
   ├── Runtime hook    → extensions/
   ├── Registration    → NewContentDataDLC1.tres
   └── Localization    → translations/
```

Changes to shared runtime behavior should be tested with Yoko-NewContentLoader and the complete mod stack.

## Release model

`manifest.json` is authoritative. Release tags must match the declared version exactly.

```text
manifest.json: 1.1.0
        │
        ├── v1.1.0     → build allowed
        └── v1.2.0     → build rejected
```

The workflow imports Godot resources, preserves generated `.import` data, packages the Mod Loader ZIP, validates its contents, and verifies the packaged manifest.

## Compatibility

| Component | Version |
| :--- | :--- |
| Brotato | **1.15.4** |
| Godot | 3.x / GDScript |
| Mod Loader | **6.3.0** |
| YzTato | **1.1.0** |
| Required dependency | Yoko-NewContentLoader |
| License | MIT |

Compatibility and dependency declarations live in `manifest.json`.

## Project structure

```text
Yoko-YzTato/
├── .github/workflows/release.yml
├── content/
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
- [Yoko-MoreStatsContainer](https://github.com/CYoJkoY/Yoko-MoreStatsContainer) — paginated Brotato statistics UI.
- [Yoko-DebugMenu](https://github.com/CYoJkoY/Yoko-DebugMenu) — in-game testing and debugging tools.

## Contributing

Contributions are most useful when they add coherent content, fix a concrete defect, improve compatibility, or make a runtime extension narrower and easier to audit.

For bug reports, include Brotato, Mod Loader, YzTato, and dependency versions together with reproduction steps and relevant logs.

## Support

Development support is available through the deployed payment page:

**https://cyojkoy.github.io/Payment/**

## License

Yoko-YzTato is licensed under the [MIT License](LICENSE).

<div align="center">
  <sub>Yoko-YzTato · Brotato content expansion by Yoko</sub>
</div>
