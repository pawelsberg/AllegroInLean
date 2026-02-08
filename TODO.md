# AllegroInLean TODO

Lean 4 FFI bindings to Allegro 5.

---

## Pre-Publication (must fix before first commit)

- [x] **Update CI `EXAMPLE_TARGETS`** — all 37 demos listed
- [x] **Update CI `HEADLESS_DEMOS`** — added 6 console-only extras (SystemExtras, PathExtras, ColorExtras, ConfigExtras, FileIO, EventExtras)
- [x] **Remove stale vendored-tree probe in `lakefile.lean`** — `localPkgConfigPath` cleaned
- [x] **Gitignore `docbuild/.lake/`** — 374 MB of build artifacts
- [ ] **Add `version`/`description` to `lakefile.lean` package declaration** — used by Reservoir (Lean package index)

## Known Issues & Notes

Known exclusions (intentional):
- Thread creation/lifecycle — incompatible with Lean runtime
- PhysFS addon — external dependency not typically installed
- Core `al_map_*/al_unmap_*` colour functions — by design (colours flow as float components through C shim wrappers)
- Callback-based functions (`al_register_*`, `al_draw_soft_*`, `al_set_mixer_postprocess_callback`) — inherently difficult to bind from Lean FFI
- `fixed.h` — contains only macros, no `AL_FUNC` declarations

Known Allegro bugs (re-check after Allegro update):
- **`al_play_audio_stream_f` double-free** (Allegro 5.2.11) — internal cleanup-order
  bug. Workaround: test calls `playAudioStreamF` with null file pointer.

Undemoed binding:
- `lockSampleId` / `unlockSampleId` — `playSampleWithId` returns 0 headless.
  Works on machines with audio output.

