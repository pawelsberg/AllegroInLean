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

**Plan:**
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
- [ ] Document the simplified lakefile in README "Using as a dependency".

### 2. Lead with Option-returning API (`?`-suffixed) in README and demos

**Problem:** README examples use C-style `if display == 0 then` pattern.  The
library already has 56 `?`-suffixed variants (e.g. `createDisplay?`, `loadSample?`,
`loadTtfFont?`, `createTimer?`) returning `Option` — but they are secondary.

**What already exists:**
- `src/Allegro/Core/Display.lean` — `createDisplay?`
- `src/Allegro/Core/Bitmap.lean` — `createBitmap?`, `cloneBitmap?`, `loadBitmap?`, etc.
- `src/Allegro/Addons/Audio.lean` — `loadSample?`
- `src/Allegro/Addons/Ttf.lean` — `loadTtfFont?`
- `src/Allegro/Core/System.lean` — `liftOption` helper used to build all of these
- `Allegro.Compat` — dot-notation aliases include `?` variants (`Bitmap.clone?`, etc.)

**Plan:**
- [ ] Rewrite README "Main.lean" minimal example to use `Option`-style:
      ```lean
      let some display ← createDisplay? 640 480
        | do IO.eprintln "createDisplay failed"; return
      ```
- [ ] Rewrite `GameLoopDemo.lean` and `FullDemo.lean` to use `?` variants
      as the primary pattern.
- [ ] Keep the raw `UInt64` / `== 0` API available but position it as
      "low-level / C-interop" in docs.
- [ ] Add `init?` returning `IO (Option Unit)` or `IO Bool` wrapper for
      `Allegro.init` (currently returns `UInt32`).

### 3. Add a high-level game-loop combinator

**Problem:** Every game repeats ~30 lines of boilerplate: create timer, create
queue, register sources, `while running do queue.waitFor …`, check `queue.isEmpty`
before redraw, cleanup in reverse order.

**What already exists:**
- `src/Allegro/Resource.lean` — 22 `with*` RAII wrappers (`withDisplay`,
  `withTimer`, `withEventQueue`, etc.) already handle creation + destruction.
- `docs/Overview.md` — describes the "Functional game loop pattern" with pure
  `GameState` + `InputState` → `GameState` updates.
- `examples/Examples/GameLoopDemo.lean` — 272-line "Catch the Stars" game that
  is a perfect specimen of the boilerplate to factor out.

**Plan:**
- [ ] Create `src/Allegro/GameLoop.lean` with a combinator like:
      ```lean
      def Allegro.runGame (cfg : GameConfig) (init : IO σ)
          (onEvent : σ → EventInfo → σ)
          (draw    : σ → IO Unit)
          (cleanup : σ → IO Unit := fun _ => pure ()) : IO Unit
      ```
      where `GameConfig` bundles display size, FPS, which addons to init, etc.
      Internally uses `withDisplay`, `withTimer`, `withEventQueue`, `withEvent`.
- [ ] Define `EventInfo` sum type wrapping `EventType` + relevant fields
      (key code, mouse position, etc.) so consumers don't need raw `evt.type`
      dispatch chains.
- [ ] Rewrite `GameLoopDemo` to use the combinator as a reference (~50 lines).
- [ ] Keep the manual loop pattern documented for advanced use cases.

### 4. Provide Float-returning mouse position accessors

**Problem:** `evt.mouseX` and `evt.mouseY` return `UInt32`, requiring awkward
conversion (`mx.toNat.toUInt64.toFloat`) for any drawing or hit-testing math.

**What already exists:**
- `src/Allegro/Core/Events.lean` — `eventGetMouseX : Event → IO UInt32`,
  `eventGetMouseY : Event → IO UInt32`.
- `Allegro.Compat` — `Event.mouseX`, `Event.mouseY` (also `UInt32`).
- `EventData.mouseX`, `EventData.mouseY` — also `UInt32`.

**Plan:**
- [ ] Add to `Events.lean`:
      ```lean
      def eventGetMouseXf (e : Event) : IO Float := do
        let v ← eventGetMouseX e; pure v.toFloat
      def eventGetMouseYf (e : Event) : IO Float := do
        let v ← eventGetMouseY e; pure v.toFloat
      ```
- [ ] Add `Event.mouseXf` / `Event.mouseYf` to `Compat.lean`.
- [ ] Consider changing the C shim to return `Int32` (Allegro's actual type)
      instead of `UInt32`, and providing both `Int32` and `Float` Lean accessors.

### 5. Bundle a minimal asset pipeline / "starter kit" command

**Problem:** After `lake update`, the font is buried in
`.lake/packages/AllegroInLean/data/DejaVuSans.ttf` and users must manually
`mkdir -p data && cp …`.  The README documents this but it's still manual friction.

**What already exists:**
- `data/DejaVuSans.ttf`, `data/beep.wav`, `data/sample.png` — bundled assets.
- README documents the `cp` commands under "Data files" section.
- `withBuiltinFont` exists for zero-dependency prototyping.

**Plan:**
- [ ] Add a Lake `postUpdate` script (or `lake exe allegroInit`) that:
      1. Creates `data/` in the consumer project root.
      2. Copies `DejaVuSans.ttf` + license from the dependency.
      3. Generates a minimal `Main.lean` scaffold if none exists.
- [ ] Alternatively, add a `scripts/init-project.sh` that consumers run once.
- [ ] Document the one-liner in README Step 4.

### 6. Consider graceful degradation for Allegro < 5.2.11

**Problem:** The hard 5.2.11 requirement (due to `al_get_joystick_guid` and
similar newer APIs) means Ubuntu 24.04 users must build from source.

**What already exists:**
- `scripts/build-allegro.sh` — works but requires ~20 `-dev` packages and
  several minutes of compile time.
- The C shim uses all 5.2.11 functions unconditionally.

**Plan:**
- [ ] Audit the C shim for functions that are 5.2.11-only (joystick GUID,
      joystick type, joystick button label, joystick stick label, etc.).
- [ ] Gate those behind `#if ALLEGRO_VERSION_INT >= …` preprocessor guards.
- [ ] On the Lean side, gate the corresponding bindings behind a `have5211`
      config flag, or return `none` / stub values when unavailable.
- [ ] Test with Ubuntu 24.04's system Allegro 5.2.9 packages.

### 7. Add `createSampleFromPCM` (in-memory sample creation)

**Problem:** Generating procedural audio currently requires writing a WAV file
to disk, then loading it back.  Allegro's memfile addon or
`al_register_sample_loader_f` could support creating samples from a `ByteArray`.

**What already exists:**
- `src/Allegro/Addons/Memfile.lean` — `openMemfile`, `getMemfileVersion`.
- `docs/Overview.md` — documents the write-WAV-then-load workaround.

**Plan:**
- [ ] Implement `createSampleFromPCM : ByteArray → SampleDepth → ChannelConf → UInt32 → IO Sample`
      in the C shim using `al_open_memfile` + `al_load_sample_f`, or
      `al_create_sample` with direct buffer copy.
- [ ] Add a convenience wrapper and demo/test.

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

