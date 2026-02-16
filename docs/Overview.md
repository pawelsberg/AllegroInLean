# Allegro Lean Library

This library provides low-level Lean bindings to Allegro 5 with a small C shim and a set of 34 Lean modules grouped by subsystem: core (system, display, bitmap, events, input, timer, config, blending, transforms, joystick, touch, path, ustr, thread, file, filesystem, haptic, shader) and addons (image, font, ttf, primitives, audio, color, native dialog, video, memfile), plus a compatibility layer, RAII resource wrappers, and utility modules (Math, Vec2, GameLoop).

## Goals

- Thin, predictable FFI surface
- Clear ownership and explicit destruction
- Modules that map closely to Allegro addons
- A focused, documented surface for building small games/tools in Lean
- **Type safety**: all 42 handle types (Display, Bitmap, Timer, AllegroFile, Shader, Haptic, etc.) are opaque newtypes with `BEq`, `Inhabited`, `DecidableEq`, `OfNat 0`, `ToString`, and `Repr` instances — the compiler prevents mixing handle types
- **Option-returning variants**: 56 `?`-suffixed wrappers (e.g. `createTimer?`, `loadBitmap?`, `loadFont?`) return `Option α` instead of raw `0` on failure, plus `getErrno`/`setErrno` for error context
- **Utility modules**: `Math.lean` (clampF, lerpF, distF, etc.), `Vec2.lean` (2D vector type with operators), `GameLoop.lean` (high-level game loop combinator)
- **In-memory sample creation**: `createSampleFromPCM` creates samples from `ByteArray` without disk I/O
- **Better error handling**: `initOrFail` throws descriptive errors; `checkSetup` diagnoses common init issues

## Mission

Provide a minimal, stable, low-level binding that mirrors Allegro 5’s public API
while remaining idiomatic to Lean. Higher-level abstractions should be built on
top of this library, not inside it.

## Getting started

Minimal init/shutdown example:

```lean
import Allegro.Core.System

open Allegro

def main : IO Unit := do
  let okInit ← Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"
    return
  Allegro.uninstallSystem
  IO.println "ok"
```

### Common addon initialisation

Most games need several addons. Initialise them right after `Allegro.init`:

```lean
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  -- Core subsystems
  let _ ← Allegro.installKeyboard
  let _ ← Allegro.installMouse

  -- Addons — call initFontAddon before initTtfAddon
  let _ ← Allegro.initImageAddon
  Allegro.initFontAddon
  let _ ← Allegro.initTtfAddon
  let _ ← Allegro.initPrimitivesAddon
  let _ ← Allegro.installAudio
  let _ ← Allegro.initAcodecAddon
  let _ ← Allegro.reserveSamples 4    -- for fire-and-forget playback

  -- … create display, event queue, game loop …

  -- Shutdown in reverse order
  Allegro.uninstallAudio
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownTtfAddon
  Allegro.shutdownFontAddon
  Allegro.shutdownImageAddon
```

### Dot-notation via Allegro.Compat

When you `import Allegro` and `open Allegro`, the `Allegro.Compat` module is
included automatically. This provides dot-notation on handle types so you can
write `display.destroy`, `timer.start`, `queue.waitFor evt`, etc. instead of
the fully-qualified `Allegro.destroyDisplay display` style.

### Asset loading in consumer projects

The library demos use `getStandardPath` and `changeDirectory` to locate
`data/` relative to the executable. In consumer projects, this path resolves
to the binary directory (`.lake/build/bin/`), **not** the project root. The
simplest approach is to use relative paths and run from the project root:

```lean
-- Load assets via relative paths (run from project root)
let font ← Allegro.loadTtfFont "data/MyFont.ttf" 24 0
let sample ← Allegro.loadSample "data/beep.wav"
```

```bash
# Run from the project root so relative paths work
.lake/build/bin/my_game
```

### Common consumer project pitfalls

