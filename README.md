<div align="center">
  <h1>Yoko-YzTato</h1>
  <p><strong>A content-heavy Brotato expansion built from structured resources and focused runtime systems.</strong></p>
  <p>Characters · Weapons · Items · Enemies · Worlds · Gameplay systems</p>
  <p>
    <a href="https://github.com/CYoJkoY/Yoko-YzTato/releases"><img src="https://img.shields.io/github/v/release/CYoJkoY/Yoko-YzTato?display_name=tag&sort=semver&style=flat-square&label=release" alt="Latest release"></a>
    <a href="https://github.com/CYoJkoY/Yoko-YzTato/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/CYoJkoY/Yoko-YzTato/release.yml?style=flat-square&label=build" alt="Build status"></a>
    <img src="https://img.shields.io/badge/Brotato-1.1.15.4-478CBF?style=flat-square" alt="Brotato 1.1.15.4">
    <img src="https://img.shields.io/badge/Mod%20Loader-6.3.0-5965FF?style=flat-square" alt="Mod Loader 6.3.0">
    <a href="LICENSE"><img src="https://img.shields.io/github/license/CYoJkoY/Yoko-YzTato?style=flat-square" alt="MIT License"></a>
  </p>
  <p><a href="#what-it-is">Overview</a> · <a href="#content">Content</a> · <a href="#runtime-model">Runtime</a> · <a href="#installation">Install</a> · <a href="#development--support">Development</a></p>
</div>

> **Core boundary:** resources describe content, `Yoko-NewContentLoader` owns shared registration, and `extensions/` handles behavior that requires deeper Brotato integration.

## <img src="assets/readme/icons/overview.svg" width="20" height="20" alt=""> What it is

Yoko-YzTato is the content-heavy expansion layer of the Yoko Brotato mod stack. It combines a large resource catalog with narrow runtime extensions rather than turning every new mechanic into bespoke registration code.

```text
content data → NewContentDataDLC1.tres → Yoko-NewContentLoader → Brotato services
                                      ↘ extensions/ ↗
```

## <img src="assets/readme/icons/features.svg" width="20" height="20" alt=""> Content

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
| Localization | `translations/` |

`NewContentDataDLC1.tres` is the aggregate DLC resource consumed by the loader.

## <img src="assets/readme/icons/architecture.svg" width="20" height="20" alt=""> Runtime model

Runtime extensions remain organized around the system that owns the behavior.

| Area | Examples |
| :--- | :--- |
| Combat | Weapon behavior, projectiles, hit effects, custom effects |
| Entities | Enemy behavior, targeting, spawning, special entities |
| Run / player | Player and run-state integration |
| Waves | Wave logic and spawning |
| Shop / upgrades | Shop hooks and item/weapon services |
| Content services | Lookups and shared support |

`mod_main.gd` is the runtime entry point.

## <img src="assets/readme/icons/installation.svg" width="20" height="20" alt=""> Installation

Requirements: **Brotato 1.1.15.4**, **Brotato Mod Loader 6.3.0**, and [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader).

1. Install the required game and loader versions.
2. Install the matching NewContentLoader release.
3. Download the latest `YzTato-*.zip` from [Releases](https://github.com/CYoJkoY/Yoko-YzTato/releases).
4. Place the ZIP in the Mod Loader `mods` directory.
5. Launch Brotato and verify the dependency chain loads.

For development, the intended unpacked layout is:

```text
mods-unpacked/
├── Yoko-NewContentLoader/
└── Yoko-YzTato/
```

## <img src="assets/readme/icons/development.svg" width="20" height="20" alt=""> Development & support

For new content, separate resource data, runtime hooks, registration, and localization. Changes to shared runtime behavior should be tested with the complete dependency stack.

`manifest.json` is authoritative for version `1.1.0`, dependencies, and the declared Brotato / Mod Loader compatibility.

<a href="https://cyojkoy.github.io/Payment/"><img src="assets/readme/support-cta.svg" alt="Support Yoko-YzTato" width="900" style="max-width:100%;height:auto;"></a>

Development support: **https://cyojkoy.github.io/Payment/**

## License

Yoko-YzTato is licensed under the [MIT License](LICENSE).

<div align="center"><sub>Yoko-YzTato · Brotato content expansion by Yoko.</sub></div>
