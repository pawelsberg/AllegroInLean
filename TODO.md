# AllegroInLean TODO

Lean 4 FFI bindings to Allegro 5.

---

## Remaining work

### Graceful degradation for Allegro < 5.2.11

C-side preprocessor guards are in place. Remaining Lean-side work:

- [ ] Test with Ubuntu 24.04's system Allegro 5.2.9 packages.
- [ ] On the Lean side, consider gating bindings behind a config flag or
      returning `none` for unavailable functions.

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

