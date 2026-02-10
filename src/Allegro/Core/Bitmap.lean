import Allegro.Core.System
import Allegro.Core.Blending

/-!
Bitmap creation, format, locking, pixel access, and drawing for Allegro 5.

## Pixel formats
Use format constants directly (pure values, no IO needed):
```
Allegro.setNewBitmapFormat Allegro.PixelFormat.rgba8888
```

## Bitmap flags
Control bitmap type before creation:
```
Allegro.setNewBitmapFlags Allegro.BitmapFlags.memory
```

## Locking
Lock a bitmap for direct pixel access, then unlock:
```
let lr ← Allegro.lockBitmap bmp Allegro.PixelFormat.any Allegro.LockMode.readwrite
-- use putPixel / getPixel while locked --
Allegro.unlockBitmap bmp
```
-/
namespace Allegro

/-- Opaque handle to an Allegro bitmap. -/
def Bitmap := UInt64

instance : BEq Bitmap := inferInstanceAs (BEq UInt64)
instance : Inhabited Bitmap := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Bitmap := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Bitmap 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Bitmap := ⟨fun (h : UInt64) => s!"Bitmap#{h}"⟩
instance : Repr Bitmap := ⟨fun (h : UInt64) _ => .text s!"Bitmap#{repr h}"⟩

/-- The null bitmap handle. -/
def Bitmap.null : Bitmap := (0 : UInt64)

-- ── Pixel format constants ──

/-- Allegro pixel format identifier. -/
structure PixelFormat where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace PixelFormat
/-- Let Allegro choose the best pixel format. -/
def any : PixelFormat := ⟨0⟩
/-- Any format without an alpha channel. -/
def anyNoAlpha : PixelFormat := ⟨1⟩
/-- Any format with an alpha channel. -/
def anyWithAlpha : PixelFormat := ⟨2⟩
/-- Any 15-bit format without alpha. -/
def any15NoAlpha : PixelFormat := ⟨3⟩
/-- Any 16-bit format without alpha. -/
def any16NoAlpha : PixelFormat := ⟨4⟩
/-- Any 16-bit format with alpha. -/
def any16WithAlpha : PixelFormat := ⟨5⟩
/-- Any 24-bit format without alpha. -/
def any24NoAlpha : PixelFormat := ⟨6⟩
/-- Any 32-bit format without alpha. -/
def any32NoAlpha : PixelFormat := ⟨7⟩
/-- Any 32-bit format with alpha. -/
def any32WithAlpha : PixelFormat := ⟨8⟩
/-- 32-bit ARGB (8 bits per channel). -/
def argb8888 : PixelFormat := ⟨9⟩
/-- 32-bit RGBA (8 bits per channel). -/
def rgba8888 : PixelFormat := ⟨10⟩
/-- 16-bit ARGB (4 bits per channel). -/
def argb4444 : PixelFormat := ⟨11⟩
/-- 24-bit RGB (8 bits per channel, no alpha). -/
def rgb888 : PixelFormat := ⟨12⟩
/-- 16-bit RGB (5-6-5 bits). -/
def rgb565 : PixelFormat := ⟨13⟩
/-- 16-bit RGB (5-5-5 bits, 1 unused). -/
def rgb555 : PixelFormat := ⟨14⟩
/-- 16-bit RGBA (5-5-5-1 bits). -/
def rgba5551 : PixelFormat := ⟨15⟩
/-- 16-bit ARGB (1-5-5-5 bits). -/
def argb1555 : PixelFormat := ⟨16⟩
/-- 32-bit ABGR (8 bits per channel). -/
def abgr8888 : PixelFormat := ⟨17⟩
/-- 32-bit xBGR (8 bits per channel, alpha ignored). -/
def xbgr8888 : PixelFormat := ⟨18⟩
/-- 24-bit BGR (8 bits per channel, no alpha). -/
def bgr888 : PixelFormat := ⟨19⟩
/-- 16-bit BGR (5-6-5 bits). -/
def bgr565 : PixelFormat := ⟨20⟩
/-- 16-bit BGR (5-5-5 bits, 1 unused). -/
def bgr555 : PixelFormat := ⟨21⟩
/-- 32-bit RGBx (8 bits per channel, alpha ignored). -/
def rgbx8888 : PixelFormat := ⟨22⟩
/-- 32-bit xRGB (8 bits per channel, alpha ignored). -/
def xrgb8888 : PixelFormat := ⟨23⟩
/-- 128-bit ABGR (32-bit float per channel). -/
def abgrF32 : PixelFormat := ⟨24⟩
end PixelFormat

