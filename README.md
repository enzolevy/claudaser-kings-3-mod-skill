# Claudaser Kings 3 — CK3 Modding Skill for Claude Code

> A mega-skill that gives Claude Code structured documentation, actionable recipes, and anti-hallucination guardrails for Crusader Kings 3 modding.

<!-- Replace YOUR_USERNAME with your GitHub username throughout this file -->

## The Problem

Paradox Script — the proprietary DSL used by Crusader Kings 3 — is poorly documented. The official wiki is often outdated, and the real reference is buried in the game files themselves. LLMs confidently hallucinate triggers, effects, and syntax that don't exist, making AI-assisted CK3 modding frustrating and error-prone.

## The Solution

Claudaser Kings 3 is a Claude Code skill that extracts documentation directly from the game files (`.info` files + `script_docs`), wraps it with actionable recipes and utility scripts, and enforces anti-hallucination guardrails that force verification against real sources. No external wiki dependency — everything comes from the game itself.

## Features

- 📋 **.info file sync** — extract Paradox's own syntax documentation (~166 files) directly from the game
- 📖 **script_docs sync** — all effects, triggers, scopes, and modifiers from the game engine (32K+ lines)
- 🧑‍🍳 **Actionable recipes** for common modding tasks (events, decisions, traits, buildings, CBs, GUI, and more)
- 🧭 **Smart navigation index** — Claude Code knows which file to read for each task
- 🔍 **Utility scripts** for searching, indexing vanilla game files, and checking mod compatibility
- 🛡️ **Anti-hallucination guardrails** — forces verification against real sources (.info > script_docs > vanilla > patterns)
- 🔀 **Mod compatibility tools** — detect conflicts between mods before they cause issues
- 💻 **Cross-platform support** (Windows, macOS, Linux) with auto-detection of Steam paths

## Installation

### Option 1: Claude Code Plugin (recommended)

```bash
claude plugin marketplace add YOUR_USERNAME/claudaser-kings-3-mod-skill
```

### Option 2: Clone to personal skills

```bash
git clone https://github.com/YOUR_USERNAME/claudaser-kings-3-mod-skill.git \
  ~/.claude/skills/ck3-modding
```

### Option 3: Clone to project skills

```bash
git clone https://github.com/YOUR_USERNAME/claudaser-kings-3-mod-skill.git \
  .claude/skills/ck3-modding
```

## Setup

After installing, run the sync script to extract documentation from your game:

```bash
./scripts/sync_info.sh
```

This auto-detects your Steam installation and copies `.info` files + `script_docs` logs. See [references/setup.md](references/setup.md) for detailed instructions.

## How It Works

