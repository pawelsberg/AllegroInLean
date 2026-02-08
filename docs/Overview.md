# Allegro Lean Library

This library provides low-level Lean bindings to Allegro 5 with a small C shim and a set of 31 Lean modules grouped by subsystem: core (system, display, bitmap, events, input, timer, config, blending, transforms, joystick, touch, path, ustr, thread, file, filesystem, haptic, shader) and addons (image, font, ttf, primitives, audio, color, native dialog, video, memfile), plus a compatibility layer and RAII resource wrappers.

## Goals

- Thin, predictable FFI surface
- Clear ownership and explicit destruction
- Modules that map closely to Allegro addons
- A focused, documented surface for building small games/tools in Lean
- **Type safety**: all 42 handle types (Display, Bitmap, Timer, AllegroFile, Shader, Haptic, etc.) are opaque newtypes with `BEq`, `Inhabited`, `DecidableEq`, `OfNat 0`, `ToString`, and `Repr` instances — the compiler prevents mixing handle types
- **Option-returning variants**: 54 `?`-suffixed wrappers (e.g. `createTimer?`, `loadBitmap?`, `loadFont?`) return `Option α` instead of raw `0` on failure, plus `getErrno`/`setErrno` for error context

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
	let okInit <- Allegro.init
	if okInit == 0 then
		IO.eprintln "al_init failed"
		return
	Allegro.uninstallSystem
	IO.println "ok"
```


## Structure

- `src/Allegro/*`: Low-level FFI bindings and resource wrappers
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
| Image addon | Allegro.Addons.Image | implemented | Init/shutdown, load/save bitmap, load with flags, identify bitmap, version query |
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
