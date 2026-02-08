import Allegro.Core.System

/-!
Filesystem path helpers.

Create, clone, and inspect Allegro path objects.
-/
namespace Allegro

/-- Opaque handle to an Allegro path. -/
def Path := UInt64

instance : BEq Path := inferInstanceAs (BEq UInt64)
instance : Inhabited Path := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Path := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Path 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Path := ⟨fun (h : UInt64) => s!"Path#{h}"⟩
instance : Repr Path := ⟨fun (h : UInt64) _ => .text s!"Path#{repr h}"⟩

/-- The null path handle. -/
def Path.null : Path := (0 : UInt64)

/-- Return the `ALLEGRO_RESOURCES_PATH` constant for use with `getStandardPath`. -/
@[extern "allegro_al_standard_path_resources"]
opaque standardPathResources : IO UInt32

/-- Parse a path string into an Allegro path object. -/
@[extern "allegro_al_create_path"]
opaque createPath : String -> IO Path

/-- Create an independent copy of a path. -/
@[extern "allegro_al_clone_path"]
opaque clonePath : Path -> IO Path

/-- Simplify the path by resolving `.` and `..` components. Returns 1 on success. -/
@[extern "allegro_al_make_path_canonical"]
opaque makePathCanonical : Path -> IO UInt32

/-- Get a platform-specific standard path (resources, user data, etc.). -/
@[extern "allegro_al_get_standard_path"]
opaque getStandardPath : UInt32 -> IO Path

/-- Append a directory component to the path. -/
@[extern "allegro_al_append_path_component"]
opaque appendPathComponent : Path -> String -> IO Unit

/-- Convert the path to a string using the given separator (e.g. `'/'`). -/
@[extern "allegro_al_path_cstr"]
opaque pathCstr : Path -> UInt32 -> IO String

/-- Get the drive letter (Windows) or empty string (Unix). -/
@[extern "allegro_al_get_path_drive"]
opaque getPathDrive : Path -> IO String

/-- Get the filename component of the path. -/
@[extern "allegro_al_get_path_filename"]
opaque getPathFilename : Path -> IO String

/-- Get the number of directory components in the path. -/
@[extern "allegro_al_get_path_num_components"]
opaque getPathNumComponents : Path -> IO UInt32

/-- Get the directory component at the given index. -/
@[extern "allegro_al_get_path_component"]
opaque getPathComponent : Path -> UInt32 -> IO String

/-- Change the current working directory. Returns 1 on success. -/
@[extern "allegro_al_change_directory"]
opaque changeDirectory : String -> IO UInt32

/-- Destroy a path and free its resources. -/
@[extern "allegro_al_destroy_path"]
opaque destroyPath : Path -> IO Unit

/-- Create a path for a directory (ensures trailing separator). -/
@[extern "allegro_al_create_path_for_directory"]
opaque createPathForDirectory : String → IO Path

/-- Insert a directory component at the given index. -/
@[extern "allegro_al_insert_path_component"]
opaque insertPathComponent : Path → UInt32 → String → IO Unit

/-- Remove the directory component at the given index. -/
@[extern "allegro_al_remove_path_component"]
opaque removePathComponent : Path → UInt32 → IO Unit

/-- Replace the directory component at the given index. -/
@[extern "allegro_al_replace_path_component"]
opaque replacePathComponent : Path → UInt32 → String → IO Unit

/-- Get the last directory component of the path. -/
@[extern "allegro_al_get_path_tail"]
opaque getPathTail : Path → IO String

/-- Remove the last directory component from the path. -/
@[extern "allegro_al_drop_path_tail"]
opaque dropPathTail : Path → IO Unit

/-- Join two paths: append `tail`’s directory components to `path`. Returns 1 on success. -/
@[extern "allegro_al_join_paths"]
opaque joinPaths : Path → Path → IO UInt32

/-- Make a relative path (`tail`) absolute using `head` as base. Returns 1 on success. -/
@[extern "allegro_al_rebase_path"]
opaque rebasePath : Path → Path → IO UInt32

/-- Set the drive letter / root of the path (Windows). -/
@[extern "allegro_al_set_path_drive"]
opaque setPathDrive : Path → String → IO Unit

/-- Set the filename part of the path. -/
@[extern "allegro_al_set_path_filename"]
opaque setPathFilename : Path → String → IO Unit

/-- Get the file extension (e.g. ".png"). -/
@[extern "allegro_al_get_path_extension"]
opaque getPathExtension : Path → IO String

/-- Set the file extension. Returns 1 on success. -/
@[extern "allegro_al_set_path_extension"]
opaque setPathExtension : Path → String → IO UInt32

/-- Get the filename without the extension. -/
@[extern "allegro_al_get_path_basename"]
opaque getPathBasename : Path → IO String

/-- Get the path as an `ALLEGRO_USTR` handle (owned by the path — do not destroy).
    `delim` is the separator character (e.g. `'/'`). -/
@[extern "allegro_al_path_ustr"]
opaque pathUstr : Path → UInt32 → IO UInt64

-- ── Option-returning variants ──

/-- Get a standard (platform-specific) path, returning `none` if not available. -/
def getStandardPath? (pathId : UInt32) : IO (Option Path) := liftOption (getStandardPath pathId)

end Allegro