-- ── Pixel format queries ──

@[extern "allegro_al_get_pixel_size"]
private opaque getPixelSizeRaw : UInt32 → IO UInt32

/-- Bytes per pixel for the given format. -/
@[inline] def getPixelSize (fmt : PixelFormat) : IO UInt32 :=
  getPixelSizeRaw fmt.val

@[extern "allegro_al_get_pixel_format_bits"]
private opaque getPixelFormatBitsRaw : UInt32 → IO UInt32

/-- Bits per pixel for the given format. -/
@[inline] def getPixelFormatBits (fmt : PixelFormat) : IO UInt32 :=
  getPixelFormatBitsRaw fmt.val

@[extern "allegro_al_get_pixel_block_size"]
private opaque getPixelBlockSizeRaw : UInt32 → IO UInt32

/-- Block size in bytes for compressed formats (1 for uncompressed). -/
@[inline] def getPixelBlockSize (fmt : PixelFormat) : IO UInt32 :=
  getPixelBlockSizeRaw fmt.val

@[extern "allegro_al_get_pixel_block_width"]
private opaque getPixelBlockWidthRaw : UInt32 → IO UInt32

/-- Block width for compressed formats (1 for uncompressed). -/
@[inline] def getPixelBlockWidth (fmt : PixelFormat) : IO UInt32 :=
  getPixelBlockWidthRaw fmt.val

@[extern "allegro_al_get_pixel_block_height"]
private opaque getPixelBlockHeightRaw : UInt32 → IO UInt32

/-- Block height for compressed formats (1 for uncompressed). -/
@[inline] def getPixelBlockHeight (fmt : PixelFormat) : IO UInt32 :=
  getPixelBlockHeightRaw fmt.val

-- ── Bitmap flag constants ──

/-- Allegro bitmap creation flags (bitfield). -/
structure BitmapFlags where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

instance : OrOp BitmapFlags where or a b := ⟨a.val ||| b.val⟩
instance : AndOp BitmapFlags where and a b := ⟨a.val &&& b.val⟩

namespace BitmapFlags
/-- No special flags (default). -/
def none : BitmapFlags := ⟨0⟩
/-- Create the bitmap in system memory (not GPU). -/
def memory : BitmapFlags := ⟨1⟩
/-- Create the bitmap in video (GPU) memory. -/
def video : BitmapFlags := ⟨1024⟩
/-- Force pixel format conversion on creation. -/
def convert : BitmapFlags := ⟨4096⟩
/-- Do not preserve texture when the display is lost. -/
def noPreserveTexture : BitmapFlags := ⟨8⟩
/-- Use linear filtering for minification. -/
def minLinear : BitmapFlags := ⟨64⟩
/-- Use linear filtering for magnification. -/
def magLinear : BitmapFlags := ⟨128⟩
/-- Generate mipmaps for the bitmap. -/
def mipmap : BitmapFlags := ⟨256⟩
/-- Do not premultiply alpha on load. -/
def noPremultipliedAlpha : BitmapFlags := ⟨512⟩
end BitmapFlags

-- FlipFlags is defined in Blending.lean (imported above) so both
-- Bitmap.lean and Blending.lean can use it.

-- ── Lock mode constants ──

/-- Allegro bitmap lock mode. -/
structure LockMode where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace LockMode
/-- Lock for both reading and writing. -/
def readwrite : LockMode := ⟨0⟩
/-- Lock for reading only. -/
def readonly : LockMode := ⟨1⟩
/-- Lock for writing only (may discard existing content). -/
def writeonly : LockMode := ⟨2⟩
end LockMode

