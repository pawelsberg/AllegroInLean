#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# init-project.sh — Bootstrap a new AllegroInLean game project
#
# Copies essential scaffolding files into the current directory so you
# can `lake build && .lake/build/bin/my_game` with minimal setup.
#
# Intended to be run from an EMPTY project directory after you have
# already created it:
#
#   mkdir my_game && cd my_game
#   /path/to/AllegroInLean/scripts/init-project.sh
#   lake update && lake build
#
# If AllegroInLean is already a Lake dependency (fetched via `lake
# update`), you can also invoke it from the cached package:
#
#   .lake/packages/AllegroInLean/scripts/init-project.sh
#
# What it creates:
#   lean-toolchain        — matching Lean version
#   lakefile.lean         — build config with Allegro link flags
#   Main.lean             — minimal working example (window + rectangle)
#   scripts/build-allegro.sh — local Allegro build helper (copied)
#   data/DejaVuSans.ttf   — default font (copied if available)
#   data/DejaVuSans.LICENSE
#
# Existing files are NEVER overwritten.
# ──────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Resolve script location & library root ──────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Colour helpers (disabled when stdout is not a terminal) ─────────
if [[ -t 1 ]]; then
  GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RESET=$'\033[0m'
else
  GREEN=''; YELLOW=''; RESET=''
fi

info()  { printf '%s[init]%s %s\n' "$GREEN"  "$RESET" "$1"; }
warn()  { printf '%s[skip]%s %s\n' "$YELLOW" "$RESET" "$1"; }

# ── Helper: write a file only if it doesn't exist ──────────────────
write_if_missing() {
  local dest="$1"
  if [[ -e "$dest" ]]; then
    warn "$dest already exists"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  # content comes from stdin
  cat > "$dest"
  info "created $dest"
}

copy_if_missing() {
  local src="$1" dest="$2"
  if [[ -e "$dest" ]]; then
    warn "$dest already exists"
    return
  fi
  if [[ ! -f "$src" ]]; then
    warn "source not found: $src"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  info "copied  $dest"
}

# ── Detect Lean toolchain version from library ─────────────────────
LEAN_VERSION="leanprover/lean4:4.27.0"
if [[ -f "$LIB_ROOT/lean-toolchain" ]]; then
  LEAN_VERSION="$(cat "$LIB_ROOT/lean-toolchain" | tr -d '[:space:]')"
fi

# ── 1. lean-toolchain ──────────────────────────────────────────────
write_if_missing "lean-toolchain" <<< "$LEAN_VERSION"

# ── 2. lakefile.lean ───────────────────────────────────────────────
# The library's lakefile exports `allegroLinkArgs` (with pkg-config
# detection, rpath, platform flags).  Consumers just reference it.
write_if_missing "lakefile.lean" <<'LAKEFILE'
import Lake
open Lake DSL

require AllegroInLean from git
  "https://github.com/pawelsberg/AllegroInLean" @ "main"

package my_game where
  moreLeanArgs := #["-DautoImplicit=false"]

@[default_target]
lean_exe my_game where
  root := `Main
  moreLinkArgs := allegroLinkArgs
LAKEFILE

# ── 3. Main.lean ───────────────────────────────────────────────────
# Uses `runGameLoop` to handle init, display, timer, event queue,
# addon setup, and cleanup automatically.
write_if_missing "Main.lean" <<'MAIN'
import Allegro

open Allegro

def main : IO Unit :=
  Allegro.runGameLoop
    { initAddons := [.primitives, .font, .keyboard] }
    (fun _display => do
      pure (← Allegro.createBuiltinFont))
    (fun font event => do
      match event with
      | .keyDown key =>
        if key == KeyCode.escape then return none else return some font
      | .quit => return none
      | _ => return some font)
    (fun font _display => do
      Allegro.clearToColorRgb 10 10 40
      Allegro.drawFilledRectangleRgb 200 150 440 330 60 180 255
      Allegro.drawTextRgb font 255 255 255 320 340 TextAlign.centre
        "Hello from AllegroInLean!"
      Allegro.flipDisplay)
MAIN

# ── 4. Copy build-allegro.sh ──────────────────────────────────────
copy_if_missing "$LIB_ROOT/scripts/build-allegro.sh" "scripts/build-allegro.sh"
chmod +x "scripts/build-allegro.sh" 2>/dev/null || true

# ── 5. Copy font + license ────────────────────────────────────────
copy_if_missing "$LIB_ROOT/data/DejaVuSans.ttf"     "data/DejaVuSans.ttf"
copy_if_missing "$LIB_ROOT/data/DejaVuSans.LICENSE"  "data/DejaVuSans.LICENSE"

# ── Done ───────────────────────────────────────────────────────────
echo ""
info "Project scaffolding complete!"
echo ""
echo "Next steps:"
echo "  1. (Linux without system Allegro) ./scripts/build-allegro.sh"
echo "  2. lake update"
echo "  3. lake build              # or: lake build -K allegroPrefix=\$PWD/allegro-local"
echo "  4. .lake/build/bin/my_game"
echo ""
