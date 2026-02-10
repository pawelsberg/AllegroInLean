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

**Windows (MSYS2 / MinGW-w64)**

```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-allegro mingw-w64-x86_64-pkg-config
```

> Ensure `C:\msys64\mingw64\bin` is on your `PATH`, or run `lake build`
> from the MSYS2 **MINGW64** shell.

See [docs/Build.md](docs/Build.md) for Fedora, building from source via
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
.lake/build/bin/allegroFullDemo
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

**Linux / macOS:**
```bash
lake build allegroSmoke allegroFuncTest allegroErrorTest && \
  .lake/build/bin/allegroSmoke && \
  .lake/build/bin/allegroFuncTest && \
  .lake/build/bin/allegroErrorTest
```

**Windows (PowerShell):**
```powershell
lake build allegroSmoke allegroFuncTest allegroErrorTest
.lake\build\bin\allegroSmoke.exe
.lake\build\bin\allegroFuncTest.exe
.lake\build\bin\allegroErrorTest.exe
```

## Using as a dependency

To use AllegroInLean in your own Lean 4 project, add it as a dependency in your `lakefile.lean`:

```lean
import Lake
open Lake DSL

require AllegroInLean from git
  "https://github.com/pawelsberg/AllegroInLean" @ "main"

package my_game where
  moreLeanArgs := #["-DautoImplicit=false"]

-- Use the same link arguments as AllegroInLean
def allegroLibDirs : Array String :=
  if System.Platform.isWindows then
    #["-LC:/msys64/mingw64/lib"]
  else if System.Platform.isOSX then
    #["-L/opt/homebrew/lib"]
  else
    #[]

def allegroLinkArgs : Array String :=
  allegroLibDirs ++ #["-lallegro", "-lallegro_image", "-lallegro_font",
    "-lallegro_ttf", "-lallegro_primitives", "-lallegro_audio", "-lallegro_acodec",
    "-lallegro_color", "-lallegro_dialog", "-lallegro_video",
    "-lallegro_memfile"]

@[default_target]
lean_exe my_game where
  root := `Main`
  moreLinkArgs := allegroLinkArgs
```

Then import the library in your Lean files:

```lean
import Allegro
open Allegro
```

On Windows make sure the Allegro DLLs are on your `PATH` (e.g. `C:\msys64\mingw64\bin`).

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