1. **`al_init` returns 0 / fails silently** — Almost always a header/library
   version mismatch. The `al_init` macro embeds `ALLEGRO_VERSION_INT` at compile
   time and compares it to the runtime library. If you built Allegro locally into
   `allegro-local/`, make sure to pass
   `lake build -K allegroPrefix=$PWD/allegro-local` so the C shim is compiled
   against the correct headers. Stale headers in `/usr/local/include` are a
   common culprit.

2. **Addon initialisation order** — `initFontAddon` must be called before
   `initTtfAddon`. `installAudio` must be called before `initAcodecAddon`.
   `reserveSamples` must be called before `loadSample`/`playSample`.

3. **Cleanup order** — Destroy resources in reverse order of creation.
   Shutdown addons in reverse order of initialisation.

### Functional game loop pattern

For games, keep your state in a pure `structure` and update it via pure functions.
Only the main event loop and drawing require `IO`. This makes game logic testable
and avoids excessive use of mutable references:

```lean
-- Pure game state — no IO
structure GameState where
  playerX : Float
  playerY : Float
  score   : Nat

structure InputState where
  upHeld   : Bool
  downHeld : Bool

-- Pure update — all game logic here
def gameTick (gs : GameState) (input : InputState) : GameState :=
  let dy := (if input.downHeld then 2.0 else 0.0) -
            (if input.upHeld   then 2.0 else 0.0)
  { gs with playerY := gs.playerY + dy }

-- IO only for rendering
def drawFrame (gs : GameState) (font : Allegro.Font) : IO Unit := do
  Allegro.clearToColorRgb 0 0 0
  Allegro.drawFilledCircleRgb gs.playerX gs.playerY 16 255 255 255
  Allegro.drawTextRgb font 255 255 0 10 10 Allegro.TextAlign.left s!"Score: {gs.score}"
  Allegro.flipDisplay
```

In the main loop, the only `mut` variables are the game state and input snapshot:

```lean
let mut gs := { playerX := 320, playerY := 240, score := 0 : GameState }
let mut input : InputState := { upHeld := false, downHeld := false }
-- on timer event:
gs := gameTick gs input
drawFrame gs font
```

This pattern scales well to complex games — rooms, enemies, and inventory can all
live inside the pure `GameState` structure.

### Array helper patterns for game state

When manipulating arrays in pure game logic (e.g. removing matched balls,
inserting elements), several common patterns are needed that don't have
direct standard library equivalents in Lean 4.27.0:

```lean
-- Remove element at index (since Array.eraseIdx may not be available)
def removeAt {T : Type} [Inhabited T] (a : Array T) (i : Nat) : Array T := Id.run do
  let mut r : Array T := #[]
  for j in List.range a.size do
    if j != i then r := r.push a[j]!
  return r

-- Filter array by index set
def removeIndices {T : Type} [Inhabited T] (a : Array T) (idxs : Array Nat) : Array T := Id.run do
  let mut r : Array T := #[]
  for j in List.range a.size do
    if !idxs.contains j then r := r.push a[j]!
  return r
```

> **Tip:** Always add `deriving Inhabited` to structures used in arrays
> with `!`-indexing. Without it, `arr[i]!` won't compile.

### Procedural audio generation

You can generate sound effects and music programmatically. The preferred
approach is `createSampleFromPCM`, which creates a sample directly from
a `ByteArray` without writing to disk:

```lean
-- Generate raw PCM data (e.g. 16-bit signed, mono, 44100 Hz)
let pcmData : ByteArray := generateMySound
let some sample ← Allegro.createSampleFromPCM? pcmData
    AudioDepth.int16 ChannelConf.conf1 44100
  | do IO.eprintln "createSampleFromPCM failed"; return
let _ ← Allegro.playOnce sample
```

Alternatively, you can write a WAV file to disk and load it:

```lean
-- Generate PCM, write as .wav, load as Allegro Sample
let pcmData := generateMySound  -- your ByteArray of 16-bit LE samples
let wavFile := buildWavHeader pcmData  -- prepend 44-byte RIFF/WAV header
IO.FS.writeBinFile "data/sfx.wav" wavFile
let sample ← Allegro.loadSample "data/sfx.wav"
```

