# AllegroInLean

Lean 4 FFI bindings for [Allegro 5](https://liballeg.org/), providing
type-safe, idiomatic Lean wrappers around Allegro's C API via a thin C shim
layer.

📖 **[API Documentation](https://pawelsberg.github.io/AllegroInLean/)**

**Lean modules** · **C shim files** · **demo programs** · **test suites**

## Quick start

### 1. Install Allegro 5

**Debian / Ubuntu**

```bash
sudo apt-get install liballegro5-dev liballegro-image5-dev \
  liballegro-font5-dev liballegro-ttf5-dev liballegro-primitives5-dev \
  liballegro-audio5-dev liballegro-acodec5-dev liballegro-dialog5-dev \
  liballegro-video5-dev libgtk-3-dev
```

**macOS (Homebrew)**

```bash
brew install allegro
```

**Fedora / Rocky / RHEL**

Allegro 5 packages are **not available** in the standard Fedora, Rocky Linux, or RHEL repositories. Build from source using the provided helper script:

```bash
# Install build dependencies first
sudo dnf install -y gcc gcc-c++ cmake make \
  libX11-devel libXcursor-devel libXrandr-devel libXi-devel \
  mesa-libGL-devel libpng-devel libjpeg-turbo-devel \
  freetype-devel pulseaudio-libs-devel openal-soft-devel \
  libvorbis-devel flac-devel libtheora-devel gtk3-devel

./scripts/build-allegro.sh
```

This builds Allegro 5.2.11 into `allegro-local/` which the lakefile discovers automatically.

> **Using AllegroInLean as a dependency?** You won't have `scripts/` in your
> own project yet. Run `lake update` first, then copy the script from the
> fetched package — see [Platform notes](#platform-notes) below for the
> exact commands.

**Windows (MSYS2 / MinGW-w64)**

```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-allegro mingw-w64-x86_64-pkg-config
```

> Ensure `C:\msys64\mingw64\bin` is on your `PATH`, or run `lake build`
> from the MSYS2 **MINGW64** shell.

See [docs/Build.md](docs/Build.md) for building from source via
the helper scripts, and more Windows details.

### 2. Install Lean 4

Install [elan](https://github.com/leanprover/elan) — the correct Lean
toolchain is selected automatically from `lean-toolchain`.

### 3. Build

```bash
lake build                                # library only
lake build allegroFullDemo                # a single demo
lake build -K allegroPrefix=/usr          # custom Allegro prefix
```

### 4. Run

```bash
.lake/build/bin/allegroFullDemo      # direct binary path
lake exe allegroFullDemo              # or via Lake
```

If your Allegro install is not under the default local prefix, pass a prefix
at build time or set it in a `lakefile.toml`:

```toml
[config]
allegroPrefix = "/opt/allegro"
```

## Demos

| Target | Description |
|--------|-------------|
| `allegroLoopDemo` | Minimal event loop |
| `allegroFullDemo` | Combined showcase |
| `allegroImageDemo` | Bitmap loading / drawing |
| `allegroFontDemo` | Built-in font rendering |
| `allegroTtfDemo` | TrueType font rendering |
| `allegroPrimitivesDemo` | Lines, circles, filled shapes |
| `allegroAudioDemo` | Audio playback |
| `allegroInputDemo` | Keyboard and mouse input |
| `allegroTransformDemo` | Affine transforms |
| `allegroJoystickDemo` | Joystick enumeration |
| `allegroEventDemo` | Event source & queue |
| `allegroGameLoopDemo` | Fixed-timestep game loop |
| `allegroConfigDemo` | Config file I/O |
| `allegroColorDemo` | Colour conversions |
| `allegroUstrDemo` | Unicode string functions |
| `allegroPathDemo` | Path manipulation |
| `allegroBlendingDemo` | Alpha blending modes |
| `allegroNativeDialogDemo` | Native file / message dialogs |
| `allegroVideoDemo` | Video playback |
| `allegroFileIODemo` | File I/O via `ALLEGRO_FILE` |
| `allegroShaderDemo` | GLSL / HLSL shader programs |
| `allegroHapticDemo` | Force-feedback / haptic devices |
| `allegroSystemExtrasDemo` | System extras (ID, exe name, timeout) |
| `allegroDisplayExtrasDemo` | Display extras (adapter, refresh rate, vsync) |
| `allegroBitmapExtrasDemo` | Bitmap extras (depth, samples, sub-bitmap offsets) |
| `allegroEventExtrasDemo` | Event extras (source data, source registered) |
| `allegroTransformExtrasDemo` | 3D transforms, camera, transpose |
| `allegroPathExtrasDemo` | Path manipulation extras |
| `allegroUstrExtrasDemo` | Ustr extras (ref, buffer, UTF-16) |
| `allegroColorExtrasDemo` | Colour extras (CIE XYZ/Lab/LCH, distance) |
| `allegroAudioExtrasDemo` | Audio extras (recorder, sample ID, raw streams) |
| `allegroPrimitivesExtrasDemo` | Primitives extras (vertex decl, prim draw) |
| `allegroConfigExtrasDemo` | Config extras (file F variants) |
| `allegroFontExtrasDemo` | Font extras (glyph info, multiline) |
| `allegroJoystickExtrasDemo` | Joystick extras (GUID, type, mappings) |
| `allegroMenuExtrasDemo` | Menu extras (find, toggle, build) |
| `allegroVideoFileDemo` | Video file I/O via `ALLEGRO_FILE` |

## Tests

```bash
lake build allegroSmoke allegroFuncTest allegroErrorTest && \
  .lake/build/bin/allegroSmoke && \
  .lake/build/bin/allegroFuncTest && \
  .lake/build/bin/allegroErrorTest
```

> **Windows:** Use backslashes, `.exe` suffix, and `;` instead of `&&`:
> `lake build allegroSmoke; .lake\build\bin\allegroSmoke.exe`

## Using as a dependency

To use AllegroInLean in your own Lean 4 project you need three files.

### Step 1 — `lean-toolchain`

Create a `lean-toolchain` file matching the version used by AllegroInLean
(currently `leanprover/lean4:4.27.0`):

```
leanprover/lean4:4.27.0
```

### Step 2 — `lakefile.lean`

```lean
import Lake
open Lake DSL

require AllegroInLean from git
  "https://github.com/pawelsberg/AllegroInLean" @ "main"

package my_game where
  moreLeanArgs := #["-DautoImplicit=false"]

-- Locate Allegro libraries on the current platform.
-- IMPORTANT: Only add directories where Allegro is actually installed.
-- Adding broad system paths (e.g. /usr/lib64) can shadow the Lean
-- toolchain's bundled glibc and cause link failures on glibc ≥ 2.34.
-- NOTE: If MSYS2 is installed outside C:\msys64, update the path below.
def allegroLibDirs : Array String := Id.run do
  let mut dirs : Array String := #[]
  if System.Platform.isWindows then
    dirs := dirs.push "-LC:/msys64/mingw64/lib"
  else if System.Platform.isOSX then
    dirs := dirs.push "-L/opt/homebrew/lib"
  else
    -- Linux: allegro-local/ is produced by scripts/build-allegro.sh.
    -- System-installed Allegro (e.g. /usr/lib64) is found by the
    -- default linker search path — no explicit -L needed.
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
  -- macOS bundles math in libSystem; -Wl,--allow-shlib-undefined is
  -- Linux-only (ld64 on macOS does not recognise it).
  if !System.Platform.isWindows && !System.Platform.isOSX then
    args := args.push "-lm"
    args := args.push "-Wl,--allow-shlib-undefined"
  return args

@[default_target]
lean_exe my_game where
  root := `Main
  moreLinkArgs := allegroLinkArgs
```

### Step 3 — `Main.lean` (minimal working example)

This opens a window and draws a rectangle — enough to verify that
everything is wired up correctly. `import Allegro` brings in the full
library, and `open Allegro` enables unqualified access to all API
functions **including dot-notation** on handle types (e.g.
`display.destroy`, `timer.start`) via the auto-imported `Allegro.Compat`
module.

```lean
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  -- Initialise the addons your game needs
  let _ ← Allegro.initPrimitivesAddon
  Allegro.initFontAddon
  let _ ← Allegro.installKeyboard

  let display ← Allegro.createDisplay 640 480
  if display == 0 then IO.eprintln "createDisplay failed"; return

  -- Built-in font — no external files needed for quick prototyping
  let font ← Allegro.createBuiltinFont

  let timer ← Allegro.createTimer (1.0 / 60.0)
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
```

### Step 4 — Build and run

**If Allegro is installed system-wide** (Debian/Ubuntu, macOS Homebrew):
```bash
lake update                               # fetch dependencies
lake build                                # compile
.lake/build/bin/my_game                   # run (from project root)
```

**If you built Allegro locally** into `allegro-local/` (Fedora/Rocky/RHEL):
```bash
lake update
lake build -K allegroPrefix=$PWD/allegro-local
.lake/build/bin/my_game
```

**Windows (PowerShell):**
```powershell
$env:PATH = "C:\msys64\mingw64\bin;" + $env:PATH
lake update
lake build
.lake\build\bin\my_game.exe
```

> ⚠️ **The `-K allegroPrefix=…` flag is required** when using a local Allegro
> build. It ensures the C shim is compiled against the correct headers.
> Without it, stale system headers (e.g. an older Allegro in `/usr/local/include`)
> may cause `al_init` to silently fail at runtime due to a version mismatch
> baked into the `al_init` macro.

### Step 5 — First game checklist (recommended)

When starting a real game (not just a rectangle demo), this order avoids most setup mistakes:

1. `Allegro.init`
2. Addons/subsystems you actually use (`initPrimitivesAddon`, `initFontAddon`, `installKeyboard`, `installMouse`, `installAudio`, `initAcodecAddon`, `reserveSamples`)
3. `createDisplay`, `createTimer`, `createEventQueue`, `createEvent`
4. Register event sources (display, keyboard, mouse, timer)
5. Start timer, run event loop, update on timer events, draw only when queue is empty
6. Destroy in reverse order (timer/event/queue/assets/display, then shutdown addons)

**Mouse-driven games**: Don't forget `installMouse` and `getMouseEventSource` —
without registering the mouse event source, `mouseAxes` and `mouseButtonDown`
events will never arrive:

```lean
let _ ← Allegro.installMouse
let mouseSrc ← Allegro.getMouseEventSource
queue.registerSource mouseSrc
```

**Audio**: Call `reserveSamples n` (e.g. 4–8) before loading/playing any sample.
For looping background music, use `sample.play gain pan speed Playmode.loop`.
Allegro's `Sample.play` fires-and-forgets — no stream management needed for
simple sound effects.

**Pure game state**: Keep game logic in a pure `structure GameState` updated
by pure functions. Only rendering and event dispatch should use `IO`.
See [Overview — Functional game loop pattern](docs/Overview.md#functional-game-loop-pattern)
for a full example.

This is the same lifecycle used by the demos and is suitable for side-scrollers,
arcade games, and interactive tools.

### Platform notes

**Linux — Building Allegro locally for your project:**
On Fedora, Rocky Linux, RHEL, and other distributions that do not ship Allegro 5
packages, you need to build Allegro from source. The simplest approach is to copy
the build script from the AllegroInLean dependency and run it inside your project:

```bash
# After `lake update` (which fetches the dependency):
mkdir -p scripts
cp .lake/packages/AllegroInLean/scripts/build-allegro.sh ./scripts/
./scripts/build-allegro.sh
```

This creates an `allegro-local/` directory in your project root. The template
`lakefile.lean` above already includes `-L` and `-rpath` flags for this location.

**Linux — `LD_LIBRARY_PATH`:**
If Allegro is installed in a non-standard location (e.g. `/usr/local/lib` or
`allegro-local/lib64`) and you did **not** use `-rpath` in your link flags, set
`LD_LIBRARY_PATH` before running your executable:

```bash
LD_LIBRARY_PATH=allegro-local/lib64 .lake/build/bin/my_game
```

The template above already embeds `-rpath` for the local build, so this is only
needed if you customise the link flags.

**Windows:**
Make sure the Allegro DLLs are on your `PATH` (e.g. `C:\msys64\mingw64\bin`).

### Troubleshooting

**`al_init failed` at runtime (silent, no error details):**
This almost always means the C shim was compiled against different Allegro headers
than the libraries loaded at runtime. The `al_init` macro embeds a version check.
Fix: pass the correct prefix — `lake build -K allegroPrefix=$PWD/allegro-local`.
Also check for stale Allegro headers in `/usr/local/include/allegro5/` that may
be picked up over the `allegro-local/` headers.

**Build fails with "implicit declaration of function" in C shim files:**
This indicates the Allegro version installed on your system is older than what
the bindings expect (5.2.11). Either update Allegro or build from source via
`scripts/build-allegro.sh`.

**Windows process exits with `-1073741515` (`0xC0000135`) before showing a window:**
This usually means Allegro DLLs are not on `PATH` at runtime. In PowerShell:
```powershell
$env:PATH = "C:\msys64\mingw64\bin;" + $env:PATH
.lake\build\bin\my_game.exe
```
Or run from the MSYS2 `MINGW64` shell where the path is preconfigured.

**`LD_LIBRARY_PATH` needed despite `allegro-local/` existing:**
The template `lakefile.lean` embeds `-rpath` for `allegro-local/lib64` and
`allegro-local/lib`. If you changed the link flags, you may need:
```bash
LD_LIBRARY_PATH=allegro-local/lib64 .lake/build/bin/my_game
```

### Data files (fonts, sounds, images)

AllegroInLean does **not** ship game assets for consumer projects. You must
provide your own fonts, sounds, and images. Place them in a `data/` directory
(or wherever you prefer) and load them using relative paths from your working
directory:

```lean
let font ← Allegro.loadTtfFont "data/MyFont.ttf" 24 0
let sample ← Allegro.loadSample "data/beep.wav"
```

> **Quick prototyping:** If you don't have font files yet, use
> `Allegro.createBuiltinFont` for a zero-dependency 8×8 bitmap font.
> It requires no addon initialisation beyond `Allegro.initFontAddon`.

> **Font from the dependency:** After `lake update`, a ready-to-use
> DejaVu Sans font (SIL Open Font License) is available at
> `.lake/packages/AllegroInLean/data/DejaVuSans.ttf`. Copy it into your
> project's `data/` directory:
> ```bash
> mkdir -p data
> cp .lake/packages/AllegroInLean/data/DejaVuSans.ttf data/
> cp .lake/packages/AllegroInLean/data/DejaVuSans.LICENSE data/
> ```

> **Examples:** The fetched dependency also contains 35+ demo programs
> in `.lake/packages/AllegroInLean/examples/Examples/` covering every
> addon (audio, input, primitives, fonts, etc.). They are an excellent
> reference for learning the API.

Run your executable from the project root so that relative paths resolve
correctly:

```bash
# From the project root:
.lake/build/bin/my_game
```

### `open Allegro` namespace note

When you `open Allegro`, some standard library names may be shadowed by
identically-named Allegro declarations. If you encounter unexpected
"unknown identifier" errors, either:
- Qualify the call with `_root_`: e.g. `_root_.SomeModule.someFunction`
- Use a selective open: `open Allegro in` on specific `do` blocks

> **Lean 4.27.0 API differences:**
> - `Array.mkArray` was removed from the standard library. Use
>   `(List.replicate n default).toArray` or `Array.ofFn (n := 5) (fun _ => 0)`.
> - `Array.setD` does not exist. Use `Array.set!` (panics on out-of-bounds)
>   or guard the index manually.
> - `ByteArray.mkEmpty` does not exist. Use `ByteArray.empty`.
> - `List.enum` does not exist. Use indexed `for i in List.range arr.size` loops instead.
> - To iterate over a range, use `for i in List.range n do` (the `[:n]` syntax
>   may not be available).
> - When `moreLeanArgs` includes `-DautoImplicit=false` (recommended), **all
>   type variables must be declared explicitly** with `{T : Type}` in function
>   signatures. Bare `α` in parameter types will fail.
> - Anonymous constructor syntax `⟨x, y, z⟩` can fail when the expected type
>   is ambiguous (e.g. in `if`/`else` branches). Use explicit constructors
>   like `MyStruct.mk x y z` or add a type annotation: `let v : MyStruct := ⟨…⟩`.
> - Structure update `{ expr with field := val }` can fail when `expr` is an
>   array-indexed element like `arr[i]!`. Bind the element first:
>   `let old := arr[i]!; { old with field := val }`.
> - Multi-line structure update literals (where `with` fields span multiple
>   lines) can cause parse errors. Prefer single-line `{ s with a := x, b := y }`
>   or use intermediate `let` bindings.
> - Add `deriving Inhabited` to any structure you index with `arr[i]!`.
> - Add `deriving BEq` to structures used with `Array.contains`.

## Layout

| Path | Contents |
|------|----------|
| `src/Allegro/` | Lean binding modules (Core + Addons + Compat) |
| `ffi/` | C shim wrappers (`allegro_*.c`, `allegro_ffi.h`) |
| `examples/` | Demo programs (one per addon / feature) |
| `tests/` | Smoke, functional, and error-path tests |
| `data/` | Shared assets (fonts, sample video, licenses) |
| `scripts/` | Cross-platform Allegro build helpers (`build-allegro.sh`, `build-allegro.ps1`) |
| `docs/` | [Overview](docs/Overview.md) · [Build](docs/Build.md) · [FFI](docs/FFI.md) |

## Documentation

- [docs/Overview.md](docs/Overview.md) — Architecture and module parity matrix
- [docs/Build.md](docs/Build.md) — Cross-platform build instructions
- [docs/FFI.md](docs/FFI.md) — FFI design, memory model, and conventions

## License

See [LICENSE](LICENSE) for details.
