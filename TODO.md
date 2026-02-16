# AllegroInLean TODO

Lean 4 FFI bindings to Allegro 5.

---

## Platform game example (isometric)

Create a self-contained isometric platform game in `examples/IsometricGame/`:

- [ ] **Project structure** — `examples/IsometricGame/` with its own `data/` folder
      for all sprites, tilesets, sounds, and level definitions
- [ ] **Isometric rendering** — tile-based isometric view with depth sorting
- [ ] **Player character** — animated sprite with walk and jump animations,
      controlled via keyboard (arrow keys + space to jump)
- [ ] **Room system** — one room visible at a time, 9 rooms total for level 1,
      connected by exits at room edges
- [ ] **Diamond collectibles** — diamonds scattered across rooms, with pickup
      sound and counter HUD
- [ ] **Multiple sprites** — player, diamonds, room tiles, decorations
      (all original or CC0 assets in `data/`)
- [ ] **Multiple sounds** — jump, land, diamond pickup, room transition,
      background music
- [ ] **HUD** — diamond count, current room indicator
- [ ] **Level data format** — simple text or JSON level files in `data/`
      describing tile layout, diamond placement, and room connections
- [ ] **Lake target** — `allegro_exe` entry so `lake build allegroIsometricGame`
      works
- [ ] **README** — `examples/IsometricGame/README.md` with screenshot, controls,
      and how to run

## Reduce consumer-side boilerplate & adopt Lean-idiomatic patterns

Conclusions from user feedback analysis (Feb 2025).
Goal: fewer steps from `lake update` to a running game, and more Lean-native API surface.

### 1. Expose a Lake plugin / helper to eliminate the 40-line lakefile template

**Problem:** Every consumer must copy ~45 lines of platform-detection + link-flag
logic (`allegroLibDirs`, `allegroLinkArgs`, `-Wl,-rpath`, `-lm`, etc.) into their
own `lakefile.lean`.  This is the single largest onboarding friction point.

**What already exists in the library:**
- The library's own `lakefile.lean` already contains `allegroLinkArgs`,
  `allegroLibDirs`, `allegroIncludeDirs`, `allegroPrefixCandidates`, and the
  `allegro_exe` macro that injects `moreLinkArgs` + `extraDepTargets` automatically.
- However, **none of this propagates to downstream packages** — Lake does not
  re-export build configuration from dependencies by default.

**Status: partially done.**
- [x] Added documentation block in `lakefile.lean` explaining how consumers can
      use `allegroLinkArgs` and the `allegro_exe` macro.
- [ ] Investigate Lake's `extraDepTargets`, `postUpdate` hooks, and package-level
      config propagation to determine what can be auto-inherited by consumers.
- [ ] Create an `Allegro.Lake` module (or a `lakefile` helper script) that
      consumers can `import` and call, e.g.:
      ```lean
      import AllegroInLean.Lake
      -- one-liner: inherits link args, rpath, dep on allegroshim
      allegroPackage "my_game"
      ```
- [ ] At minimum, export `allegroLinkArgs` as a public def so consumers write:
      ```lean
      require AllegroInLean from git …
      lean_exe my_game where
        moreLinkArgs := AllegroInLean.allegroLinkArgs
        extraDepTargets := #[`allegroshim]
      ```

### 2. Lead with Option-returning API (`?`-suffixed) in README and demos

**Problem:** README examples use C-style `if display == 0 then` pattern.  The
library already has 56 `?`-suffixed variants (e.g. `createDisplay?`, `loadSample?`,
`loadTtfFont?`, `createTimer?`) returning `Option` — but they are secondary.

**Status: done.**
- [x] Rewrote README "Main.lean" minimal example to use `Option`-style
      (`let some display ← createDisplay? 640 480 | …`).
- [x] Added "Idiomatic Lean: Option-returning API" section to README with
      preferred vs avoid patterns and a list of all `?` variants.
- [x] Added `initOrFail` in `System.lean` for one-liner init with descriptive errors.
- [ ] Rewrite `GameLoopDemo.lean` and `FullDemo.lean` to use `?` variants
      as the primary pattern.
- [x] Keep the raw `UInt64` / `== 0` API available but position it as
      "low-level / C-interop" in docs.

### 3. Add a high-level game-loop combinator

**Problem:** Every game repeats ~30 lines of boilerplate: create timer, create
queue, register sources, `while running do queue.waitFor …`, check `queue.isEmpty`
before redraw, cleanup in reverse order.

**Status: done.**
- [x] Created `src/Allegro/GameLoop.lean` with `runGameLoop` combinator,
      `GameConfig` structure (width, height, fps, addons, window title),
      `GameEvent` inductive (tick, keyDown, keyUp, keyChar, mouseMove,
      mouseDown, mouseUp, quit, resize, other), and `AddonFlag` inductive.
- [x] Automatic addon init/shutdown, display/timer/queue lifecycle.
- [ ] Rewrite `GameLoopDemo` to use the combinator as a reference (~50 lines).
- [x] Manual loop pattern remains documented for advanced use cases.

### 4. Provide Float-returning mouse position accessors

**Problem:** `evt.mouseX` and `evt.mouseY` return `UInt32`, requiring awkward
conversion (`mx.toNat.toUInt64.toFloat`) for any drawing or hit-testing math.

**Status: done.**
- [x] Added C shim functions `allegro_al_event_get_mouse_{x,y,z,w,dx,dy}_f`
      returning Float via `lean_box_float`.
- [x] Added Lean bindings `eventGetMouseXf`/`Yf`/`Zf`/`Wf`/`Dxf`/`Dyf` in
      `Events.lean`.
- [x] Added `Event.mouseXf`/`mouseYf`/etc. dot-notation aliases in `Compat.lean`.
- [x] Added `getDisplayWidthF`/`getDisplayHeightF` Float-returning display
      dimension accessors in `Display.lean` + `Compat.lean`.

### 5. Bundle a minimal asset pipeline / "starter kit" command

**Problem:** After `lake update`, the font is buried in
`.lake/packages/AllegroInLean/data/DejaVuSans.ttf` and users must manually
`mkdir -p data && cp …`.  The README documents this but it's still manual friction.

**Status: done.**
- [x] Created `scripts/init-project.sh` that copies `build-allegro.sh`,
      `DejaVuSans.ttf` + license, generates `lean-toolchain`, `lakefile.lean`,
      and a minimal `Main.lean` scaffold. Never overwrites existing files.
- [x] Documented the one-liner in README "Using as a dependency" section.

### 6. Consider graceful degradation for Allegro < 5.2.11

**Problem:** The hard 5.2.11 requirement (due to `al_get_joystick_guid` and
similar newer APIs) means Ubuntu 24.04 users must build from source.

**Status: done.**
- [x] Audited C shim for 5.2.11-only functions (joystick GUID, type, mappings,
      stick flags).
- [x] Added `#if ALLEGRO_VERSION_INT >= AL_ID(5, 2, 11, 0)` preprocessor guards
      in `ffi/allegro_joystick.c` with stub implementations in `#else` branch
      (return empty string / 0).