-- ── Bitmap creation / new-bitmap setup ──

@[extern "allegro_al_set_new_bitmap_flags"]
private opaque setNewBitmapFlagsRaw : UInt32 → IO Unit

/-- Set flags for the next bitmap to be created. -/
@[inline] def setNewBitmapFlags (flags : BitmapFlags) : IO Unit :=
  setNewBitmapFlagsRaw flags.val

@[extern "allegro_al_get_new_bitmap_flags"]
private opaque getNewBitmapFlagsRaw : IO UInt32

/-- Get the flags that will be used for the next bitmap creation. -/
@[inline] def getNewBitmapFlags : IO BitmapFlags := do
  let v ← getNewBitmapFlagsRaw
  return ⟨v⟩

@[extern "allegro_al_add_new_bitmap_flag"]
private opaque addNewBitmapFlagRaw : UInt32 → IO Unit

/-- Add a flag to the current new-bitmap flags (bitwise OR). -/
@[inline] def addNewBitmapFlag (flag : BitmapFlags) : IO Unit :=
  addNewBitmapFlagRaw flag.val

@[extern "allegro_al_set_new_bitmap_format"]
private opaque setNewBitmapFormatRaw : UInt32 → IO Unit

/-- Set the pixel format for the next bitmap to be created. -/
@[inline] def setNewBitmapFormat (fmt : PixelFormat) : IO Unit :=
  setNewBitmapFormatRaw fmt.val

@[extern "allegro_al_get_new_bitmap_format"]
private opaque getNewBitmapFormatRaw : IO UInt32

/-- Get the pixel format that will be used for the next bitmap creation. -/
@[inline] def getNewBitmapFormat : IO PixelFormat := do
  let v ← getNewBitmapFormatRaw
  return ⟨v⟩

/-- Create a new bitmap with the given width and height. Returns null on failure. -/
@[extern "allegro_al_create_bitmap"]
opaque createBitmap : UInt32 → UInt32 → IO UInt64

/-- Create an independent copy of a bitmap. Returns null on failure. -/
@[extern "allegro_al_clone_bitmap"]
opaque cloneBitmap : UInt64 → IO UInt64

/-- Create a sub-bitmap that shares pixel data with a parent bitmap. -/
@[extern "allegro_al_create_sub_bitmap"]
opaque createSubBitmap : UInt64 → Int32 → Int32 → Int32 → Int32 → IO UInt64

/-- Destroy a bitmap and free its resources. -/
@[extern "allegro_al_destroy_bitmap"]
opaque destroyBitmap : UInt64 → IO Unit

/-- Convert a bitmap to the current new-bitmap format and flags. -/
@[extern "allegro_al_convert_bitmap"]
opaque convertBitmap : UInt64 → IO Unit

/-- Convert all memory bitmaps to video bitmaps for the current display. -/
@[extern "allegro_al_convert_memory_bitmaps"]
opaque convertMemoryBitmaps : IO Unit

-- ── Bitmap queries ──

/-- Get the width of a bitmap in pixels. -/
@[extern "allegro_al_get_bitmap_width"]
opaque getBitmapWidth : UInt64 → IO UInt32

/-- Get the height of a bitmap in pixels. -/
@[extern "allegro_al_get_bitmap_height"]
opaque getBitmapHeight : UInt64 → IO UInt32

@[extern "allegro_al_get_bitmap_flags"]
private opaque getBitmapFlagsRaw : UInt64 → IO UInt32

/-- Get the creation flags of a bitmap. -/
@[inline] def getBitmapFlags (bmp : UInt64) : IO BitmapFlags := do
  let v ← getBitmapFlagsRaw bmp
  return ⟨v⟩

@[extern "allegro_al_get_bitmap_format"]
private opaque getBitmapFormatRaw : UInt64 → IO UInt32

