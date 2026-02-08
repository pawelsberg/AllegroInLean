import Allegro.Core.System

/-!
# Allegro 5 File I/O bindings (`file.h`)

Full bindings for Allegro's virtual-file-system abstraction.
Every `*_f` variant across all addons takes an `AllegroFile` handle.

## Seek origins
- `seekSet` (0) — seek from beginning
- `seekCur` (1) — seek from current position
- `seekEnd` (2) — seek from end
-/
namespace Allegro

/-- Opaque handle to an Allegro file (`ALLEGRO_FILE *`). -/
def AllegroFile := UInt64

instance : BEq AllegroFile := inferInstanceAs (BEq UInt64)
instance : Inhabited AllegroFile := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq AllegroFile := inferInstanceAs (DecidableEq UInt64)
instance : OfNat AllegroFile 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString AllegroFile := ⟨fun (h : UInt64) => s!"AllegroFile#{h}"⟩
instance : Repr AllegroFile := ⟨fun (h : UInt64) _ => .text s!"AllegroFile#{repr h}"⟩

/-- The null file handle. -/
def AllegroFile.null : AllegroFile := (0 : UInt64)

-- ── Seek origin constants ──

/-- Seek from beginning of file. -/
def seekSet : UInt32 := 0
/-- Seek from current position. -/
def seekCur : UInt32 := 1
/-- Seek from end of file. -/
def seekEnd : UInt32 := 2

-- ── File open / close ──

/-- Open a file. `mode` is one of `"r"`, `"w"`, `"rb"`, `"wb"`, etc.
    Returns `AllegroFile.null` (0) on failure. -/
@[extern "allegro_al_fopen"]
opaque fopen : String → String → IO AllegroFile

/-- Close an Allegro file. Returns 1 on success, 0 on failure. -/
@[extern "allegro_al_fclose"]
opaque fclose : AllegroFile → IO UInt32

-- ── Read / write ──

/-- Read up to `size` bytes. Returns `(ByteArray × UInt32)` — the data and bytes actually read. -/
@[extern "allegro_al_fread"]
opaque fread : AllegroFile → UInt32 → IO (ByteArray × UInt32)

/-- Write the contents of a `ByteArray`. Returns the number of bytes written. -/
@[extern "allegro_al_fwrite"]
opaque fwrite : AllegroFile → ByteArray → IO UInt32

-- ── Flush / seek / tell / size ──

/-- Flush pending writes. Returns 1 on success, 0 on failure. -/
@[extern "allegro_al_fflush"]
opaque fflush : AllegroFile → IO UInt32

/-- Get current position in the file. -/
@[extern "allegro_al_ftell"]
opaque ftell : AllegroFile → IO UInt64

/-- Seek to a position. `whence` is one of `AllegroSeek.set/cur/end_`.
    Returns 1 on success, 0 on failure. -/
@[extern "allegro_al_fseek"]
opaque fseek : AllegroFile → UInt64 → UInt32 → IO UInt32

/-- Check if end-of-file has been reached. Returns 1 if EOF. -/
@[extern "allegro_al_feof"]
opaque feof : AllegroFile → IO UInt32

/-- Get the error indicator. Returns non-zero on error. -/
@[extern "allegro_al_ferror"]
opaque ferror : AllegroFile → IO UInt32

/-- Get the error message string for the last error. -/
@[extern "allegro_al_ferrmsg"]
opaque ferrmsg : AllegroFile → IO String

/-- Clear the error indicator. -/
@[extern "allegro_al_fclearerr"]
opaque fclearerr : AllegroFile → IO Unit

/-- Get the total size of the file in bytes, or -1 if unknown. -/
@[extern "allegro_al_fsize"]
opaque fsize : AllegroFile → IO UInt64

-- ── Character-level I/O ──

/-- Read one byte. Returns the byte value, or 0xFFFFFFFF on EOF/error. -/
@[extern "allegro_al_fgetc"]
opaque fgetc : AllegroFile → IO UInt32

/-- Write one byte. Returns the byte written, or 0xFFFFFFFF on error. -/
@[extern "allegro_al_fputc"]
opaque fputc : AllegroFile → UInt32 → IO UInt32