Both approaches avoid needing to ship external audio assets and are useful
for prototyping or procedural games.

### Mouse input in the game loop

Mouse position is available via event fields. A common pattern:

```lean
else if eType == Allegro.EventType.mouseAxes then
  let mx ← evt.mouseX   -- UInt32
  let my ← evt.mouseY
  gs := { gs with mouseX := mx.toFloat, mouseY := my.toFloat }
else if eType == Allegro.EventType.mouseButtonDown then
  let btn ← evt.mouseButton
  if btn == 1 then  -- left click
    gs := handleLeftClick gs
```


## Structure

- `src/Allegro/*`: Low-level FFI bindings and resource wrappers
- `src/Allegro/Math.lean`: Math helpers (clampF, lerpF, distF, toFloat, pi, etc.)
- `src/Allegro/Vec2.lean`: 2D vector type with operators
- `src/Allegro/GameLoop.lean`: High-level game loop combinator (runGameLoop)
- `ffi/*`: C shim wrappers over Allegro C API
- `examples/`: Executable demos
- `tests/`: Smoke, functional, and error-path tests

## Module parity matrix (Allegro 5 vs Lean)

Status key: implemented | partial | deferred

| Allegro module/addon | Lean module(s) | Status | Notes |
| --- | --- | --- | --- |
| System | Allegro.Core.System | implemented | `init`, `uninstallSystem`, `rest`, `getTime`, version, app/org name, CPU/RAM, state save/restore, `getErrno`/`setErrno`, `liftOption` helper |
| Display | Allegro.Core.Display | implemented | Creation, flags, options, resize, window position/constraints, clipping, render state, backbuffer, clipboard, monitor info, display modes, icon, screensaver; tuple APIs for window position, clipping rect, monitor info, display mode |
| Bitmap | Allegro.Core.Bitmap | implemented | Create/clone/sub, pixel formats, locking, flags, pixel get/put (incl. tuple RGBA), scaled/rotated/tinted drawing |
| Events | Allegro.Core.Events | implemented | Queue, poll/wait, keyboard/mouse/display/timer/joystick/touch/user event fields; stack-allocated `EventData`; event type constants |
| Input | Allegro.Core.Input | implemented | Keyboard/mouse install, state queries, cursor show/hide, custom/system mouse cursors, warp, grab, key constants; tuple getMouseCursorPosition |
| Timer | Allegro.Core.Timer | implemented | Create/start/stop, speed, count |
| Config | Allegro.Core.Config | implemented | Create/load/save, sections, key/value, comments, merge, system config, section & entry iteration |
| Blending | Allegro.Core.Blending | implemented | Blender ops/factors, separate blender, RGBA clear/tinted draw; tuple APIs for getBlender, getSeparateBlender |
| Transforms | Allegro.Core.Transforms | implemented | Identity, translate, rotate, scale, compose, invert, projection, shear; tuple transformCoordinates |
| Joystick | Allegro.Core.Joystick | implemented | Install, enumerate, properties, state polling, event source |
| Touch | Allegro.Core.Touch | implemented | Install, event sources, mouse emulation modes |
| Path | Allegro.Core.Path | implemented | Create/clone, components, drive, filename, standard paths |
| Ustr | Allegro.Core.Ustr | implemented | 60+ functions: creation, append/insert/remove, search (chr/cstr/set/cset), comparison, prefix/suffix, trim, ref (cstr/buffer/ustr), UTF-8/UTF-16 encode/decode, `cstrDup`, `ustrToBuffer` |
| Thread | Allegro.Core.Thread | implemented | Mutex (create/lock/unlock/destroy), condition variables (create/wait/signal/broadcast/destroy), `withMutex` RAII helper. Thread *creation* intentionally skipped (incompatible with Lean runtime). |
| Image addon | Allegro.Addons.Image | implemented | Init/shutdown, load/save bitmap (incl. `ALLEGRO_FILE` variants), load with flags, identify bitmap (path and file), version query |
| Font addon | Allegro.Addons.Font | implemented | Builtin/bitmap/file fonts, text drawing (incl. ustr variants), multiline, justified, glyph queries/dimensions, metrics, fallback, grab from bitmap, version query; tuple getTextDimensions, getUstrDimensions, getGlyphDimensions |
| TTF addon | Allegro.Addons.Ttf | implemented | Init/shutdown, load, stretch, flag constants |
| Primitives addon | Allegro.Addons.Primitives | implemented | Shapes (line, triangle, rect, rounded rect, circle, ellipse, arc, pieslice), splines, polylines, polygons, ribbons; vertex/index buffer management; `packFloats`/`packPoints` helpers; prim type/buffer/join/cap constants |
| Audio addon | Allegro.Addons.Audio | implemented | Samples, instances, streams, mixers, voices, devices, playmode/depth/channel constants; acodec init |
| Color addon | Allegro.Addons.Color | implemented | HSV, HSL, CMYK, YUV, OkLab, linear sRGB, named CSS colours, HTML hex; tuple-returning APIs for all 14 conversion groups |
| Native dialogs | Allegro.Addons.NativeDialog | implemented | File chooser, message box, text log, menus including find/toggle/build (39 functions). Requires GTK 3 on Linux; on Wayland sessions launch with `GDK_BACKEND=x11`. |
| Video addon | Allegro.Addons.Video | implemented | Open/close (incl. `ALLEGRO_FILE` variant), start (mixer/voice), play/pause/seek, frame/position/fps queries, event source, identification (21 functions). |
| Memfile addon | Allegro.Addons.Memfile | implemented | `openMemfile`, `getMemfileVersion` |
| File I/O | Allegro.Core.File | implemented | `fopen`/`fclose`/`fread`/`fwrite`/`fseek`/`ftell`/`fsize`/`feof`/`ferror`/`fflush`/`fclearerr`/`fungetc`/`fgetc`/`fputc`, string I/O, temp files (31 functions) |
| Filesystem | Allegro.Core.Filesystem | implemented | `createFsEntry`, `fsEntryExists`, `fsEntryName`, `removeFilename`, `makeDirectory`, `openDirectory`/`readDirectory`/`closeDirectory`, stat queries (20 functions) |
| Haptic | Allegro.Core.Haptic | implemented | `installHaptic`, `getHaptic`, `isHapticInstalled`, `getMaxHapticEffects`, `isHapticActive`, `uploadRumbleEffect`/`playHaptic`/`stopHaptic`/`releaseHaptic` and more (26 functions) |
| Shader | Allegro.Core.Shader | implemented | `createShader`, `attachShaderSource`/`attachShaderSourceFile`, `buildShader`, `useShader`, `setShaderSampler`/`setShaderBool`/`setShaderInt`/`setShaderFloat`/`setShaderMatrix`, `destroyShader` (17 functions) |
| PhysFS addon | — | deferred | Requires external PhysFS library not typically installed |
| Compat layer | Allegro.Compat | implemented | Dot-notation aliases for all handle types (Display, Bitmap, Timer, Font, etc.) |
| Resource wrappers | Allegro.Resource | implemented | 22 `with*` RAII wrappers (display, timer, bitmap, events, config, transform, font, audio, input, mouse cursor, state) |
| Math utilities | Allegro.Math | implemented | `toFloat`, `clampF`, `lerpF`, `distF`, `absF`, `minF`, `maxF`, `pi`, `tau`, `wrapAngle`, `degToRad`, `radToDeg`, `signF` |
| Vec2 type | Allegro.Vec2 | implemented | 2D vector with `Add`/`Sub`/`Neg`/`HMul`/`ToString` instances and operations (`normalize`, `lerp`, `rotate`, `angle`, `perp`) |
| Game loop | Allegro.GameLoop | implemented | `runGameLoop` combinator with `GameConfig`, `GameEvent` sum type, `AddonFlag` — eliminates boilerplate |