/-- Get the pixel format of a bitmap. -/
@[inline] def getBitmapFormat (bmp : UInt64) : IO PixelFormat := do
  let v ← getBitmapFormatRaw bmp
  return ⟨v⟩

/-- Check whether a bitmap is a sub-bitmap. Returns 1 if yes. -/
@[extern "allegro_al_is_sub_bitmap"]
opaque isSubBitmap : UInt64 → IO UInt32

/-- Get the parent bitmap of a sub-bitmap (null if not a sub-bitmap). -/
@[extern "allegro_al_get_parent_bitmap"]
opaque getParentBitmap : UInt64 → IO UInt64

/-- Change the parent and region of a sub-bitmap. -/
@[extern "allegro_al_reparent_bitmap"]
opaque reparentBitmap : UInt64 → UInt64 → Int32 → Int32 → Int32 → Int32 → IO Unit

/-- Check whether a bitmap is currently locked. Returns 1 if locked. -/
@[extern "allegro_al_is_bitmap_locked"]
opaque isBitmapLocked : UInt64 → IO UInt32

-- ── Target bitmap ──

/-- Set the bitmap that drawing operations will target. -/
@[extern "allegro_al_set_target_bitmap"]
opaque setTargetBitmap : UInt64 → IO Unit

/-- Get the current target bitmap. -/
@[extern "allegro_al_get_target_bitmap"]
opaque getTargetBitmap : IO UInt64

-- ── Bitmap locking ──

/-- Opaque handle to a locked bitmap region. -/
def LockedRegion := UInt64

instance : BEq LockedRegion := inferInstanceAs (BEq UInt64)
instance : Inhabited LockedRegion := inferInstanceAs (Inhabited UInt64)
instance : OfNat LockedRegion 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString LockedRegion := ⟨fun (h : UInt64) => s!"LockedRegion#{h}"⟩
instance : Repr LockedRegion := ⟨fun (h : UInt64) _ => .text s!"LockedRegion#{repr h}"⟩

@[extern "allegro_al_lock_bitmap"]
private opaque lockBitmapRaw : UInt64 → UInt32 → UInt32 → IO LockedRegion

/-- Lock entire bitmap. Returns a LockedRegion handle (0 on failure). -/
@[inline] def lockBitmap (bmp : UInt64) (fmt : PixelFormat) (mode : LockMode) : IO LockedRegion :=
  lockBitmapRaw bmp fmt.val mode.val

@[extern "allegro_al_lock_bitmap_region"]
private opaque lockBitmapRegionRaw : UInt64 → Int32 → Int32 → Int32 → Int32 → UInt32 → UInt32 → IO LockedRegion

/-- Lock a rectangular region. Returns a LockedRegion handle (0 on failure). -/
@[inline] def lockBitmapRegion (bmp : UInt64) (x y w h : Int32) (fmt : PixelFormat) (mode : LockMode) : IO LockedRegion :=
  lockBitmapRegionRaw bmp x y w h fmt.val mode.val

/-- Unlock a locked bitmap. -/
@[extern "allegro_al_unlock_bitmap"]
opaque unlockBitmap : UInt64 → IO Unit

@[extern "allegro_al_locked_region_get_format"]
private opaque lockedRegionGetFormatRaw : LockedRegion → IO UInt32

/-- Get the pixel format of a locked region. -/
@[inline] def lockedRegionGetFormat (lr : LockedRegion) : IO PixelFormat := do
  let v ← lockedRegionGetFormatRaw lr
  return ⟨v⟩

/-- Get the pitch (bytes per row, may be negative) of a locked region. -/
@[extern "allegro_al_locked_region_get_pitch"]
opaque lockedRegionGetPitch : LockedRegion → IO UInt32

/-- Get the pixel size in bytes of a locked region. -/
@[extern "allegro_al_locked_region_get_pixel_size"]
opaque lockedRegionGetPixelSize : LockedRegion → IO UInt32

/-- Get the raw data pointer of a locked region (as UInt64). -/
@[extern "allegro_al_locked_region_get_data"]
opaque lockedRegionGetData : LockedRegion → IO UInt64

