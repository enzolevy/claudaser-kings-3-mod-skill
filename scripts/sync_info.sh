#!/usr/bin/env bash
#
# sync_info.sh — Sync CK3 reference documentation into this skill repo.
#
# Copies two things:
#   1. All .info files (Paradox's syntax documentation) from the CK3 game folder
#      into references/info/, preserving directory structure.
#   2. script_docs logs (effects.log, triggers.log, etc.) from the CK3 user
#      data folder into references/script_docs/.
#
# Usage:
#   sync_info.sh [options] [game_path]
#   sync_info.sh "/path/to/Crusader Kings III"
#   sync_info.sh --dry-run
#   CK3_GAME_PATH="..." sync_info.sh
#
# Options:
#   --dry-run       Show what would be copied without copying
#   --clean         Remove existing synced data before syncing
#   --output DIR    Override output directory for .info files
#   --help, -h      Show this help message

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Defaults ─────────────────────────────────────────────────────────────────

DRY_RUN=0
CLEAN=0
OUTPUT_DIR=""
GAME_PATH=""

# ── Usage ────────────────────────────────────────────────────────────────────

usage() {
    cat <<'USAGE'
Usage: sync_info.sh [options] [game_path]

Sync CK3 reference documentation: .info files + script_docs logs.

Arguments:
  game_path       Path to the CK3 installation directory (containing a game/ subfolder).
                  Falls back to CK3_GAME_PATH env var, then auto-detects Steam paths.

Options:
  --dry-run       Show what would be copied without actually copying
  --clean         Remove existing synced data before syncing
  --output DIR    Override the output directory for .info files (default: references/info/)
  -h, --help      Show this help message

What gets synced:
  1. .info files  → references/info/     (syntax docs from game folder, ~166 files)
  2. script_docs  → references/script_docs/  (effects, triggers, scopes, modifiers)

Auto-detected Steam paths:
  Windows:  C:\Program Files (x86)\Steam\steamapps\common\Crusader Kings III
  macOS:    ~/Library/Application Support/Steam/steamapps/common/Crusader Kings III
  Linux:    ~/.steam/steam/steamapps/common/Crusader Kings III

script_docs are auto-detected from:
  Windows:  %USERPROFILE%\Documents\Paradox Interactive\Crusader Kings III\logs\
  macOS:    ~/Documents/Paradox Interactive/Crusader Kings III/logs/
  Linux:    ~/.local/share/Paradox Interactive/Crusader Kings III/logs/

If script_docs are not found, run CK3 with -debug_mode, then type "script_docs" in console.
USAGE
}

