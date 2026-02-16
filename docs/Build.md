# Build

## Prerequisites
- **Lean 4** — install via [elan](https://github.com/leanprover/elan). The required toolchain version is pinned in `lean-toolchain`.
- **Allegro 5** installed on the system (or built locally).
- **pkg-config** is recommended — the lakefile auto-detects Allegro's prefix via `pkg-config --variable=prefix allegro-5`.
- If Allegro is built locally via `scripts/build-allegro.sh` into `allegro-local/`, it will be discovered automatically as a fallback.

## Installing Allegro 5 (per platform)

### Linux — Debian / Ubuntu

> ⚠️ Ubuntu 24.04 / Debian 12 ship Allegro **5.2.9**. AllegroInLean requires
> **5.2.11**. If the build fails with `implicit declaration of function` errors
> in the C shim, build Allegro from source — see
> [Building from source](#building-from-source-helper-script) below.
> The Debian/Ubuntu build dependencies are listed in that section.

```bash
sudo apt-get update
sudo apt-get install -y \
  liballegro5-dev liballegro-image5-dev \
  liballegro-ttf5-dev \
  liballegro-audio5-dev liballegro-acodec5-dev \
  liballegro-dialog5-dev liballegro-video5-dev \
  libgtk-3-dev   # needed by native-dialog addon
```

> **Note:** `liballegro5-dev` already includes the font, primitives, color,
> and memfile headers on Debian/Ubuntu. The per-addon `-dev` packages
> (`liballegro-font5-dev`, `liballegro-primitives5-dev`) do **not exist**
> in Ubuntu 24.04 / Debian 12 and will cause `apt-get` to fail.

### Linux — Fedora / Rocky / RHEL

> ⚠️ **Allegro 5 packages are not available** in the standard Fedora, Rocky Linux,
> or RHEL repositories (as of 2025). The `dnf install` commands below are listed
> for completeness — they may work on Fedora spins that carry EPEL or third-party
> repos, but on a stock install they will fail. **The recommended path is to build
> from source** using the provided helper script (see
> [Building from source](#building-from-source-helper-script) below).

```bash
# These packages may NOT be available — see warning above.
sudo dnf install -y \
  allegro5-devel allegro5-addon-image-devel allegro5-addon-font-devel \
  allegro5-addon-ttf-devel allegro5-addon-primitives-devel \
  allegro5-addon-audio-devel allegro5-addon-acodec-devel \
  allegro5-addon-dialog-devel allegro5-addon-video-devel \
  gtk3-devel
```
If per-addon `-devel` packages are not available, a single `allegro5-devel` may
pull in everything.

### macOS (Homebrew)
```bash
brew install allegro pkg-config
```
Homebrew installs all addons and sets up `pkg-config` automatically.

### Windows (MSYS2 / MinGW-w64)
```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-allegro mingw-w64-x86_64-pkg-config
```

> **GCC is required.** Lake compiles the C shim with `cc`, which is
> provided by the `mingw-w64-x86_64-gcc` package.

Either run `lake build` from the MSYS2 **MINGW64** shell (which sets up
`PATH` automatically), or add `C:\msys64\mingw64\bin` to your system
`PATH` so that `cc`, `pkg-config`, and the Allegro DLLs are found from
PowerShell / CMD / VS Code terminals.

To set the path for the current PowerShell session:
```powershell
$env:PATH = "C:\msys64\mingw64\bin;" + $env:PATH
```

If pkg-config is still not discovered, point `allegroPrefix` explicitly:
```bash
lake build -K allegroPrefix=/mingw64
```

### Building from source (helper script)

If system packages are not available (common on Fedora / Rocky / RHEL), or you
prefer a local build, use the provided script to download and build Allegro into
a local `allegro-local/` prefix.

#### Build dependencies

The script needs `cmake`, `make`, and a C compiler (`cc` / `gcc`). Allegro
itself needs development headers for the features you want:

**Fedora / Rocky / RHEL:**
```bash
sudo dnf install -y gcc gcc-c++ cmake make \
  libX11-devel libXcursor-devel libXrandr-devel libXi-devel \
  mesa-libGL-devel libpng-devel libjpeg-turbo-devel \
  freetype-devel pulseaudio-libs-devel openal-soft-devel \
  libvorbis-devel flac-devel libtheora-devel gtk3-devel
```

**Debian / Ubuntu:**
```bash
sudo apt-get install -y build-essential cmake \
  libx11-dev libxcursor-dev libxrandr-dev libxi-dev \
  libgl-dev libpng-dev libjpeg-dev \
  libfreetype-dev libpulse-dev libopenal-dev \
  libvorbis-dev libflac-dev libtheora-dev libgtk-3-dev
```

**macOS:** `xcode-select --install && brew install cmake`

> Missing optional dependencies will not break the build — Allegro simply
> disables the corresponding addon (e.g. no PulseAudio headers → no audio
> backend). However, you likely want most of them for game development.

#### Running the build script

**Linux / macOS / FreeBSD:**
```bash
./scripts/build-allegro.sh
```

**Windows (PowerShell + MSYS2):**
```powershell
.\scripts\build-allegro.ps1
# or, using vcpkg instead of building from source:
.\scripts\build-allegro.ps1 -UseVcpkg
```

The scripts accept `--prefix DIR` / `-Prefix DIR` to change the install
location, `--jobs N` / `-Jobs N` to control parallelism, and `--clean` to
remove the source and install directories.

The lakefile will discover `allegro-local/` automatically via its fallback
`PKG_CONFIG_PATH`. To use a custom prefix:
```bash
lake build -K allegroPrefix=/path/to/your/prefix
```

## Configuration

### Consumer projects (using AllegroInLean as a dependency)

If you are using AllegroInLean as a Lake dependency in your own project (see
[README — Using as a dependency](../README.md#using-as-a-dependency)), you
need Allegro installed on your system **or** built locally inside your project.

> **Quick scaffold:** Use `scripts/init-project.sh` to generate all required
> files (`lean-toolchain`, `lakefile.lean`, `Main.lean`, build script, font)
> in one step:
> ```bash
> mkdir my_game && cd my_game
> /path/to/AllegroInLean/scripts/init-project.sh
> lake update && lake build
> ```

#### Quick-start checklist (consumer project)

1. Create three files: `lean-toolchain`, `lakefile.lean`, `Main.lean`
   (see the [README template](../README.md#using-as-a-dependency))
2. `lake update` — fetches AllegroInLean from GitHub
3. `lake build` — compiles your project (pass `-K allegroPrefix=…` if needed)
4. Run from the project root so relative asset paths (e.g. `data/`) resolve
5. On Windows, ensure `C:\msys64\mingw64\bin` is in `PATH` before building

#### Common consumer-project pitfalls

| Symptom | Cause | Fix |
|---------|-------|-----|
| `al_init` returns 0 silently | Header/library version mismatch | Pass `-K allegroPrefix=$PWD/allegro-local` |
| `Unknown identifier α` | `-DautoImplicit=false` in `moreLeanArgs` | Use explicit type params: `{T : Type}` |
| `Unknown constant ByteArray.mkEmpty` | API removed in Lean 4.27.0 | Use `ByteArray.empty` |
| `List.enum` not found | API removed in Lean 4.27.0 | Use `for i in List.range arr.size` + `arr[i]!` |
| `failed to synthesize Inhabited` | `arr[i]!` on a custom struct array | Add `deriving Inhabited` to the struct |
| Parse error on multi-line `{ s with }` | Continuation fields on new lines | Keep `with` update on one line |
| `implicit declaration of function` in C shim | System Allegro older than 5.2.11 | Build from source: `./scripts/build-allegro.sh` + `-K allegroPrefix` |
| Exit code `-1073741515` (Windows) | Allegro DLLs not on PATH | `$env:PATH = "C:\msys64\mingw64\bin;" + $env:PATH` |

The recommended approach for Fedora / Rocky / RHEL (where system packages are
unavailable):

```bash
# 1. Fetch the AllegroInLean dependency
lake update

# 2. Copy the build script into your project
mkdir -p scripts
cp .lake/packages/AllegroInLean/scripts/build-allegro.sh scripts/

# 3. Build Allegro locally
./scripts/build-allegro.sh

# 4. Build your project — pass the absolute path to allegro-local/
lake build -K allegroPrefix=$PWD/allegro-local
```

> ⚠️ **The `-K allegroPrefix=…` flag is critical.** The library's C shim is
> compiled as part of your build, and `allegroPrefix` controls which headers
> it uses. Without it, stale system headers (e.g. Allegro 5.2.9 in
> `/usr/local/include`) can silently shadow the local 5.2.11 headers, causing
> the `al_init` macro to embed the wrong version — leading to `al_init`
> returning `false` at runtime with no error message.

Make sure your consumer `lakefile.lean` includes the proper `-L` and `-rpath`
flags for `allegro-local/` — see the [lakefile template](../README.md#step-2--lakefilelean) in the README.

### Build configuration (library development)

The build resolves the Allegro prefix in this order:

1. **Explicit flag** — `lake build -K allegroPrefix=/opt/allegro`
2. **Local build** — probes `allegro-local/` via `pkg-config` (produced by `scripts/build-allegro.sh`)
3. **System pkg-config** — queries `pkg-config` on the default `PKG_CONFIG_PATH`
4. **Common prefixes** — probes `/usr/local`, `/opt/homebrew` (useful on RHEL/Rocky, macOS)
5. If none succeed, the link step will fail with "unable to find library".

## Build
```
lake build
```

## Run examples

You can run demos either via `lake exe` or directly from the build output.

```bash
lake exe allegroLoopDemo                              # via Lake
.lake/build/bin/allegroConfigDemo                     # direct binary path

# More examples:
lake exe allegroConfigDemo     # console-only — Config subsystem
lake exe allegroColorDemo      # console-only — Color addon
lake exe allegroUstrDemo       # console-only — Ustr (Unicode strings)
lake exe allegroPathDemo       # console-only — Path helpers
lake exe allegroBlendingDemo   # windowed — blend-mode visualiser
lake exe allegroNativeDialogDemo  # windowed — file chooser, message box, text log
```

> **Windows:** Use backslashes and `.exe` suffix for direct paths:
> `.lake\build\bin\allegroConfigDemo.exe`. Ensure `C:\msys64\mingw64\bin`
> is on your `PATH` (see [Windows setup](#windows-msys2--mingw-w64) above).

> **Wayland note:** The native dialog demo requires XWayland on Wayland sessions.
> Launch with `GDK_BACKEND=x11 lake exe allegroNativeDialogDemo`.

See `examples/Examples/` for the full list.

## Run tests

The project ships three test executables. They all run headless (no display
required, or only a memory-bitmap display) and print PASS/FAIL per test.

### Smoke test
A quick integration check: initialises every addon, creates a display, and tears
down cleanly.

```bash
lake build allegroSmoke && .lake/build/bin/allegroSmoke
```

### Functional tests
Per-module tests that exercise bindings against real Allegro behaviour (config
round-trips, colour math, font metrics, path manipulation, etc.).

```bash
lake build allegroFuncTest && .lake/build/bin/allegroFuncTest
```

### Error-path tests
Validates that bad inputs return sensible failures (null handles, missing files,
out-of-range parameters, `Option`-returning wrappers, etc.).

```bash
lake build allegroErrorTest && .lake/build/bin/allegroErrorTest
```

### Run all tests at once

```bash
lake build allegroSmoke allegroFuncTest allegroErrorTest && \
  .lake/build/bin/allegroSmoke && \
  .lake/build/bin/allegroFuncTest && \
  .lake/build/bin/allegroErrorTest
```

> **Windows:** Use backslashes, `.exe` suffix, and `;` instead of `&&`:
> `lake build allegroSmoke; .lake\build\bin\allegroSmoke.exe`

### Data files
Some tests and examples reference files under `data/`:
- `data/sample.png` — used by `ImageDemo`
- `data/sample.ogv` — used by `VideoDemo` and `VideoFileDemo`
- `data/DejaVuSans.ttf` — used by `TtfDemo`, `GameLoopDemo`, and TTF functional tests
- `data/beep.wav` — used by `AudioDemo`, `GameLoopDemo`, and audio functional tests

Some tests generate temporary files (`_test_save.wav`, `_test_save_f.wav`) in `data/`
during execution — these are gitignored.

If an asset is missing, the test/demo will print a SKIP or warning rather than fail.

## Troubleshooting

### `al_init` fails silently at runtime (returns 0)

The `al_init()` macro embeds `ALLEGRO_VERSION_INT` at compile time and checks
it against the runtime library version. If the C shim was compiled against
different headers than the `.so` loaded at runtime, `al_init` will return
`false`.

**Common cause:** Stale Allegro headers in `/usr/local/include/allegro5/`
(e.g. version 5.2.9) shadowing the `allegro-local/include/` headers (5.2.11).

**Fix:** Pass the correct prefix explicitly:
```bash
lake build -K allegroPrefix=$PWD/allegro-local
```

Or remove the stale headers:
```bash
sudo rm -rf /usr/local/include/allegro5 /usr/local/lib64/liballegro*
```

### Build fails with "implicit declaration of function"

The installed Allegro version is older than 5.2.11. Some APIs
(`al_get_display_adapter`, `al_get_render_state`, `al_get_joystick_guid`,
etc.) were added in later releases. Build Allegro 5.2.11 from source:

```bash
./scripts/build-allegro.sh
lake build -K allegroPrefix=$PWD/allegro-local
```

### Windows exits with code `-1073741515` (`0xC0000135`)

The executable was built, but Windows cannot locate one or more Allegro DLLs
at startup. Ensure `C:\msys64\mingw64\bin` is in `PATH` **for the same shell
session where you run the executable**:

```powershell
$env:PATH = "C:\msys64\mingw64\bin;" + $env:PATH
.lake\build\bin\my_game.exe
```

Using the MSYS2 `MINGW64` shell also works because it sets this path
automatically.

### `allegro5/allegro_native_dialog.h: No such file or directory`

The native dialog addon header is missing from your Allegro installation.
On Debian/Ubuntu, install `liballegro-dialog5-dev`. On Fedora/Rocky, build
from source (the build script includes native dialog support when GTK 3
headers are available):

```bash
sudo dnf install gtk3-devel
./scripts/build-allegro.sh --clean
```

### Linker: "unable to find library -lallegro"

Allegro is not installed, or is installed in a non-standard location.
Either install system packages, build from source, or specify the prefix:

```bash
lake build -K allegroPrefix=/path/to/allegro
```

### Runtime: "error while loading shared libraries: liballegro.so.5.2"

The runtime linker cannot find Allegro shared libraries. Either:
- Ensure `-rpath` is set in your link flags (the template lakefile does this)
- Set `LD_LIBRARY_PATH`:
  ```bash
  LD_LIBRARY_PATH=allegro-local/lib64 .lake/build/bin/my_game
  ```

## Generate API documentation

Browsable HTML documentation is produced by
[doc-gen4](https://github.com/leanprover/doc-gen4). A ready-made
`docbuild/` sub-project is included in the repository.

```bash
cd docbuild
lake update doc-gen4                      # first time only — pins doc-gen4 & deps
DOCGEN_SRC=file lake build Allegro:docs   # generates HTML into .lake/build/doc/
```

> If your repo has a GitHub remote, you can omit `DOCGEN_SRC=file` and
> doc-gen4 will auto-detect the remote for source links.

To view the generated docs locally (required because of the browser's Same
Origin Policy):

```bash
cd .lake/build/doc
python3 -m http.server 8000
# open http://localhost:8000
```

> **Tip:** Set `DOCGEN_SRC=vscode` before `lake build` to make source links
> open files directly in VS Code instead of pointing at GitHub.