-- ── Pixel get / put ──

/-- Clear the target bitmap to an RGB colour. -/
@[extern "allegro_al_clear_to_color_rgb"]
opaque clearToColorRgb : UInt32 → UInt32 → UInt32 → IO Unit

/-- Draw a single pixel at (x, y) with an RGB colour using the current blender. -/
@[extern "allegro_al_draw_pixel_rgb"]
opaque drawPixelRgb : Float → Float → UInt32 → UInt32 → UInt32 → IO Unit

/-- Get all four pixel components (r, g, b, a) in one call. -/
@[extern "allegro_al_get_pixel_rgba"]
opaque getPixelRgba : UInt64 → Int32 → Int32 → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Write a pixel (RGB, alpha=255) at the given coords on the target bitmap. -/
@[extern "allegro_al_put_pixel"]
opaque putPixel : Int32 → Int32 → UInt32 → UInt32 → UInt32 → IO Unit

/-- Write a pixel (RGBA) at the given coords on the target bitmap. -/
@[extern "allegro_al_put_pixel_rgba"]
opaque putPixelRgba : Int32 → Int32 → UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

/-- Write a pixel using the current blender. -/
@[extern "allegro_al_put_blended_pixel"]
opaque putBlendedPixel : Int32 → Int32 → UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Bitmap drawing ──

@[extern "allegro_al_draw_bitmap"]
private opaque drawBitmapRaw : UInt64 → Float → Float → UInt32 → IO Unit

/-- Draw a bitmap at position (dx, dy) with the given flip flags. -/
@[inline] def drawBitmap (bmp : UInt64) (dx dy : Float) (flags : FlipFlags) : IO Unit :=
  drawBitmapRaw bmp dx dy flags.val

@[extern "allegro_al_draw_scaled_bitmap"]
private opaque drawScaledBitmapRaw : UInt64 → Float → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a scaled bitmap.
    `drawScaledBitmap bmp sx sy sw sh dx dy dw dh flags` -/
@[inline] def drawScaledBitmap (bmp : UInt64) (sx sy sw sh dx dy dw dh : Float) (flags : FlipFlags) : IO Unit :=
  drawScaledBitmapRaw bmp sx sy sw sh dx dy dw dh flags.val

@[extern "allegro_al_draw_bitmap_region"]
private opaque drawBitmapRegionRaw : UInt64 → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a region of a bitmap.
    `drawBitmapRegion bmp sx sy sw sh dx dy flags` -/
@[inline] def drawBitmapRegion (bmp : UInt64) (sx sy sw sh dx dy : Float) (flags : FlipFlags) : IO Unit :=
  drawBitmapRegionRaw bmp sx sy sw sh dx dy flags.val

@[extern "allegro_al_draw_rotated_bitmap"]
private opaque drawRotatedBitmapRaw : UInt64 → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a bitmap with rotation.
    `drawRotatedBitmap bmp cx cy dx dy angle flags` -/
@[inline] def drawRotatedBitmap (bmp : UInt64) (cx cy dx dy angle : Float) (flags : FlipFlags) : IO Unit :=
  drawRotatedBitmapRaw bmp cx cy dx dy angle flags.val

@[extern "allegro_al_draw_scaled_rotated_bitmap"]
private opaque drawScaledRotatedBitmapRaw : UInt64 → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a bitmap with scaling and rotation.
    `drawScaledRotatedBitmap bmp cx cy dx dy xscale yscale angle flags` -/
@[inline] def drawScaledRotatedBitmap (bmp : UInt64) (cx cy dx dy xscale yscale angle : Float) (flags : FlipFlags) : IO Unit :=
  drawScaledRotatedBitmapRaw bmp cx cy dx dy xscale yscale angle flags.val

@[extern "allegro_al_draw_tinted_bitmap_rgb"]
private opaque drawTintedBitmapRgbRaw : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → UInt32 → IO Unit

