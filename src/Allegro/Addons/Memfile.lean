/-!
# Memfile addon bindings

Provides in-memory file I/O via `al_open_memfile`. The resulting
`ALLEGRO_FILE*` handle can be passed to any Allegro function that accepts
a file handle, enabling loading from memory buffers.

Requires the Allegro memfile addon library (`liballegro_memfile`).

## Quick start
```
-- Assume `bufPtr` is a UInt64 pointer to valid memory and `bufLen` its size.
let f ← Allegro.openMemfile bufPtr bufLen "r"
-- use f with bitmap/audio loading functions that accept ALLEGRO_FILE*
```
-/
namespace Allegro

-- ── Memfile ──

/-- Open a memory buffer as an Allegro file.
    `mem` is a raw pointer (as UInt64), `size` is the buffer length,
    `mode` is a C-style mode string ("r", "w", "rw").
    Returns a file handle (0 on failure).
    **Important:** the caller must ensure the buffer stays alive while the file is in use. -/
@[extern "allegro_al_open_memfile"]
opaque openMemfile : UInt64 → Int64 → String → IO UInt64

/-- Return the version of the memfile addon (packed integer). -/
@[extern "allegro_al_get_allegro_memfile_version"]
opaque getMemfileVersion : IO UInt32

end Allegro
