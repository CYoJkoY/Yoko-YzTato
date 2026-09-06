<div align="center">

# Yoko-YzTato

**A content-heavy Brotato expansion built around custom gameplay systems.**

Characters, weapons, items, enemies, challenges, maps, projectiles, particles, sets, structures, zones, effects, and runtime extensions — all registered through the Yoko mod stack.

[![Latest Release](https://img.shields.io/github/v/release/CYoJkoY/Yoko-YzTato?display_name=tag&sort=semver&style=flat-square)](https://github.com/CYoJkoY/Yoko-YzTato/releases)
[![Build](https://img.shields.io/github/actions/workflow/status/CYoJkoY/Yoko-YzTato/release.yml?style=flat-square&label=build)](https://github.com/CYoJkoY/Yoko-YzTato/actions/workflows/release.yml)
[![Mod Loader](https://img.shields.io/badge/Mod%20Loader-6.3.0-5965FF?style=flat-square)](#compatibility)
[![Godot](https://img.shields.io/badge/Godot-3.x-478CBF?style=flat-square&logo=godot-engine&logoColor=white)](https://godotengine.org/)
[![License](https://img.shields.io/github/license/CYoJkoY/Yoko-YzTato?style=flat-square)](LICENSE)

[Overview](#overview) · [Content](#content) · [Runtime systems](#runtime-systems) · [Installation](#installation) · [Development](#development)

</div>

---

## Overview

Yoko-YzTato is the gameplay and content layer of the Yoko Brotato mod stack. It uses [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader) for structured resource registration and targeted script extensions for mechanics that need deeper integration with Brotato.

The project separates data from runtime behavior:

```text
Yoko-YzTato
   │
   ├── Content resources
   │      ├── Characters / Weapons / Items
   │      ├── Enemies / Entities
   │      ├── Maps / Zones / Challenges
   │      └── Projectiles / Particles / Sets / Structures
   │
   ├── NewContentDataDLC1.tres
   │
   └── Script extensions
          │
          ▼
   Yoko-NewContentLoader
          │
          ▼
     Brotato services
```

## Content

The repository currently organizes content into dedicated categories:

| Category | Path |
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

`NewContentDataDLC1.tres` aggregates the content resources used by the loader, while translations are kept separately under `translations/`.

## Runtime systems

YzTato extends core Brotato scripts where content data alone is not sufficient. The current extension layer covers areas including:

- Enemy behavior and targeting.
- Player and player-run data.
- Melee and ranged weapon behavior.
- Weapon container behavior.
- Projectile behavior.
- Entity spawning.
- Wave management.
- Shop and upgrade UI behavior.
- Item and weapon services.
- Custom effect implementations and lookup support.

This lets a content resource remain declarative while deeper gameplay mechanics are attached to the existing system that owns them.

## Installation

### Requirements

- Brotato
- **Brotato Mod Loader 6.3.0**
- [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader)

Yoko-NewContentLoader is the required dependency declared by `manifest.json`.

### Release installation

1. Install Brotato with Mod Loader 6.3.0.
2. Install the matching Yoko-NewContentLoader release.
3. Download the latest `YzTato-*.zip` from [Releases](https://github.com/CYoJkoY/Yoko-YzTato/releases).
4. Place the ZIP in the Mod Loader `mods` directory.
5. Start Brotato and verify that both the dependency and YzTato load correctly.

Keep release files as ZIPs for normal installation.

For development:

```text
mods-unpacked/
├── Yoko-NewContentLoader/
└── Yoko-YzTato/
```

See the [Godot Mod Loader documentation](https://wiki.godotmodding.com/) for current installation conventions.

## Development

New content should generally live under `content/` as Godot resources. Behavior that changes an existing Brotato system belongs under `extensions/` and should be kept narrowly scoped.

The main runtime entry point is `mod_main.gd`, while `NewContentDataDLC1.tres` is the primary aggregated content resource.

When adding a feature, a useful separation is:

```text
New feature
   │
   ├── Resource data  → content/
   ├── Runtime hook   → extensions/
   ├── Registration   → NewContentDataDLC1.tres
   └── Localization   → translations/
```

## Release pipeline

Releases are created from semantic version tags. The workflow now requires the repository manifest and the release tag to match exactly:

```text
manifest.json: 1.1.0
        │
        ├── tag v1.1.0  → build allowed
        └── tag v1.2.0  → build rejected
```

The pipeline also imports Godot resources, preserves generated `.import` data, builds the Mod Loader ZIP, verifies the archive contents, and checks the packaged manifest before publishing.

## Compatibility

| Component | Declared target |
| :--- | :--- |
| Engine | Godot 3.x / GDScript |
| Mod Loader | **6.3.0** |
| Mod version | **1.1.0** |
| Dependency | Yoko-NewContentLoader |
| Brotato game version | Not specified |
| License | MIT |

Because YzTato depends on NewContentLoader, compatibility should be considered at the full stack level rather than from one manifest entry alone.

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

- [Yoko-NewContentLoader](https://github.com/CYoJkoY/Yoko-NewContentLoader) — shared content registration and service-extension infrastructure.
- [Yoko-MoreStatsContainer](https://github.com/CYoJkoY/Yoko-MoreStatsContainer) — paginated stat display enhancement.
- [Yoko-DebugMenu](https://github.com/CYoJkoY/Yoko-DebugMenu) — runtime debugging and testing tools.

## License

This project is licensed under the [MIT License](LICENSE).

## Support the Author

If this expansion improves your Brotato experience or helps with mod development, consider supporting its continued development.

<div align="center">
  <a href="https://cyojkoy.github.io/Payment/">
    <img src="https://img.shields.io/badge/Support_the_Author-9E8F7E?style=for-the-badge&logo=buy-me-a-coffee&logoColor=BEB8AE" alt="Support the Author">
  </a>
</div>

---

<div align="center">
  <sub>Yoko-YzTato · Brotato content expansion by CYoJkoY</sub>
</div>
