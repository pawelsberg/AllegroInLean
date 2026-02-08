import Allegro.Core.File

/-!
# Allegro 5 Filesystem bindings (`fshook.h`)

Provides access to filesystem entries: create, query metadata (name,
mode, size, timestamps), traverse directories, and manipulate paths.

## File mode flags (`ALLEGRO_FILEMODE`)
- `fileModeRead`    (1)  — readable
- `fileModeWrite`   (2)  — writable
- `fileModeExecute` (4)  — executable
- `fileModeHidden`  (8)  — hidden
- `fileModeIsFile`  (16) — regular file
- `fileModeIsDir`   (32) — directory
-/
namespace Allegro

/-- Opaque handle to an Allegro filesystem entry (`ALLEGRO_FS_ENTRY *`). -/
def FsEntry := UInt64

instance : BEq FsEntry := inferInstanceAs (BEq UInt64)
instance : Inhabited FsEntry := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq FsEntry := inferInstanceAs (DecidableEq UInt64)
instance : OfNat FsEntry 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString FsEntry := ⟨fun (h : UInt64) => s!"FsEntry#{h}"⟩
instance : Repr FsEntry := ⟨fun (h : UInt64) _ => .text s!"FsEntry#{repr h}"⟩

/-- The null filesystem entry handle. -/
def FsEntry.null : FsEntry := (0 : UInt64)

-- ── File mode flags ──

/-- File mode: readable. -/
def fileModeRead    : UInt32 := 1
/-- File mode: writable. -/
def fileModeWrite   : UInt32 := 2
/-- File mode: executable. -/
def fileModeExecute : UInt32 := 4
/-- File mode: hidden. -/
def fileModeHidden  : UInt32 := 8
/-- File mode: regular file. -/
def fileModeIsFile  : UInt32 := 16
/-- File mode: directory. -/
def fileModeIsDir   : UInt32 := 32

-- ── Entry lifecycle ──

/-- Create a filesystem entry for the given path. -/
@[extern "allegro_al_create_fs_entry"]
opaque createFsEntry : String → IO FsEntry

/-- Destroy a filesystem entry. -/
@[extern "allegro_al_destroy_fs_entry"]
opaque destroyFsEntry : FsEntry → IO Unit

-- ── Entry queries ──

/-- Get the full path name of a filesystem entry. -/
@[extern "allegro_al_get_fs_entry_name"]
opaque getFsEntryName : FsEntry → IO String

/-- Refresh the entry's cached stat information. Returns 1 on success. -/
@[extern "allegro_al_update_fs_entry"]
opaque updateFsEntry : FsEntry → IO UInt32

/-- Get the file mode flags (see `AllegroFileMode`). -/
@[extern "allegro_al_get_fs_entry_mode"]
opaque getFsEntryMode : FsEntry → IO UInt32

/-- Get last access time (Unix timestamp). -/
@[extern "allegro_al_get_fs_entry_atime"]
opaque getFsEntryAtime : FsEntry → IO UInt64

/-- Get last modification time (Unix timestamp). -/
@[extern "allegro_al_get_fs_entry_mtime"]
opaque getFsEntryMtime : FsEntry → IO UInt64

/-- Get creation time (Unix timestamp). -/
@[extern "allegro_al_get_fs_entry_ctime"]
opaque getFsEntryCtime : FsEntry → IO UInt64

/-- Get file size in bytes. -/
@[extern "allegro_al_get_fs_entry_size"]
opaque getFsEntrySize : FsEntry → IO UInt64

/-- Check if the entry exists on disk. Returns 1 if it exists. -/
@[extern "allegro_al_fs_entry_exists"]
opaque fsEntryExists : FsEntry → IO UInt32

/-- Remove the file or directory. Returns 1 on success. -/
@[extern "allegro_al_remove_fs_entry"]
opaque removeFsEntry : FsEntry → IO UInt32

-- ── Directory traversal ──

/-- Open a directory for reading its children. Returns 1 on success. -/
@[extern "allegro_al_open_directory"]
opaque openDirectory : FsEntry → IO UInt32

/-- Read the next child entry. Returns `FsEntry.null` (0) when done. -/
@[extern "allegro_al_read_directory"]
opaque readDirectory : FsEntry → IO FsEntry

/-- Close an opened directory. Returns 1 on success. -/
@[extern "allegro_al_close_directory"]
opaque closeDirectory : FsEntry → IO UInt32

-- ── Filename / path utilities ──

/-- Check if a filename exists. Returns 1 if it does. -/
@[extern "allegro_al_filename_exists"]
opaque filenameExists : String → IO UInt32

/-- Remove a file by path. Returns 1 on success. -/
@[extern "allegro_al_remove_filename"]
opaque removeFilename : String → IO UInt32

/-- Get the current working directory. -/
@[extern "allegro_al_get_current_directory"]
opaque getCurrentDirectory : IO String

-- changeDirectory: already bound in Core.Path — re-use that definition.

/-- Create a directory (and parents). Returns 1 on success. -/
@[extern "allegro_al_make_directory"]
opaque makeDirectory : String → IO UInt32

-- ── Open fs entry as file ──

/-- Open a filesystem entry as an `AllegroFile`. -/
@[extern "allegro_al_open_fs_entry"]
opaque openFsEntry : FsEntry → String → IO AllegroFile

-- ── Interface management ──

/-- Reset to the standard filesystem interface. -/
@[extern "allegro_al_set_standard_fs_interface"]
opaque setStandardFsInterface : IO Unit

-- ── Option-returning variants ──

/-- Create a filesystem entry, returning `none` on failure. -/
def createFsEntry? (path : String) : IO (Option FsEntry) := liftOption (createFsEntry path)

/-- Read the next directory child, returning `none` when done. -/
def readDirectory? (dir : FsEntry) : IO (Option FsEntry) := liftOption (readDirectory dir)

-- ── RAII wrapper ──

/-- Create a filesystem entry, run `f`, then destroy it. -/
def withFsEntry (path : String) (f : FsEntry → IO α) : IO α := do
  let e ← createFsEntry path
  try f e finally destroyFsEntry e

/-- Collect all children of a directory into an `Array FsEntry`.
    Caller is responsible for destroying the returned entries. -/
def listDirectory (dirPath : String) : IO (Array FsEntry) := do
  let dir ← createFsEntry dirPath
  let _ ← openDirectory dir
  let mut children := #[]
  let mut cont := true
  while cont do
    let child ← readDirectory dir
    if child == 0 then
      cont := false
    else
      children := children.push child
  let _ ← closeDirectory dir
  destroyFsEntry dir
  return children

end Allegro