/-- Draw a bitmap tinted with an RGB colour.
    `drawTintedBitmapRgb bmp r g b dx dy flags` -/
@[inline] def drawTintedBitmapRgb (bmp : UInt64) (r g b : UInt32) (dx dy : Float) (flags : FlipFlags) : IO Unit :=
  drawTintedBitmapRgbRaw bmp r g b dx dy flags.val

@[extern "allegro_al_draw_tinted_scaled_bitmap_rgb"]
private opaque drawTintedScaledBitmapRgbRaw : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a tinted, scaled bitmap.
    `drawTintedScaledBitmapRgb bmp r g b sx sy sw sh dx dy dw dh flags` -/
@[inline] def drawTintedScaledBitmapRgb (bmp : UInt64) (r g b : UInt32) (sx sy sw sh dx dy dw dh : Float) (flags : FlipFlags) : IO Unit :=
  drawTintedScaledBitmapRgbRaw bmp r g b sx sy sw sh dx dy dw dh flags.val

@[extern "allegro_al_draw_tinted_rotated_bitmap_rgb"]
private opaque drawTintedRotatedBitmapRgbRaw : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a tinted, rotated bitmap.
    `drawTintedRotatedBitmapRgb bmp r g b cx cy dx dy angle flags` -/
@[inline] def drawTintedRotatedBitmapRgb (bmp : UInt64) (r g b : UInt32) (cx cy dx dy angle : Float) (flags : FlipFlags) : IO Unit :=
  drawTintedRotatedBitmapRgbRaw bmp r g b cx cy dx dy angle flags.val

-- ── Depth / samples / wrap ──

/-- Get the depth buffer bit count for newly created bitmaps. -/
@[extern "allegro_al_get_new_bitmap_depth"]
opaque getNewBitmapDepth : IO UInt32

/-- Set the depth buffer bit count for newly created bitmaps. -/
@[extern "allegro_al_set_new_bitmap_depth"]
opaque setNewBitmapDepth : UInt32 → IO Unit

/-- Get the multisample count for newly created bitmaps. -/
@[extern "allegro_al_get_new_bitmap_samples"]
opaque getNewBitmapSamples : IO UInt32

/-- Set the multisample count for newly created bitmaps. -/
@[extern "allegro_al_set_new_bitmap_samples"]
opaque setNewBitmapSamples : UInt32 → IO Unit

-- ── Bitmap wrap mode constants ──

/-- Allegro texture wrap mode. -/
structure BitmapWrapMode where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace BitmapWrapMode
/-- Wrap mode: use the default (usually clamp). -/
def default : BitmapWrapMode := ⟨0⟩
/-- Wrap mode: repeat the texture. -/
def «repeat» : BitmapWrapMode := ⟨1⟩
/-- Wrap mode: clamp to edge. -/
def clamp : BitmapWrapMode := ⟨2⟩
/-- Wrap mode: mirror the texture. -/
def mirror : BitmapWrapMode := ⟨3⟩
end BitmapWrapMode

@[extern "allegro_al_get_new_bitmap_wrap"]
private opaque getNewBitmapWrapRaw : IO (UInt32 × UInt32)

/-- Get the texture wrap mode (u, v) for newly created bitmaps. -/
@[inline] def getNewBitmapWrap : IO (BitmapWrapMode × BitmapWrapMode) := do
  let (u, v) ← getNewBitmapWrapRaw
  return (⟨u⟩, ⟨v⟩)

@[extern "allegro_al_set_new_bitmap_wrap"]
private opaque setNewBitmapWrapRaw : UInt32 → UInt32 → IO Unit

/-- Set the texture wrap mode (u, v) for newly created bitmaps. -/
@[inline] def setNewBitmapWrap (u v : BitmapWrapMode) : IO Unit :=
  setNewBitmapWrapRaw u.val v.val

/-- Get the depth buffer bit count of a bitmap. -/
@[extern "allegro_al_get_bitmap_depth"]
opaque getBitmapDepth : UInt64 → IO UInt32

