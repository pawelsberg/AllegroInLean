# Changelog

All notable changes to AllegroInLean are documented in this file.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/).

---

## Post-Milestone (gap-fill, Compat migration, docs audit)

### Added
- **New core subsystems:** File I/O (31 bindings), Filesystem (20), Haptic (26), Shader (17) — with C shims, Lean modules, tests, and demos for each.
- **Gap-fill bindings:** ~320 additional functions across all existing modules (System, Display, Bitmap, Events, Input, Timer, Transforms, Path, Joystick, Touch, Blending, Ustr, Audio, Color, Font, Primitives, TTF, Native Dialog, Video). Coverage rose from ~579 to ~900 bindings.
- **42 handle types** (up from 24): added `AllegroFile`, `FsEntry`, `Haptic`, `HapticEffectId`, `Shader`, `Menu`, `VertexDecl`, `VertexBuffer`, `IndexBuffer`, `AudioRecorder`, `SampleId`, `Timeout`, `TouchInputState`, `TtfFont`, plus `LockedRegion`.
- **54 Option-returning wrappers** (up from 28).
- **533 Compat dot-notation wrappers** covering all handle types.
- **18 new extras/thematic demos:** SystemExtras, DisplayExtras, BitmapExtras, EventExtras, TransformExtras, PathExtras, UstrExtras, ColorExtras, AudioExtras, PrimitivesExtras, ConfigExtras, FontExtras, JoystickExtras, MenuExtras, FileIO, Shader, Haptic, VideoFile. Total demo count: 37.
- **Tests:** 626 functional + 212 error-path = 838 assertions (up from 423).
- **`scripts/build-allegro.sh --clean`** option to remove source and install dirs.

### Changed
- All 37 demos and 3 test suites migrated from `Allegro.functionName handle args` to dot-notation via `Allegro.Compat`.
- All markdown documentation updated to reflect current project state (31 modules, 27 C shims, 37 demos, 838 assertions, 42 handle types).

---

## Milestone C

### Added
- **Build system:** `pkg-config` auto-detection of Allegro prefix; 4-tier cascade (explicit flag → system pkg-config → local build → common prefixes). Cross-platform build scripts (`scripts/build-allegro.sh`, `scripts/build-allegro.ps1`).
- **CI matrix:** collapsed 3 duplicate platform jobs (Linux / macOS / Windows) into a single matrix job with `fail-fast: false`.
- **Centralized target lists:** example, test, and headless-demo lists defined once in workflow-level `env` vars — adding a new target requires editing a single line.
- **Lake build caching:** `actions/cache@v4` for `.lake/` keyed on toolchain + lakefile + manifest hash.
- **Headless demo runs:** console-only demos (Config, Color, Ustr, Path) executed in CI as extra smoke tests on all 3 platforms.
- **Failure artifact upload:** `actions/upload-artifact@v4` uploads `.lake/build/` on failure (5-day retention).
- **Shell strictness:** `set -euo pipefail` in all multi-line `run:` blocks.
- **Examples:** standalone demos for Config, Color, Ustr, Path, Blending, and Video subsystems.
- **VideoDemo:** video playback example using the Video addon (`data/sample.ogv`).
- **Docs:** `CONTRIBUTING.md`, `CHANGELOG.md`, test execution guide in `docs/Build.md`.

### Fixed
- GameLoopDemo star-catch sound played with `ALLEGRO_PLAYMODE_LOOP` instead of `ALLEGRO_PLAYMODE_ONCE`.

### Changed
- Vendored `allegro-5.2.11.2/` tree removed (116 MB); replaced by `scripts/build-allegro.sh` and `scripts/build-allegro.ps1`.
- `docs/Build.md` rewritten with updated configuration, example, and testing instructions.
- README updated: demo count 18 → 19, C shim count 19 → 23, assertion count 384 → 423, VideoDemo added to table.

---

## Milestone B″

### Added
- **Tuple APIs (10 groups):** clipping rectangle, pixel RGBA, window position, monitor info, display mode, blender, separate blender, transform coordinates, mouse cursor position, text dimensions.
- **C shim architecture:** stack-allocated `EventData` struct, 77 duplicate C/Lean bindings removed.
- **Tests:** 195 functional + 189 error-path = 384 total.

---

## Milestone B′

### Added
- **Type safety:** opaque newtypes for 24 handle types with `ToString`/`Repr` instances.
- **Colour tuple APIs:** 14 conversion groups (HSV, HSL, CMYK, YUV, OkLab, linear sRGB, named CSS, HTML hex).
- **Tests:** 170 functional + 193 error-path = 363 total.

---

## Milestone B

### Added
- **Addons:** Image, Font, TTF, Primitives, Audio, Acodec, Color.
- **Tests:** smoke, 156 functional, 193 error-path.
- **Resource wrappers:** `with*` RAII helpers for all owned handles.
- **State save/restore:** `storeState` / `restoreState` with flag constants.
- **Ustr extended:** 41 Unicode string functions bound.
- **`Option` wrappers:** 28 `?`-suffixed fallible-call variants across 11 modules, `liftOption` helper, `getErrno`/`setErrno`.

---

## Milestone A

### Added
- **Core APIs:** System, Display, Bitmap, Events, Input, Timer, Config, Blending, Transforms, Joystick, Touch, Path.
- **C FFI shim layer:** one `.c` file per module, `allegro_ffi.h` shared header.
- **Lakefile:** multi-target build with `extern_lib allegroshim`.
- **Initial examples:** LoopDemo, FullDemo, ImageDemo, FontDemo, TtfDemo, PrimitivesDemo, AudioDemo, InputDemo, TransformDemo, JoystickDemo, EventDemo, GameLoopDemo.
