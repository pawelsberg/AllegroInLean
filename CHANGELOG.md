# Changelog

All notable changes to AllegroInLean are documented in this file.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/).

---

## Ergonomic improvements (utility modules, API polish, consumer tooling)

### Added
- **Math utilities** (`src/Allegro/Math.lean`): `toFloat`, `u32ToFloat`, `intToFloat`, `pi`, `tau`, `absF`, `clampF`, `lerpF`, `distF`, `distSqF`, `minF`, `maxF`, `wrapAngle`, `degToRad`, `radToDeg`, `signF`.
- **Vec2 type** (`src/Allegro/Vec2.lean`): 2D vector with `Add`/`Sub`/`Neg`/`HMul`/`ToString` instances and operations (`normalize`, `lerp`, `rotate`, `angle`, `perp`, `clamp`).
- **Game loop combinator** (`src/Allegro/GameLoop.lean`): `runGameLoop` with `GameConfig`, `GameEvent`, `AddonFlag` — eliminates ~30 lines of boilerplate per game.
- **Float-returning accessors**: `eventGetMouseXf`/`Yf`/`Zf`/`Wf`/`Dxf`/`Dyf` (C shim + Lean) and `getDisplayWidthF`/`HeightF` for direct Float coordinates.
- **RGBA primitive variants**: 10 C shim functions + Lean bindings (`drawLineRgba`, `drawFilledRectangleRgba`, etc.) + Color-accepting `A` overloads.
- **In-memory sample creation**: `createSampleFromPCM` / `createSampleFromPCM?` — create samples from `ByteArray` without writing WAV to disk.
- **Sound convenience layer**: `PlayParams` structure, `playOnce`/`playLoop`/`playWith` wrappers in `Audio.lean` + `Compat.lean`.
- **Better error messages**: `initOrFail` (throws descriptive error), `checkSetup` diagnostic function.
- **Starter kit script**: `scripts/init-project.sh` bootstraps a new game project with `lean-toolchain`, `lakefile.lean`, `Main.lean`, font, and build script.
- **Joystick version guards**: `#if ALLEGRO_VERSION_INT >= AL_ID(5,2,11,0)` guards in `ffi/allegro_joystick.c` for graceful degradation on Allegro < 5.2.11.
- **lakefile documentation**: Public API docs explaining `allegroLinkArgs` and `allegro_exe` macro for consumer packages.

### Changed
- Root `Allegro.lean` now imports `Math`, `Vec2`, and `GameLoop` modules.
- README rewritten: leads with `Option`-returning API patterns; minimal example uses `initOrFail` and `createDisplay?`; added "Idiomatic Lean" section; layout table updated with new modules; `init-project.sh` documented.
- `JoystickDemo` updated: removed local `clampF` (now uses `Allegro.clampF` from `Math.lean`).
- Tests: 581 functional + 212 error-path = 793 total (all passing).

---

## Post-Milestone (gap-fill, Compat migration, docs audit)

### Added
- **New core subsystems:** File I/O (31 bindings), Filesystem (20), Haptic (26), Shader (17) — with C shims, Lean modules, tests, and demos for each.
- **Gap-fill bindings:** ~320 additional functions across all existing modules (System, Display, Bitmap, Events, Input, Timer, Transforms, Path, Joystick, Touch, Blending, Ustr, Audio, Color, Font, Primitives, TTF, Native Dialog, Video). Coverage rose from ~579 to ~900 bindings.
- **42 handle types** (up from 24): added `AllegroFile`, `FsEntry`, `Haptic`, `HapticEffectId`, `Shader`, `Menu`, `VertexDecl`, `VertexBuffer`, `IndexBuffer`, `AudioRecorder`, `SampleId`, `Timeout`, `TouchInputState`, `TtfFont`, plus `LockedRegion`.
- **56 Option-returning wrappers** (up from 28).
- **533 Compat dot-notation wrappers** covering all handle types.
- **18 new extras/thematic demos:** SystemExtras, DisplayExtras, BitmapExtras, EventExtras, TransformExtras, PathExtras, UstrExtras, ColorExtras, AudioExtras, PrimitivesExtras, ConfigExtras, FontExtras, JoystickExtras, MenuExtras, FileIO, Shader, Haptic, VideoFile. Total demo count: 37.
- **`scripts/build-allegro.sh --clean`** option to remove source and install dirs.

### Fixed
- `allegro_al_play_sample` C shim treated the `Playmode` value as a boolean (`loop ? LOOP : ONCE`); since `Playmode.once` = 0x100 (non-zero), it was always interpreted as `LOOP`. Changed to `(ALLEGRO_PLAYMODE)playmode` to pass the actual enum value through.

### Changed
- Removed all 337 backward-compatible `def` aliases from 13 `src/` modules; migrated all examples and tests to typed enum constructors (e.g. `EventType.keyDown` instead of `eventTypeKeyDown`).
- All 37 demos and 3 test suites migrated from `Allegro.functionName handle args` to dot-notation via `Allegro.Compat`.
- All markdown documentation updated to reflect current project state
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