/-- Get the multisample count of a bitmap. -/
@[extern "allegro_al_get_bitmap_samples"]
opaque getBitmapSamples : UInt64 → IO UInt32

-- ── Sub-bitmap position ──

/-- Get the X offset of a sub-bitmap within its parent. -/
@[extern "allegro_al_get_bitmap_x"]
opaque getBitmapX : UInt64 → IO UInt32

/-- Get the Y offset of a sub-bitmap within its parent. -/
@[extern "allegro_al_get_bitmap_y"]
opaque getBitmapY : UInt64 → IO UInt32

-- ── Mask to alpha ──

/-- Convert pixels matching the mask colour (RGB) to transparent (alpha = 0). -/
@[extern "allegro_al_convert_mask_to_alpha"]
opaque convertMaskToAlpha : UInt64 → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Per-bitmap blender ──

/-- Get the per-bitmap blender as `(op, src, dst)`. -/
@[extern "allegro_al_get_bitmap_blender"]
opaque getBitmapBlender : IO (BlendOp × BlendFactor × BlendFactor)

/-- Set the per-bitmap blender.
    `setBitmapBlender op src dst` -/
@[extern "allegro_al_set_bitmap_blender"]
opaque setBitmapBlender : BlendOp → BlendFactor → BlendFactor → IO Unit

/-- Get the per-bitmap separate blender as `(op, src, dst, alphaOp, alphaSrc, alphaDst)`. -/
@[extern "allegro_al_get_separate_bitmap_blender"]
opaque getSeparateBitmapBlender : IO (BlendOp × BlendFactor × BlendFactor × BlendOp × BlendFactor × BlendFactor)

/-- Set the per-bitmap separate blender.
    `setSeparateBitmapBlender op src dst alphaOp alphaSrc alphaDst` -/
@[extern "allegro_al_set_separate_bitmap_blender"]
opaque setSeparateBitmapBlender : BlendOp → BlendFactor → BlendFactor → BlendOp → BlendFactor → BlendFactor → IO Unit

/-- Get the per-bitmap blend colour as `(r, g, b, a)` with components in 0.0…1.0. -/
@[extern "allegro_al_get_bitmap_blend_color"]
opaque getBitmapBlendColor : IO (Float × Float × Float × Float)

/-- Set the per-bitmap blend colour.
    `setBitmapBlendColor r g b a` where each component is in 0.0…1.0. -/
@[extern "allegro_al_set_bitmap_blend_color"]
opaque setBitmapBlendColor : Float → Float → Float → Float → IO Unit

