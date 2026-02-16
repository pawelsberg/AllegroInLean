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
write_if_missing "lakefile.lean" <<'LAKEFILE'
import Lake
open Lake DSL

require AllegroInLean from git
  "https://github.com/pawelsberg/AllegroInLean" @ "main"

package my_game where
  moreLeanArgs := #["-DautoImplicit=false"]

-- Locate Allegro libraries on the current platform.
def allegroLibDirs : Array String := Id.run do
  let mut dirs : Array String := #[]
  if System.Platform.isWindows then
    dirs := dirs.push "-LC:/msys64/mingw64/lib"
  else if System.Platform.isOSX then
    dirs := dirs.push "-L/opt/homebrew/lib"
  else
    let candidates := #[
      ("allegro-local/lib64", true),
      ("allegro-local/lib", true)
    ]
    for (dir, needsRpath) in candidates do
      dirs := dirs.push s!"-L{dir}"
      if needsRpath then
        dirs := dirs.push s!"-Wl,-rpath,{dir}"
  return dirs

def allegroLinkArgs : Array String := Id.run do
  let mut args := allegroLibDirs
  args := args ++ #["-lallegro", "-lallegro_image", "-lallegro_font",
    "-lallegro_ttf", "-lallegro_primitives", "-lallegro_audio", "-lallegro_acodec",
    "-lallegro_color", "-lallegro_dialog", "-lallegro_video",
    "-lallegro_memfile"]
  if !System.Platform.isWindows && !System.Platform.isOSX then
    args := args.push "-lm"
    args := args.push "-Wl,--allow-shlib-undefined"
  return args

@[default_target]
lean_exe my_game where
  root := `Main
  moreLinkArgs := allegroLinkArgs
LAKEFILE

# ── 3. Main.lean ───────────────────────────────────────────────────
write_if_missing "Main.lean" <<'MAIN'
import Allegro

open Allegro

def main : IO Unit := do
  Allegro.initOrFail

  let _ ← Allegro.initPrimitivesAddon
  Allegro.initFontAddon
  let _ ← Allegro.installKeyboard

  let some display ← Allegro.createDisplay? 640 480
    | do IO.eprintln "createDisplay failed"; return

  let font ← Allegro.createBuiltinFont

  let some timer ← Allegro.createTimer? (1.0 / 60.0)
    | do IO.eprintln "createTimer failed"; return
  let queue ← Allegro.createEventQueue
  let evt   ← Allegro.createEvent

  queue.registerSource (← display.eventSource)
  queue.registerSource (← Allegro.getKeyboardEventSource)
  queue.registerSource (← timer.eventSource)
  timer.start

  let mut running := true
  while running do
    queue.waitFor evt
    let eType ← evt.type
    if eType == EventType.displayClose then
      running := false
    else if eType == EventType.keyDown then
      if (← evt.keyboardKeycode) == KeyCode.escape then running := false
    else if eType == EventType.timer then
      Allegro.clearToColorRgb 10 10 40
      Allegro.drawFilledRectangleRgb 200 150 440 330 60 180 255
      Allegro.drawTextRgb font 255 255 255 320 340 TextAlign.centre "Hello from AllegroInLean!"
      Allegro.flipDisplay

  timer.stop; timer.destroy
  evt.destroy; queue.destroy
  font.destroy; display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownFontAddon
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
