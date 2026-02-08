# Build

## Prerequisites
- **Lean 4** — install via [elan](https://github.com/leanprover/elan). The required toolchain version is pinned in `lean-toolchain`.
- **Allegro 5** installed on the system (or built locally).
- **pkg-config** is recommended — the lakefile auto-detects Allegro's prefix via `pkg-config --variable=prefix allegro-5`.
- If Allegro is built locally via `scripts/build-allegro.sh` into `allegro-local/`, it will be discovered automatically as a fallback.

## Installing Allegro 5 (per platform)

### Linux — Debian / Ubuntu
```bash
sudo apt-get update
sudo apt-get install -y \
  liballegro5-dev liballegro-image5-dev liballegro-font5-dev \
  liballegro-ttf5-dev liballegro-primitives5-dev \
  liballegro-audio5-dev liballegro-acodec5-dev \
  liballegro-dialog5-dev liballegro-video5-dev \
  libgtk-3-dev   # needed by native-dialog addon
```

### Linux — Fedora / Rocky / RHEL
```bash
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
pacman -S mingw-w64-x86_64-allegro
```
Use the **MINGW64** shell. Point `allegroPrefix` to the MSYS2 prefix if
pkg-config is not on `PATH`:
```bash
lake build -K allegroPrefix=/mingw64
```

### Building from source (helper script)
If you prefer not to install system packages, use the provided script to
download and build Allegro into a local `allegro-local/` prefix:

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
The build resolves the Allegro prefix in this order:

1. **Explicit flag** — `lake build -K allegroPrefix=/opt/allegro`
2. **System pkg-config** — queries `pkg-config` on the default `PKG_CONFIG_PATH`
3. **Local build** — probes `allegro-local/` (produced by `scripts/build-allegro.sh`)
4. **Common prefixes** — probes `/usr/local`, `/opt/homebrew` (useful on RHEL/Rocky, macOS)
5. If none succeed, the link step will fail with "unable to find library".

## Build
```
lake build
```

## Run examples
```
lake exe allegroLoopDemo
lake exe allegroConfigDemo     # console-only — Config subsystem
lake exe allegroColorDemo      # console-only — Color addon
lake exe allegroUstrDemo       # console-only — Ustr (Unicode strings)
lake exe allegroPathDemo       # console-only — Path helpers
lake exe allegroBlendingDemo   # windowed — blend-mode visualiser
lake exe allegroNativeDialogDemo  # windowed — file chooser, message box, text log
```

> **Wayland note:** The native dialog demo requires XWayland on Wayland sessions.
> Launch with `GDK_BACKEND=x11 lake exe allegroNativeDialogDemo`.

See `examples/Examples/` for the full list.

## Run tests

The project ships three test executables. They all run headless (no display
required, or only a memory-bitmap display) and print PASS/FAIL per test.

### Smoke test
A quick integration check: initialises every addon, creates a display, and tears
down cleanly.

```
lake build allegroSmoke && .lake/build/bin/allegroSmoke
```

### Functional tests
Per-module tests that exercise bindings against real Allegro behaviour (config
round-trips, colour math, font metrics, path manipulation, etc.).

```
lake build allegroFuncTest && .lake/build/bin/allegroFuncTest
```

### Error-path tests
Validates that bad inputs return sensible failures (null handles, missing files,
out-of-range parameters, `Option`-returning wrappers, etc.).

```
lake build allegroErrorTest && .lake/build/bin/allegroErrorTest
```

### Run all tests at once
```
lake build allegroSmoke allegroFuncTest allegroErrorTest && \
  .lake/build/bin/allegroSmoke && \
  .lake/build/bin/allegroFuncTest && \
  .lake/build/bin/allegroErrorTest
```

### Data files
Some tests and examples reference files under `data/`:
- `data/sample.png` — used by `ImageDemo`
- `data/sample.ogv` — used by `VideoDemo` and `VideoFileDemo`
- `data/DejaVuSans.ttf` — used by `TtfDemo`, `GameLoopDemo`, and TTF functional tests
- `data/beep.wav` — used by `AudioDemo`, `GameLoopDemo`, and audio functional tests

Some tests generate temporary files (`_test_save.wav`, `_test_save_f.wav`) in `data/`
during execution — these are gitignored.

If an asset is missing, the test/demo will print a SKIP or warning rather than fail.

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

