import Allegro.Core.Bitmap
import Allegro.Core.System

/-!
# Image addon bindings

Provides bitmap loading/saving in various image formats (PNG, BMP, JPG, etc.).
The image addon must be initialised before loading bitmaps from files.
Drawing and lifecycle functions are in `Allegro.Core.Bitmap`.

## Typical usage
```
let _ ← Allegro.initImageAddon
let bmp ← Allegro.loadBitmap "sprite.png"
-- use drawBitmap etc. from Core.Bitmap --
Allegro.destroyBitmap bmp
Allegro.shutdownImageAddon
```
-/
namespace Allegro

/-- Initialise the image addon (required before loading bitmaps from files). -/
@[extern "allegro_al_init_image_addon"]
opaque initImageAddon : IO UInt32

/-- Shut down the image addon. -/
@[extern "allegro_al_shutdown_image_addon"]
opaque shutdownImageAddon : IO Unit

/-- Returns true (1) if the image addon is initialised. -/
@[extern "allegro_al_is_image_addon_initialized"]
opaque isImageAddonInitialized : IO UInt32

/-- Load a bitmap from an image file. Returns null on failure. -/
@[extern "allegro_al_load_bitmap"]
opaque loadBitmap : String → IO Bitmap

/-- Save a bitmap to a file. Returns 1 on success. -/
@[extern "allegro_al_save_bitmap"]
opaque saveBitmap : String → Bitmap → IO UInt32

/-- Load a bitmap from file with flags (e.g. `memoryBitmapFlag`). Returns 0 on failure. -/
@[extern "allegro_al_load_bitmap_flags"]
opaque loadBitmapFlags : String → UInt32 → IO Bitmap

-- ── Option-returning variants ──

/-- Load a bitmap from file, returning `none` on failure (file not found, decode error). -/
def loadBitmap? (filename : String) : IO (Option Bitmap) := liftOption (loadBitmap filename)

/-- Load a bitmap from file with flags, returning `none` on failure. -/
def loadBitmapFlags? (filename : String) (flags : UInt32) : IO (Option Bitmap) :=
  liftOption (loadBitmapFlags filename flags)

-- ── Identification ──

/-- Identify a bitmap file by its contents, returning a format string
    (e.g. ".png", ".bmp") or "" if unrecognised. -/
@[extern "allegro_al_identify_bitmap"]
opaque identifyBitmap : String → IO String

-- ── Version ──

/-- Return the version of the image addon (packed integer). -/
@[extern "allegro_al_get_image_version"]
opaque getImageVersion : IO UInt32

end Allegro
