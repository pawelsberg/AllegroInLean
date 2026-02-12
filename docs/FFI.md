# FFI Notes

The C shim returns Lean `IO` results and normalizes pointer handles as `UInt64`.

Guidelines:
- Always check for `0` handles before use.
- Use the corresponding `destroy*` functions to free native resources.
- Keep wrappers minimal; policy should live in Lean.

## Handle model

- All native Allegro pointers are represented as `UInt64` handles in Lean.
- A handle value of `0` means “null” or “failure.”
- Treat handles as opaque; never perform arithmetic or bit operations on them.

### Handle types (42 total, by module)

- `Display` (display windows)
- `Bitmap` (images and render targets)
- `EventQueue`, `EventSource`, `Event` (event system)
- `Timer`, `Timeout` (timing)
- `Path`
- `Ustr`
- `Font`, `TtfFont` (built-in, bitmap, and TTF fonts)
- `Config` (configuration files)
- `Transform` (affine / projection matrices)
- `State` (state save / restore snapshots)
- `Joystick`, `JoystickState`, `KeyboardState`, `MouseState`, `MouseCursor`, `TouchInputState`
- `Sample`, `SampleInstance`, `SampleId`, `AudioStream`, `AudioRecorder`, `Mixer`, `Voice` (audio)
- `Video` (video playback)
- `FileChooser`, `TextLog`, `Menu` (native dialogs)
- `AllegroFile` (file I/O)
- `FsEntry` (filesystem)
- `Haptic`, `HapticEffectId` (force feedback)
- `Shader` (GLSL / HLSL programs)
- `VertexBuffer`, `IndexBuffer`, `VertexDecl` (primitives)
- `LockedRegion` (bitmap locking)
- `Mutex`, `Cond` (threading)

## Ownership and lifetime

Each `create*` or `load*` call transfers ownership to the caller. The caller must
eventually call the matching `destroy*`.

Examples:
- `createDisplay` → `destroyDisplay`
- `createBitmap`/`loadBitmap` → `destroyBitmap`
- `createEventQueue` → `destroyEventQueue`
- `createEvent` → `destroyEvent`
- `createTimer` → `destroyTimer`
- `getStandardPath`/`createPath` → `destroyPath`
- `ustrNew`/`dup` → `ustrFree`
- `createBuiltinFont`/`loadFont`/`loadTtfFont` → `destroyFont`
- `loadSample` → `destroySample`
- `fopen` → `fclose`
- `createFsEntry` → `destroyFsEntry`
- `createShader` → `destroyShader`
- `getHaptic` → `releaseHaptic`

### Borrowed handles

Some functions return handles you **must not** destroy:
- `getCurrentDisplay` (borrowed)
- `getBackbuffer` (borrowed)
- `getDisplayEventSource`, `getTimerEventSource`, `getKeyboardEventSource`, `getMouseEventSource` (borrowed)
- `getTargetBitmap` (borrowed)

If a handle is borrowed, it remains valid only as long as the owning resource is alive.

## Error handling conventions

- Many functions return `UInt32` as success (nonzero) or failure (`0`).
- Prefer explicit checks at the call site and short-circuit early on failure.
- Always check for `0` after `create*`, `load*`, or `getStandardPath`-like functions.

### `al_init` and version checking

`al_init()` is a macro that calls `al_install_system(ALLEGRO_VERSION_INT, NULL)`.
The `ALLEGRO_VERSION_INT` constant is baked into the C shim at compile time from
the Allegro headers. If the headers and runtime library have different versions,
`al_install_system` will reject the version mismatch and return `false`.

This is the most common cause of silent `al_init` failures in consumer projects
that build Allegro locally. Ensure `lake build -K allegroPrefix=…` points to
the same Allegro tree used at runtime.

## Threading and safety

- Treat Allegro as **not** thread-safe unless the underlying Allegro documentation
	explicitly says otherwise.
- Only interact with display/event subsystems from the main thread.
- If adding thread wrappers in Lean, document which functions are safe to call
	from worker threads.

### Known thread-safe functions

The following Allegro functions are documented as safe to call from any thread:

- `al_get_time` / `al_rest` — timing
- `al_get_allegro_version` — version query
- `al_get_cpu_count` / `al_get_ram_size` — hardware info
- `al_get_errno` / `al_set_errno` — per-thread error code
- `al_create_config` / `al_destroy_config` and all config read/write (on separate config objects)
- `al_ustr_new` / `al_ustr_free` and all ustr operations (on separate ustr objects)
- Event queue operations: `al_wait_for_event`, `al_get_next_event`, etc.
  are safe **only** on the queue's owning thread (typically the main thread).

### Lean `Task` / `IO.asTask` interaction

Lean's `IO.asTask` spawns work on a thread pool. **Do not** call any Allegro
display, drawing, or event-loop function from a `Task`. Allegro's OpenGL /
platform backends assume these calls happen on the thread that created the
display.

Safe patterns for background work:
- Use `Task` for pure computation or file I/O, then pass results back to the
  main loop via an `IO.Ref` or `IO.Channel`.
- Keep all Allegro calls on the main thread's `do` block.

## Event ownership rules

- Event queues must outlive event sources registered with them.
- Event objects allocated via `createEvent` must be destroyed by the caller.
- Do not access an event after its queue has been destroyed.
- When an event source is destroyed (e.g. `destroyTimer`, `destroyDisplay`),
  it is automatically unregistered from all queues. However, any events
  already in the queue that originated from that source remain valid — their
  data was copied at enqueue time.
- `registerEventSource` does **not** transfer ownership; both the queue and
  the source must be managed independently.

## Recommended Lean-side patterns

- Wrap `create*`/`destroy*` in `with*`-style helpers for structured cleanup.
- For long-running loops, ensure cleanup occurs on early exit (use `try`/`finally`).
- Consider adding small helpers that return `Option` or `Except` to make failure
	explicit in Lean code.

## FFI extension checklist

When adding new bindings:

1. Add the extern in a module under `src/Allegro/Core` or `src/Allegro/Addons`.
2. Add the C shim entry in `ffi/` and export it (include `allegro_ffi.h`).
3. Update `lakefile.lean` if a new `.c` file is introduced (add to `srcFiles` array).
4. Add a minimal test or example to validate the binding.
