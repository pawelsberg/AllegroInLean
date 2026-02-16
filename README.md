# AllegroInLean

Lean 4 FFI bindings for [Allegro 5](https://liballeg.org/), providing
type-safe, idiomatic Lean wrappers around Allegro's C API via a thin C shim
layer.

📖 **[API Documentation](https://pawelsberg.github.io/AllegroInLean/)**

**Lean modules** · **C shim files** · **demo programs** · **test suites**

## Quick start

### 1. Install Allegro 5

**Debian / Ubuntu**

> ⚠️ **Version requirement:** AllegroInLean requires Allegro **5.2.11**.
> Ubuntu 24.04 and Debian 12 ship **5.2.9** — the system packages will install
> but the C shim will fail to compile with errors like
> `implicit declaration of function 'al_get_joystick_guid'`.
> If your distro ships an older version, **build from source** using
> `scripts/build-allegro.sh` — see [Platform notes](#platform-notes) below.

```bash
sudo apt-get install liballegro5-dev liballegro-image5-dev \
  liballegro-ttf5-dev \
  liballegro-audio5-dev liballegro-acodec5-dev liballegro-dialog5-dev \
  liballegro-video5-dev libgtk-3-dev
```

> **Note:** `liballegro5-dev` already includes the font, primitives, color,
> and memfile headers on Debian/Ubuntu. Per-addon `-dev` packages only exist
> for image, ttf, audio, acodec, dialog, and video.

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

## Idiomatic Lean: `Option`-returning API

Every function that creates or loads a resource has a `?`-suffixed variant
that returns `Option` instead of a raw handle (where `0` means failure).
Prefer these in your own code — they compose naturally with `do`-notation
and eliminate the C-style `if handle == 0` checks:

```lean
-- ✅ Preferred — uses pattern matching, clear control flow
let some display ← Allegro.createDisplay? 640 480
  | do IO.eprintln "createDisplay failed"; return
let some font ← Allegro.loadTtfFont? "data/font.ttf" 24 0
  | do IO.eprintln "loadTtfFont failed"; return
let some sample ← Allegro.loadSample? "data/beep.wav"
  | do IO.eprintln "loadSample failed"; return

-- ❌ Avoid — C-style null checks
let display ← Allegro.createDisplay 640 480
if display == 0 then IO.eprintln "createDisplay failed"; return
```

Available `?` variants include:
`createDisplay?`, `createBitmap?`, `cloneBitmap?`, `createTimer?`,
`loadBitmap?`, `loadSample?`, `loadBitmapFont?`, `loadConfigFile?`,
`createShader?`, `getDefaultMixer?`, `getDefaultVoice?`, `fopen?`,
`getJoystick?`, `createFsEntry?`, and more.

All `?` variants are built on `Allegro.liftOption`, which you can use to
wrap any handle-returning call:

```lean
-- Wrap your own handle-returning calls
let some myHandle ← Allegro.liftOption (someCustomCall args)
  | do IO.eprintln "someCustomCall failed"; return
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

### Quick scaffold (recommended)

```bash
mkdir my_game && cd my_game
/path/to/AllegroInLean/scripts/init-project.sh   # generates all files below
```

If Allegro is not installed system-wide, build it locally first:

```bash
./scripts/build-allegro.sh
```

Then build and run:

```bash
lake update && lake build && .lake/build/bin/my_game
```

After `lake update` you can also run the script from the cached package:
`.lake/packages/AllegroInLean/scripts/init-project.sh`

### Manual setup — 3 files

Create these three files in an empty directory:

**`lean-toolchain`**

```
leanprover/lean4:4.27.0
```

**`lakefile.lean`**

```lean
import Lake
open Lake DSL

require AllegroInLean from git
  "https://github.com/pawelsberg/AllegroInLean" @ "main"

-- ── Allegro link-flag helper ──
-- Lake does not propagate link args from dependency libraries,
-- so the consumer must supply them.  The block below auto-detects
-- allegro-local/ (built by scripts/build-allegro.sh) and falls
-- back to the default system library paths.

private unsafe def fileExistsImpl (p : System.FilePath) : Bool :=
  let action : IO Bool := p.pathExists
  match unsafeBaseIO action.toBaseIO with
  | Except.ok b => b | Except.error _ => false

@[implemented_by fileExistsImpl]
private opaque fileExists (p : System.FilePath) : Bool

package my_game where
  moreLeanArgs := #["-DautoImplicit=false"]
  moreLinkArgs := Id.run do
    let mut args := #[]
    -- Auto-detect allegro-local/ produced by scripts/build-allegro.sh
    let pfx := __dir__ / "allegro-local"
    if fileExists (pfx / "include" / "allegro5" / "allegro.h") then
      for sub in #["lib64", "lib"] do
        args := args.push s!"-L{(pfx / sub)}"
        if !System.Platform.isWindows then
          args := args.push s!"-Wl,-rpath,{(pfx / sub)}"
    args := args ++ #[
      "-lallegro", "-lallegro_image", "-lallegro_font",
      "-lallegro_ttf", "-lallegro_primitives",
      "-lallegro_audio", "-lallegro_acodec", "-lallegro_color",
      "-lallegro_dialog", "-lallegro_video", "-lallegro_memfile"]
    if !System.Platform.isWindows && !System.Platform.isOSX then
      args := args.push "-lm"
      args := args.push "-Wl,--allow-shlib-undefined"
    return args

@[default_target]
lean_exe my_game where
  root := `Main
```

**`Main.lean`**

```lean
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
```

**Build and run:**

Allegro 5 must be installed on your system before `lake build` — the C shim
compiles against Allegro headers. See [Install Allegro 5](#1-install-allegro-5)
above. On Fedora / Rocky / RHEL (no system packages), build locally after
`lake update`:

```bash
lake update
mkdir -p scripts
cp .lake/packages/AllegroInLean/scripts/build-allegro.sh scripts/
./scripts/build-allegro.sh
lake build
.lake/build/bin/my_game
```

On systems with Allegro system packages (Debian/Ubuntu ≥ 5.2.11, macOS,
MSYS2):

```bash
lake update && lake build && .lake/build/bin/my_game
```

> The lakefile auto-detects `allegro-local/` if present — no extra flags
> needed.

### Platform notes

**Windows:** Ensure `C:\msys64\mingw64\bin` is on `PATH`, or run from the
MSYS2 MINGW64 shell.

### Troubleshooting

**`al_init failed` at runtime:** The C shim was compiled against different
headers than the runtime libraries. Ensure `allegro-local/` (if used) was
built with the correct Allegro version. Try a clean rebuild:
`lake clean && lake build`.

**"implicit declaration of function" build error:** Allegro version is
too old (< 5.2.11). Build from source via `scripts/build-allegro.sh`.

**Windows exits with `-1073741515`:** Allegro DLLs not on `PATH`. Add
`C:\msys64\mingw64\bin` to `PATH` or run from MSYS2.

### Data files

Use `Allegro.createBuiltinFont` for zero-dependency prototyping. For custom
fonts, copy from the dependency after `lake update`:

```bash
mkdir -p data
cp .lake/packages/AllegroInLean/data/DejaVuSans.ttf data/
```

35+ demo programs are available in
`.lake/packages/AllegroInLean/examples/Examples/`.

### Advanced: manual event loop

For full control over init, event dispatch, and cleanup (bypassing
`runGameLoop`), see the manual loop pattern in
[docs/Overview.md](docs/Overview.md) and examples like `FullDemo.lean`.

### `open Allegro` namespace note

When you `open Allegro`, some standard library names may be shadowed by
identically-named Allegro declarations. If you encounter unexpected
"unknown identifier" errors, either:
- Qualify the call with `_root_`: e.g. `_root_.SomeModule.someFunction`
- Use a selective open: `open Allegro in` on specific `do` blocks

## Layout

| Path | Contents |
|------|----------|
| `src/Allegro/` | Lean binding modules (Core + Addons + Compat + utilities) |
| `src/Allegro/Math.lean` | Math helpers (`clampF`, `lerpF`, `distF`, `toFloat`, `pi`, etc.) |
| `src/Allegro/Vec2.lean` | 2D vector type with operators (`+`, `-`, `*`, `normalize`, `rotate`) |
| `src/Allegro/GameLoop.lean` | High-level game loop combinator (`runGameLoop`) |
| `ffi/` | C shim wrappers (`allegro_*.c`, `allegro_ffi.h`) |
| `examples/` | Demo programs (one per addon / feature) |
| `tests/` | Smoke, functional, and error-path tests |
| `data/` | Shared assets (fonts, sample video, licenses) |
| `scripts/` | Cross-platform Allegro build helpers (`build-allegro.sh`, `build-allegro.ps1`, `init-project.sh`) |
| `docs/` | [Overview](docs/Overview.md) · [Build](docs/Build.md) · [FFI](docs/FFI.md) |

## Documentation

- [docs/Overview.md](docs/Overview.md) — Architecture and module parity matrix
- [docs/Build.md](docs/Build.md) — Cross-platform build instructions
- [docs/FFI.md](docs/FFI.md) — FFI design, memory model, and conventions

## License

See [LICENSE](LICENSE) for details.