- [ ] Test with Ubuntu 24.04's system Allegro 5.2.9 packages.
- [ ] On the Lean side, consider gating bindings behind a config flag or
      returning `none` for unavailable functions.

### 7. Add `createSampleFromPCM` (in-memory sample creation)

**Problem:** Generating procedural audio currently requires writing a WAV file
to disk, then loading it back.  Allegro's memfile addon or
`al_register_sample_loader_f` could support creating samples from a `ByteArray`.

**Status: done.**
- [x] Added C shim `allegro_al_create_sample_from_pcm` in `ffi/allegro_audio.c`
      that copies a `ByteArray` to a malloc'd buffer and calls `al_create_sample`
      with `freeBuf=true`.
- [x] Added Lean bindings `createSampleFromPCM` / `createSampleFromPCM?` in
      `Audio.lean` with typed `AudioDepth` / `ChannelConf` parameters.
- [x] Added `PlayParams` structure and `playOnce` / `playLoop` / `playWith`
      convenience wrappers in `Audio.lean` + `Compat.lean`.

### 8–12. Additional utility modules and ergonomic improvements (done)

The following were implemented alongside the items above:

- [x] **Math utilities** (`src/Allegro/Math.lean`) — `toFloat`, `u32ToFloat`,
      `intToFloat`, `pi`, `tau`, `absF`, `clampF`, `lerpF`, `distF`, `distSqF`,
      `minF`, `maxF`, `wrapAngle`, `degToRad`, `radToDeg`, `signF`.
- [x] **Vec2 type** (`src/Allegro/Vec2.lean`) — 2D vector with `x y : Float`,
      `add`/`sub`/`scale`/`neg`/`dot`/`length`/`normalize`/`lerp`/`rotate`/
      `angle`/`perp`/`clamp`/`zero` + `Add`/`Sub`/`Neg`/`HMul`/`ToString`
      operator instances.
- [x] **RGBA primitive variants** — 10 C shim functions + Lean bindings for
      `drawLineRgba`, `drawCircleRgba`, `drawFilledRectangleRgba`, etc. plus
      Color-accepting `A` overloads (`drawLineA`, `drawFilledRectangleA`, etc.)
      in `Primitives.lean`.
- [x] **Better error messages** — `initOrFail` in `System.lean` (throws
      descriptive `IO.userError` on init failure) + `checkSetup` diagnostic
      in `Compat.lean` (checks system init, keyboard, audio, default mixer).
- [x] **Root import updated** — `Allegro.lean` now imports `Math`, `Vec2`, and
      `GameLoop` so `import Allegro` brings in everything.

---

## Known Issues & Notes

Known exclusions (intentional):
- Thread creation/lifecycle — incompatible with Lean runtime
- PhysFS addon — external dependency not typically installed
- Core `al_map_*/al_unmap_*` colour functions — by design (colours flow as float components through C shim wrappers)
- Callback-based functions (`al_register_*`, `al_draw_soft_*`, `al_set_mixer_postprocess_callback`) — inherently difficult to bind from Lean FFI
- `fixed.h` — contains only macros, no `AL_FUNC` declarations
- Haptic effect struct functions (`al_upload_haptic_effect`, `al_play_haptic_effect`,
  `al_upload_and_play_haptic_effect`, `al_is_haptic_effect_ok`,
  `al_get_haptic_effect_duration`) — require complex `ALLEGRO_HAPTIC_EFFECT`
  struct binding; rumble effect available via `uploadRumbleEffect`
- `al_get_audio_output_device` — returns opaque `ALLEGRO_AUDIO_DEVICE*`; name
  is accessible via `getAudioDeviceName`
- `al_get_audio_recorder_event` — requires `ALLEGRO_AUDIO_RECORDER_EVENT` struct binding

Known Allegro bugs (re-check after Allegro update):
- **`al_play_audio_stream_f` double-free** (Allegro 5.2.11) — internal cleanup-order
  bug. Workaround: test calls `playAudioStreamF` with null file pointer.

Notes:
- `lockSampleId` / `unlockSampleId` — tested in `Tests.Functional` (passes on
  machines with audio output). `playSampleWithId` may return 0 in headless CI
  environments; the test suite handles this gracefully.