/-- Push a byte back into the read stream. -/
@[extern "allegro_al_fungetc"]
opaque fungetc : AllegroFile → UInt32 → IO UInt32

-- ── Endian-aware reads ──

/-- Read a 16-bit little-endian value. -/
@[extern "allegro_al_fread16le"]
opaque fread16le : AllegroFile → IO UInt32

/-- Read a 16-bit big-endian value. -/
@[extern "allegro_al_fread16be"]
opaque fread16be : AllegroFile → IO UInt32

/-- Read a 32-bit little-endian value. -/
@[extern "allegro_al_fread32le"]
opaque fread32le : AllegroFile → IO UInt32

/-- Read a 32-bit big-endian value. -/
@[extern "allegro_al_fread32be"]
opaque fread32be : AllegroFile → IO UInt32

-- ── Endian-aware writes ──

/-- Write a 16-bit little-endian value. Returns bytes written (2 on success). -/
@[extern "allegro_al_fwrite16le"]
opaque fwrite16le : AllegroFile → UInt32 → IO UInt32

/-- Write a 16-bit big-endian value. Returns bytes written (2 on success). -/
@[extern "allegro_al_fwrite16be"]
opaque fwrite16be : AllegroFile → UInt32 → IO UInt32

/-- Write a 32-bit little-endian value. Returns bytes written (4 on success). -/
@[extern "allegro_al_fwrite32le"]
opaque fwrite32le : AllegroFile → UInt32 → IO UInt32

/-- Write a 32-bit big-endian value. Returns bytes written (4 on success). -/
@[extern "allegro_al_fwrite32be"]
opaque fwrite32be : AllegroFile → UInt32 → IO UInt32

-- ── String I/O ──

/-- Read a line of text (up to `max` bytes including NUL). Returns the line or `""` on EOF. -/
@[extern "allegro_al_fgets"]
opaque fgets : AllegroFile → UInt32 → IO String

/-- Read a line of text as a `Ustr` handle. Returns `0` on EOF. -/
@[extern "allegro_al_fget_ustr"]
opaque fgetUstr : AllegroFile → IO UInt64

/-- Write a string to the file. Returns non-negative on success. -/
@[extern "allegro_al_fputs"]
opaque fputs : AllegroFile → String → IO UInt32

-- ── Slices ──

/-- Open a slice (sub-range) of a file. -/
@[extern "allegro_al_fopen_slice"]
opaque fopenSlice : AllegroFile → UInt32 → String → IO AllegroFile

-- ── Temp files ──

/-- Create a temporary file. Returns `(AllegroFile × Path)`. Template uses `XXXXXX` placeholder. -/
@[extern "allegro_al_make_temp_file"]
opaque makeTempFile : String → IO (AllegroFile × UInt64)

-- ── FD-based open ──

/-- Open an Allegro file from a Unix file descriptor. -/
@[extern "allegro_al_fopen_fd"]
opaque fopenFd : UInt32 → String → IO AllegroFile

-- ── Interface management ──

/-- Reset the file interface to the standard (stdio) implementation. -/
@[extern "allegro_al_set_standard_file_interface"]
opaque setStandardFileInterface : IO Unit

/-- Get the user-data pointer associated with a file handle. -/
@[extern "allegro_al_get_file_userdata"]
opaque getFileUserdata : AllegroFile → IO UInt64

-- ── Option-returning variants ──

/-- Open a file, returning `none` on failure. -/
def fopen? (path mode : String) : IO (Option AllegroFile) := liftOption (fopen path mode)

/-- Open a slice, returning `none` on failure. -/
def fopenSlice? (fp : AllegroFile) (size : UInt32) (mode : String) : IO (Option AllegroFile) :=
  liftOption (fopenSlice fp size mode)

/-- Open a file from fd, returning `none` on failure. -/
def fopenFd? (fd : UInt32) (mode : String) : IO (Option AllegroFile) :=
  liftOption (fopenFd fd mode)

-- ── RAII wrapper ──

/-- Open a file, run `f`, then close it. -/
def withAllegroFile (path mode : String) (f : AllegroFile → IO α) : IO α := do
  let file ← fopen path mode
  try f file finally do let _ ← fclose file

end Allegro