- **SKILL.md** is the entrypoint and router. It's loaded when the skill triggers and directs Claude Code to the right reference file.
- **references/info/** contains synced `.info` files — Paradox's own syntax documentation. These are the #1 source of truth for valid keys and values.
- **references/script_docs/** contains the exhaustive list of all effects, triggers, scopes, and modifiers from the game engine.
- **references/patterns/** contains actionable recipes — the skill's real value-add. Templates, variants, checklists, and pitfalls.
- **references/structure/** documents the game's file structure, load order, and common errors.
- **references/compat/** documents mod compatibility patterns and conflict resolution strategies.
- **scripts/** contains utility tools: `sync_info.sh` (sync docs from game), `check_compat.sh` (compare mods), `find_examples.sh` and `index_vanilla.sh` (search vanilla files).
- **Progressive disclosure**: Claude Code only loads what it needs for the current task, keeping context usage efficient.

## Repo Structure

```
claudaser-kings-3-mod-skill/
├── SKILL.md                              # Entrypoint: frontmatter + navigation index
├── README.md                             # This file
│
├── references/
│   ├── setup.md                          # First-time configuration guide (all 3 OS)
│   │
│   ├── info/                             # .info files synced from game (gitignored)
│   │   ├── common/                       # ~97 subdirs (.info per system)
│   │   │   ├── buildings/_buildings.info
│   │   │   ├── character_interactions/_character_interactions.info
│   │   │   ├── traits/_traits.info
│   │   │   └── ... (~97 subdirs)
│   │   ├── events/_events.info
│   │   ├── gfx/
│   │   └── gui/
│   │
│   ├── script_docs/                      # Generated from game engine (committed)
│   │   ├── effects.log                   # All effects with syntax + scopes (15K lines)
│   │   ├── triggers.log                  # All triggers with syntax + scopes (12K lines)
│   │   ├── event_targets.log             # All scope transitions (2K lines)
│   │   ├── modifiers.log                 # All valid modifiers (2K lines)
│   │   └── event_scopes.log             # All scope types (500 lines)
│   │
│   ├── patterns/                         # Practical recipes (THE VALUE-ADD)
│   │   ├── mod-setup.md                  # Create a mod from scratch
│   │   ├── events.md                     # Events, event chains, on_actions, animations
│   │   ├── decisions.md                  # Decisions, widgets, AI behavior
│   │   ├── traits.md                     # Traits, XP tracks, compatibility
│   │   ├── buildings.md                  # Buildings (regular, special, duchy, map objects)
│   │   ├── characters.md                 # Character interactions, schemes
│   │   ├── localization.md               # Localization conventions
│   │   ├── casus-belli.md                # Custom CBs, war logic
│   │   ├── culture-religion.md           # Doctrines, tenets, innovations
│   │   ├── gui.md                        # UI modding (widgets, windows)
│   │   └── gfx.md                        # Graphical assets, portraits, CoA
│   │
│   ├── structure/
│   │   ├── vanilla-tree.md               # Game folder tree + .info file locations
│   │   ├── load-order.md                 # Loading, override, replace_path
│   │   └── common-errors.md              # Common errors, debugging, BOM encoding
│   │
│   └── compat/
│       └── compatibility.md              # Mod compatibility: conflicts, detection, resolution
│
└── scripts/
    ├── sync_info.sh                      # Sync .info files + script_docs from game
    ├── check_compat.sh                   # Compare two mods for conflicts
    ├── index_vanilla.sh                  # List vanilla files by folder
    └── find_examples.sh                  # Search vanilla for examples
```

## Contributing

Contributions are welcome! You can help by:

- **Adding new patterns** — follow the format in existing `references/patterns/` files
- **Fixing errors** — if you spot incorrect syntax or outdated information
- **Improving documentation** — better examples, clearer explanations
- **Reporting issues** — open an issue if something doesn't work as expected

Pattern files should follow the established format: context → minimal template → vanilla example → variants → checklist → pitfalls.

## Future Plans

- 🐉 **AGOT sub-skill** — A Game of Thrones mod-specific conventions and systems (dragons, Valyrian steel, mega-wars, coronation, custom map, and more)
- 🔧 **Advanced Paradox Script parser** / CLI tool
- 📖 **More pattern recipes** based on community feedback

## Acknowledgments

This skill stands on the shoulders of giants:

### Sililex/ck3-claude-skill

[Sililex/ck3-claude-skill](https://github.com/Sililex/ck3-claude-skill) is a complementary CK3 modding skill for Claude that takes a different but highly effective approach: extracting the `.info` files that ship with the CK3 game — Paradox's own official syntax documentation (~166 files covering every moddable system). Studying their approach inspired our `.info` file sync infrastructure (`scripts/sync_info.sh`) and the addition of `.info` files as the top-priority source of truth in our verification hierarchy. We adapted their idea of making these files easily accessible to Claude and integrated it with our existing pattern-based architecture. Their repo demonstrated that `.info` files are the most authoritative syntax reference available, and our `sync_info.sh` script is directly inspired by their extraction approach. They also have 22 detailed topic guides that complement our more recipe-oriented patterns — worth checking out.

### jesec/ck3-modding-wiki

[jesec/ck3-modding-wiki](https://github.com/jesec/ck3-modding-wiki) maintains a daily-updated, git-versioned markdown archive of the official CK3 Paradox Wiki modding pages. In our v1, we embedded their wiki as a submodule and used it as a primary reference source. We've since moved to sourcing documentation directly from the game files (`.info` files + `script_docs`), which are more authoritative and always version-accurate. The wiki remains an excellent community resource for conceptual understanding of Paradox Script — especially their Scripting, Scopes, and Event modding pages. All wiki content is published under the [Creative Commons Attribution-Share Alike 3.0](https://creativecommons.org/licenses/by-sa/3.0/) license.

### Paradox Interactive

For creating Crusader Kings 3 and its modding framework, and for fostering a modding community that has produced incredible content. The `.info` files and `script_docs` system shipped with the game are invaluable — if underappreciated — documentation resources that make this skill possible.

### The CK3 Modding Community

For building and maintaining the wiki documentation over the years, and for the [CK3 Mod Co-op Discord](https://discord.com/servers/ck3-mod-co-op-735413460439007241) which is the go-to place for modding questions that documentation alone can't answer.

## License

All original content (SKILL.md, patterns, scripts, structure docs) is licensed under [MIT](LICENSE).