/-- Reset the per-bitmap blender to default (use the target bitmap's blender). -/
@[extern "allegro_al_reset_bitmap_blender"]
opaque resetBitmapBlender : IO Unit

-- ── Tinted drawing (remaining) ──

@[extern "allegro_al_draw_tinted_bitmap_region_rgb"]
private opaque drawTintedBitmapRegionRgbRaw : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a tinted region of a bitmap.
    `drawTintedBitmapRegionRgb bmp r g b sx sy sw sh dx dy flags` -/
@[inline] def drawTintedBitmapRegionRgb (bmp : UInt64) (r g b : UInt32) (sx sy sw sh dx dy : Float) (flags : FlipFlags) : IO Unit :=
  drawTintedBitmapRegionRgbRaw bmp r g b sx sy sw sh dx dy flags.val

@[extern "allegro_al_draw_tinted_scaled_rotated_bitmap_rgb"]
private opaque drawTintedScaledRotatedBitmapRgbRaw : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a tinted, scaled, rotated bitmap.
    `drawTintedScaledRotatedBitmapRgb bmp r g b cx cy dx dy xscale yscale angle flags` -/
@[inline] def drawTintedScaledRotatedBitmapRgb (bmp : UInt64) (r g b : UInt32) (cx cy dx dy xscale yscale angle : Float) (flags : FlipFlags) : IO Unit :=
  drawTintedScaledRotatedBitmapRgbRaw bmp r g b cx cy dx dy xscale yscale angle flags.val

@[extern "allegro_al_draw_tinted_scaled_rotated_bitmap_region_rgb"]
private opaque drawTintedScaledRotatedBitmapRegionRgbRaw : UInt64 → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a tinted, scaled, rotated region of a bitmap.
    `drawTintedScaledRotatedBitmapRegionRgb bmp sx sy sw sh r g b cx cy dx dy xscale yscale angle flags` -/
@[inline] def drawTintedScaledRotatedBitmapRegionRgb (bmp : UInt64) (sx sy sw sh : Float) (r g b : UInt32) (cx cy dx dy xscale yscale angle : Float) (flags : FlipFlags) : IO Unit :=
  drawTintedScaledRotatedBitmapRegionRgbRaw bmp sx sy sw sh r g b cx cy dx dy xscale yscale angle flags.val

-- ── Block-aligned locking ──

@[extern "allegro_al_lock_bitmap_blocked"]
private opaque lockBitmapBlockedRaw : UInt64 → UInt32 → IO LockedRegion

/-- Lock a bitmap using block-aligned access. Returns a LockedRegion handle (0 on failure). -/
@[inline] def lockBitmapBlocked (bmp : UInt64) (mode : LockMode) : IO LockedRegion :=
  lockBitmapBlockedRaw bmp mode.val

@[extern "allegro_al_lock_bitmap_region_blocked"]
private opaque lockBitmapRegionBlockedRaw : UInt64 → Int32 → Int32 → Int32 → Int32 → UInt32 → IO LockedRegion

/-- Lock a block-aligned region of a bitmap. Returns a LockedRegion handle (0 on failure).
    `lockBitmapRegionBlocked bmp xBlock yBlock wBlock hBlock flags` -/
@[inline] def lockBitmapRegionBlocked (bmp : UInt64) (xBlock yBlock wBlock hBlock : Int32) (mode : LockMode) : IO LockedRegion :=
  lockBitmapRegionBlockedRaw bmp xBlock yBlock wBlock hBlock mode.val

/-- Back up the contents of a single dirty bitmap.
    Useful before switching display contexts. -/
@[extern "allegro_al_backup_dirty_bitmap"]
opaque backupDirtyBitmap : Bitmap → IO Unit

-- ── Option-returning variants ──

/-- Create a bitmap, returning `none` on failure (OOM, invalid size, etc.). -/
def createBitmap? (w h : UInt32) : IO (Option Bitmap) := liftOption (createBitmap w h)

/-- Clone a bitmap, returning `none` on failure. -/
def cloneBitmap? (bmp : Bitmap) : IO (Option Bitmap) := liftOption (cloneBitmap bmp)

/-- Create a sub-bitmap, returning `none` on failure. -/
def createSubBitmap? (parent : Bitmap) (x y w h : Int32) : IO (Option Bitmap) :=
  liftOption (createSubBitmap parent x y w h)

/-- Lock a bitmap for direct pixel access, returning `none` on failure. -/
def lockBitmap? (bmp : Bitmap) (format : PixelFormat) (mode : LockMode) : IO (Option LockedRegion) :=
  liftOption (lockBitmap bmp format mode)

/-- Lock a bitmap region, returning `none` on failure. -/
def lockBitmapRegion? (bmp : Bitmap) (x y w h : Int32) (format : PixelFormat) (mode : LockMode) : IO (Option LockedRegion) :=
  liftOption (lockBitmapRegion bmp x y w h format mode)

/-- Lock a bitmap with block-aligned access, returning `none` on failure. -/
def lockBitmapBlocked? (bmp : Bitmap) (mode : LockMode) : IO (Option LockedRegion) :=
  liftOption (lockBitmapBlocked bmp mode)

/-- Lock a block-aligned bitmap region, returning `none` on failure. -/
def lockBitmapRegionBlocked? (bmp : Bitmap) (x y w h : Int32) (mode : LockMode) : IO (Option LockedRegion) :=
  liftOption (lockBitmapRegionBlocked bmp x y w h mode)

end Allegro
