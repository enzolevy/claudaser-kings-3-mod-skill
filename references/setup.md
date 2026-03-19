# First-Time Setup

This guide covers configuring your environment for CK3 modding with Claude Code.

## Step 1: Locate Your Game Files

### Game Installation Path (CK3_GAME_PATH)

This is the `game/` folder inside your CK3 installation.

| Platform | Default Path |
|---|---|
| **Windows (Steam)** | `C:\Program Files (x86)\Steam\steamapps\common\Crusader Kings III\game` |
| **macOS (Steam)** | `~/Library/Application Support/Steam/steamapps/common/Crusader Kings III/game` |
| **Linux (Steam)** | `~/.steam/steam/steamapps/common/Crusader Kings III/game` |
| **Windows (Xbox Game Pass)** | Varies — typically under `C:\XboxGames\` or the WindowsApps folder. Game Pass installations use a locked folder structure that is harder to access directly. |

**Verify**: the path should contain folders like `common/`, `events/`, `gfx/`, `gui/`, and `localization/`.

### User Data Path (CK3_USER_PATH)

This is where your mods, saves, and logs live.

| Platform | Default Path |
|---|---|
| **Windows** | `%USERPROFILE%\Documents\Paradox Interactive\Crusader Kings III\` |
| **macOS** | `~/Documents/Paradox Interactive/Crusader Kings III/` |
| **Linux** | `~/.local/share/Paradox Interactive/Crusader Kings III/` |

**Verify**: the path should contain folders like `mod/`, `save games/`, and `logs/`.

## Step 2: Generate script_docs

The game can generate exhaustive documentation of all triggers, effects, event targets, and modifiers. This is one of the most valuable references available.

1. Launch CK3 with the `-debug_mode` launch option
   - **Steam**: right-click CK3 in your library → Properties → Launch Options → add `-debug_mode`
   - **Shortcut**: add `-debug_mode` to the end of your shortcut target
2. Start or load any game
3. Open the console with the `` ` `` key (grave accent, top-left of keyboard)
4. Type `script_docs` and press Enter
5. The files are generated in your logs folder (`CK3_USER_PATH/logs/`)

### Key script_docs Files

| File | Contents | Lines |
|---|---|---|
| `effects.log` | All effects with usage syntax, supported scopes, and arguments | ~15K |
| `triggers.log` | All triggers with usage syntax and supported scopes | ~12K |
| `event_targets.log` | All event targets (scope transitions) with input/output scope types | ~2K |
| `modifiers.log` | All modifiers that can be used in scripted modifiers | ~2K |
| `event_scopes.log` | All valid scope types | ~500 |

These logs are the definitive reference for what triggers, effects, and scopes actually exist in your version of the game.

## Step 3: Sync Documentation

Run the sync script to copy `.info` files and `script_docs` into the skill:

```bash
./scripts/sync_info.sh
```

The script will:
1. **Auto-detect** your Steam installation (or use `CK3_GAME_PATH` if set)
2. **Copy ~166 .info files** from the game into `references/info/`
3. **Copy script_docs logs** from your user data into `references/script_docs/`

**Manual path override** (if auto-detection fails):
```bash
./scripts/sync_info.sh "/path/to/Crusader Kings III"
```

**Preview mode** (see what would be copied without copying):
```bash
./scripts/sync_info.sh --dry-run
```

**Re-sync after game update**:
```bash
./scripts/sync_info.sh --clean
```

The `.info` files are gitignored (user-specific). The `script_docs` are committed to the repo so other users don't have to generate them — but you should re-sync after game updates.

## Step 4: Create a Mod Skeleton

The easiest way to set up a new mod is through the CK3 launcher:

1. Open the CK3 launcher
2. Go to **All Installed Mods** on the left
3. Click **Upload Mod** in the top right
4. Click **Create a Mod**
5. Enter a name, version, directory, and at least one tag
6. Click **Create**

This generates:
- A mod folder with the name you chose
- A `descriptor.mod` file inside the mod folder
- A `.mod` file alongside the mod folder

For more details, see references/patterns/mod-setup.md.

## Step 5: Tell Claude Code Your Paths

When working on a CK3 mod, provide your paths so the skill can reference vanilla files:

```
CK3_GAME_PATH=/path/to/Crusader Kings III/game
CK3_USER_PATH=/path/to/Paradox Interactive/Crusader Kings III
CK3_MOD_PATH=/path/to/your/mod
```

You can set these as environment variables or simply tell Claude Code the paths at the start of your session.
