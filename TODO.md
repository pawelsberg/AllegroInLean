# AllegroInLean TODO

Lean 4 FFI bindings to Allegro 5.

---

## Strongly-typed enums ✅

All magic integer constants have been replaced with lightweight
`structure Foo where val : UInt32` wrapper types.  Each `@[extern]`
function uses a `private opaque …Raw` with plain `UInt32` + an
`@[inline]` public wrapper that marshals via `.val` / `⟨v⟩`, so the
C shims remain unchanged.

- [x] **Audio depth** — `AudioDepth` (int8, int16, int24, float32, uint8, uint16, uint24)
- [x] **Channel configuration** — `ChannelConf` (conf1–conf71)
- [x] **Playmode** — `Playmode` (once, loop, bidir)
- [x] **Mixer quality** — `MixerQuality` (point, linear, cubic)
- [x] **Blend operations** — `BlendOp` (add, srcMinusDest, destMinusSrc)
- [x] **Blend factors** — `BlendFactor` (zero, one, alpha, inverseAlpha, …)
- [x] **Flip flags** — `FlipFlags` (none, horizontal, vertical) — bitfield
- [x] **Pixel format** — `PixelFormat` (any, argb8888, rgba8888, …)
- [x] **Bitmap flags** — `BitmapFlags` (memoryBitmap, videoBitmap, …) — bitfield
- [x] **Lock mode** — `LockMode` (readWrite, readOnly, writeOnly)
- [x] **Bitmap wrap mode** — `BitmapWrapMode` (default, repeat, clamp, mirror)
- [x] **Display flags** — `DisplayFlags` (windowed, fullscreen, …) — bitfield
- [x] **Display option** — `DisplayOption` (redSize, greenSize, …)
- [x] **Display option importance** — `DisplayOptionImportance` (dontCare, require, suggest)
- [x] **Render state** — `RenderState` (alphaTest, alphaFunction, writeRgb, writeAlpha, writeDepth)
- [x] **Render function** — `RenderFunction` (never, always, less, equal, …)
- [x] **Write mask** — `WriteMask` (rgb, alpha, depth, all) — bitfield
- [x] **Display orientation** — `DisplayOrientation` — bitfield
- [x] **State flags** — `StateFlags` (blender, targetBitmap, all, …) — bitfield
- [x] **Event types** — `EventType` (joystickAxis, keyDown, timer, displayClose, …)
- [x] **Shader types & platform** — `ShaderType` (vertex, pixel), `ShaderPlatform` (auto, glsl, hlsl)
- [x] **Key codes** — `KeyCode` (keyA–keyZ, keyF1–keyF12, keyEscape, …)
- [x] **System cursor** — `SystemCursor` (default, arrow, busy, …)
- [x] **Primitives types** — `PrimType` (pointList, lineList, triangleList, …)
- [x] **Prim buffer flags** — `PrimBufferFlags` (stream, static, dynamic, …)
- [x] **Line join / cap** — `LineJoin` (none, bevel, round, miter), `LineCap` (none, square, round, triangle, closed)
- [x] **Prim attr / storage** — `PrimAttr`, `PrimStorage`
- [x] **Text alignment** — `TextAlign` (left, centre, right, integer)
- [x] **File chooser flags** — `FileChooserFlags` — bitfield
- [x] **Message box flags** — `MessageBoxFlags` — bitfield
- [x] **Text log flags** — `TextLogFlags` — bitfield
- [x] **Menu item flags** — `MenuItemFlags` — bitfield
- [x] **Video position** — `VideoPosition` (actual, videoDecode, audioDecode)
- [x] All `@[extern]` functions wrapped with `Raw` + `@[inline]` typed wrappers
- [x] All demos, tests, and Compat.lean updated
- [x] 581/581 functional tests passing

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