# ── Parse arguments ──────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --clean)
            CLEAN=1
            shift
            ;;
        --output)
            if [[ $# -lt 2 ]]; then
                echo "Error: --output requires a directory argument." >&2
                exit 2
            fi
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Error: unknown option '$1'" >&2
            usage >&2
            exit 2
            ;;
        *)
            GAME_PATH="$1"
            shift
            ;;
    esac
done

# ── Resolve game path ───────────────────────────────────────────────────────

auto_detect_steam() {
    local candidates=()

    # Windows paths
    candidates+=(
        "/c/Program Files (x86)/Steam/steamapps/common/Crusader Kings III"
        "/d/SteamLibrary/steamapps/common/Crusader Kings III"
        "/e/SteamLibrary/steamapps/common/Crusader Kings III"
    )
    # Also try native Windows path style via PROGRAMFILES
    if [[ -n "${PROGRAMFILES:-}" ]]; then
        candidates+=("$(cygpath -u "${PROGRAMFILES} (x86)" 2>/dev/null || true)/Steam/steamapps/common/Crusader Kings III")
        candidates+=("$(cygpath -u "${PROGRAMFILES}" 2>/dev/null || true)/Steam/steamapps/common/Crusader Kings III")
    fi

    # macOS
    candidates+=("$HOME/Library/Application Support/Steam/steamapps/common/Crusader Kings III")

    # Linux
    candidates+=("$HOME/.steam/steam/steamapps/common/Crusader Kings III")
    candidates+=("$HOME/.local/share/Steam/steamapps/common/Crusader Kings III")

    for candidate in "${candidates[@]}"; do
        if [[ -d "$candidate" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

if [[ -z "$GAME_PATH" ]]; then
    GAME_PATH="${CK3_GAME_PATH:-}"
fi

if [[ -z "$GAME_PATH" ]]; then
    echo "No game path provided, attempting auto-detection..."
    if GAME_PATH="$(auto_detect_steam)"; then
        echo "Found CK3 at: $GAME_PATH"
    else
        echo "Error: Could not auto-detect CK3 installation." >&2
        echo "Provide the path as an argument or set CK3_GAME_PATH." >&2
        exit 1
    fi
fi

if [[ ! -d "$GAME_PATH" ]]; then
    echo "Error: game path does not exist or is not a directory: $GAME_PATH" >&2
    exit 1
fi

# ── Resolve output directory ────────────────────────────────────────────────

if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$REPO_ROOT/references/info"
fi

# ── Resolve script_docs path ────────────────────────────────────────────────

SCRIPT_DOCS_DIR="$REPO_ROOT/references/script_docs"

auto_detect_user_data() {
    local candidates=()

    # Windows
    if [[ -n "${USERPROFILE:-}" ]]; then
        candidates+=("$USERPROFILE/Documents/Paradox Interactive/Crusader Kings III/logs")
    fi
    candidates+=("$HOME/Documents/Paradox Interactive/Crusader Kings III/logs")

    # macOS
    candidates+=("$HOME/Documents/Paradox Interactive/Crusader Kings III/logs")

    # Linux
    candidates+=("$HOME/.local/share/Paradox Interactive/Crusader Kings III/logs")

    for candidate in "${candidates[@]}"; do
        if [[ -f "$candidate/effects.log" ]]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

# ── Clean if requested ──────────────────────────────────────────────────────

if [[ "$CLEAN" -eq 1 ]]; then
    if [[ -d "$OUTPUT_DIR" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "[dry-run] Would remove $OUTPUT_DIR"
        else
            echo "Cleaning $OUTPUT_DIR..."
            rm -rf "$OUTPUT_DIR"
        fi
    fi
    if [[ -d "$SCRIPT_DOCS_DIR" ]]; then
        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "[dry-run] Would remove $SCRIPT_DOCS_DIR"
        else
            echo "Cleaning $SCRIPT_DOCS_DIR..."
            rm -rf "$SCRIPT_DOCS_DIR"
        fi
    fi
fi

# ── Find and copy .info files ───────────────────────────────────────────────

ACTION="Syncing"
if [[ "$DRY_RUN" -eq 1 ]]; then
    ACTION="Dry-run"
fi

echo "$ACTION: $GAME_PATH -> $OUTPUT_DIR"
echo ""

FOUND=0
COPIED=0
ERRORS=0

while IFS= read -r src; do
    FOUND=$((FOUND + 1))

    # Get path relative to GAME_PATH
    rel="${src#"$GAME_PATH"/}"

    # Strip leading game/ prefix if present
    dest_rel="$rel"
    case "$dest_rel" in
        game/*)  dest_rel="${dest_rel#game/}" ;;
        Game/*)  dest_rel="${dest_rel#Game/}" ;;
    esac

    dest="$OUTPUT_DIR/$dest_rel"

    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "  [dry-run] $rel -> $dest_rel"
        COPIED=$((COPIED + 1))
    else
        dest_dir="$(dirname "$dest")"
        if mkdir -p "$dest_dir" && cp "$src" "$dest" 2>/dev/null; then
            echo "  $rel -> $dest_rel"
            COPIED=$((COPIED + 1))
        else
            echo "  ERROR: Failed to copy $rel" >&2
            ERRORS=$((ERRORS + 1))
        fi
    fi
done < <(find "$GAME_PATH" -type f -name "*.info" | sort)

# ── Summary ─────────────────────────────────────────────────────────────────

echo ""
if [[ "$FOUND" -eq 0 ]]; then
    echo "No .info files found in the game directory."
    exit 1
fi

LABEL="copied"
if [[ "$DRY_RUN" -eq 1 ]]; then
    LABEL="would copy"
fi

echo "Found $FOUND .info file(s), $LABEL $COPIED."

if [[ "$ERRORS" -gt 0 ]]; then
    echo "$ERRORS error(s) occurred." >&2
    exit 1
fi

# ── Sync script_docs ────────────────────────────────────────────────────────

echo ""
echo "============================================"
echo " Syncing script_docs logs"
echo "============================================"
echo ""

SCRIPT_DOCS_LOGS=("effects.log" "triggers.log" "event_targets.log" "modifiers.log" "event_scopes.log")

if LOGS_PATH="$(auto_detect_user_data)"; then
    echo "Found script_docs at: $LOGS_PATH"
    echo ""

    SD_COPIED=0
    SD_MISSING=0

    for logfile in "${SCRIPT_DOCS_LOGS[@]}"; do
        src="$LOGS_PATH/$logfile"
        dest="$SCRIPT_DOCS_DIR/$logfile"

        if [[ ! -f "$src" ]]; then
            echo "  SKIP: $logfile (not found)"
            SD_MISSING=$((SD_MISSING + 1))
            continue
        fi

        if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "  [dry-run] $logfile ($(wc -l < "$src" | tr -d ' ') lines)"
            SD_COPIED=$((SD_COPIED + 1))
        else
            mkdir -p "$SCRIPT_DOCS_DIR"
            if cp "$src" "$dest"; then
                echo "  $logfile ($(wc -l < "$dest" | tr -d ' ') lines)"
                SD_COPIED=$((SD_COPIED + 1))
            else
                echo "  ERROR: Failed to copy $logfile" >&2
            fi
        fi
    done

    echo ""
    echo "script_docs: $SD_COPIED/${#SCRIPT_DOCS_LOGS[@]} files synced."
    if [[ "$SD_MISSING" -gt 0 ]]; then
        echo "  $SD_MISSING file(s) missing. Run 'script_docs' in the CK3 console to generate them."
    fi
else
    echo "WARNING: Could not find CK3 user data / script_docs logs."
    echo "To generate them: launch CK3 with -debug_mode, then type 'script_docs' in console."
fi

echo ""
echo "============================================"
echo " Sync complete"
echo "============================================"

exit 0
