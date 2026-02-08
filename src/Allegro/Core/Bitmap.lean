import Allegro.Core.System

/-!
Bitmap creation, format, locking, pixel access, and drawing for Allegro 5.

## Pixel formats
Use format constants directly (pure values, no IO needed):
```
Allegro.setNewBitmapFormat Allegro.pixelFormatRgba8888
```

## Bitmap flags
Control bitmap type before creation:
```
Allegro.setNewBitmapFlags Allegro.bitmapFlagMemory
```

## Locking
Lock a bitmap for direct pixel access, then unlock:
```
let lr ← Allegro.lockBitmap bmp Allegro.pixelFormatAny Allegro.lockReadwrite
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

/-- Let Allegro choose the best pixel format. -/
def pixelFormatAny : UInt32 := 0
/-- Any format without an alpha channel. -/
def pixelFormatAnyNoAlpha : UInt32 := 1
/-- Any format with an alpha channel. -/
def pixelFormatAnyWithAlpha : UInt32 := 2
/-- Any 15-bit format without alpha. -/
def pixelFormatAny15NoAlpha : UInt32 := 3
/-- Any 16-bit format without alpha. -/
def pixelFormatAny16NoAlpha : UInt32 := 4
/-- Any 16-bit format with alpha. -/
def pixelFormatAny16WithAlpha : UInt32 := 5
/-- Any 24-bit format without alpha. -/
def pixelFormatAny24NoAlpha : UInt32 := 6
/-- Any 32-bit format without alpha. -/
def pixelFormatAny32NoAlpha : UInt32 := 7
/-- Any 32-bit format with alpha. -/
def pixelFormatAny32WithAlpha : UInt32 := 8
/-- 32-bit ARGB (8 bits per channel). -/
def pixelFormatArgb8888 : UInt32 := 9
/-- 32-bit RGBA (8 bits per channel). -/
def pixelFormatRgba8888 : UInt32 := 10
/-- 16-bit ARGB (4 bits per channel). -/
def pixelFormatArgb4444 : UInt32 := 11
/-- 24-bit RGB (8 bits per channel, no alpha). -/
def pixelFormatRgb888 : UInt32 := 12
/-- 16-bit RGB (5-6-5 bits). -/
def pixelFormatRgb565 : UInt32 := 13
/-- 16-bit RGB (5-5-5 bits, 1 unused). -/
def pixelFormatRgb555 : UInt32 := 14
/-- 16-bit RGBA (5-5-5-1 bits). -/
def pixelFormatRgba5551 : UInt32 := 15
/-- 16-bit ARGB (1-5-5-5 bits). -/
def pixelFormatArgb1555 : UInt32 := 16
/-- 32-bit ABGR (8 bits per channel). -/
def pixelFormatAbgr8888 : UInt32 := 17
/-- 32-bit xBGR (8 bits per channel, alpha ignored). -/
def pixelFormatXbgr8888 : UInt32 := 18
/-- 24-bit BGR (8 bits per channel, no alpha). -/
def pixelFormatBgr888 : UInt32 := 19
/-- 16-bit BGR (5-6-5 bits). -/
def pixelFormatBgr565 : UInt32 := 20
/-- 16-bit BGR (5-5-5 bits, 1 unused). -/
def pixelFormatBgr555 : UInt32 := 21
/-- 32-bit RGBx (8 bits per channel, alpha ignored). -/
def pixelFormatRgbx8888 : UInt32 := 22
/-- 32-bit xRGB (8 bits per channel, alpha ignored). -/
def pixelFormatXrgb8888 : UInt32 := 23
/-- 128-bit ABGR (32-bit float per channel). -/
def pixelFormatAbgrF32 : UInt32 := 24

-- ── Pixel format queries ──

/-- Bytes per pixel for the given format. -/
@[extern "allegro_al_get_pixel_size"]
opaque getPixelSize : UInt32 → IO UInt32

/-- Bits per pixel for the given format. -/
@[extern "allegro_al_get_pixel_format_bits"]
opaque getPixelFormatBits : UInt32 → IO UInt32

/-- Block size in bytes for compressed formats (1 for uncompressed). -/
@[extern "allegro_al_get_pixel_block_size"]
opaque getPixelBlockSize : UInt32 → IO UInt32

/-- Block width for compressed formats (1 for uncompressed). -/
@[extern "allegro_al_get_pixel_block_width"]
opaque getPixelBlockWidth : UInt32 → IO UInt32

/-- Block height for compressed formats (1 for uncompressed). -/
@[extern "allegro_al_get_pixel_block_height"]
opaque getPixelBlockHeight : UInt32 → IO UInt32

-- ── Bitmap flag constants ──

/-- Create the bitmap in system memory (not GPU). -/
def bitmapFlagMemory : UInt32 := 1
/-- Create the bitmap in video (GPU) memory. -/
def bitmapFlagVideo : UInt32 := 1024
/-- Force pixel format conversion on creation. -/
def bitmapFlagConvert : UInt32 := 4096
/-- Do not preserve texture when the display is lost. -/
def bitmapFlagNoPreserveTexture : UInt32 := 8
/-- Use linear filtering for minification. -/
def bitmapFlagMinLinear : UInt32 := 64
/-- Use linear filtering for magnification. -/
def bitmapFlagMagLinear : UInt32 := 128
/-- Generate mipmaps for the bitmap. -/
def bitmapFlagMipmap : UInt32 := 256
/-- Do not premultiply alpha on load. -/
def bitmapFlagNoPremultipliedAlpha : UInt32 := 512

-- ── Draw flip flags ──

/-- Flip the bitmap horizontally when drawing. -/
def flipHorizontalFlag : UInt32 := 1
/-- Flip the bitmap vertically when drawing. -/
def flipVerticalFlag : UInt32 := 2

-- ── Lock mode constants ──

/-- Lock for both reading and writing. -/
def lockReadwrite : UInt32 := 0
/-- Lock for reading only. -/
def lockReadonly : UInt32 := 1
/-- Lock for writing only (may discard existing content). -/
def lockWriteonly : UInt32 := 2

-- ── Bitmap creation / new-bitmap setup ──

/-- Set flags for the next bitmap to be created. -/
@[extern "allegro_al_set_new_bitmap_flags"]
opaque setNewBitmapFlags : UInt32 → IO Unit

/-- Get the flags that will be used for the next bitmap creation. -/
@[extern "allegro_al_get_new_bitmap_flags"]
opaque getNewBitmapFlags : IO UInt32

/-- Add a flag to the current new-bitmap flags (bitwise OR). -/
@[extern "allegro_al_add_new_bitmap_flag"]
opaque addNewBitmapFlag : UInt32 → IO Unit

/-- Set the pixel format for the next bitmap to be created. -/
@[extern "allegro_al_set_new_bitmap_format"]
opaque setNewBitmapFormat : UInt32 → IO Unit

/-- Get the pixel format that will be used for the next bitmap creation. -/
@[extern "allegro_al_get_new_bitmap_format"]
opaque getNewBitmapFormat : IO UInt32

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

/-- Get the creation flags of a bitmap. -/
@[extern "allegro_al_get_bitmap_flags"]
opaque getBitmapFlags : UInt64 → IO UInt32

/-- Get the pixel format of a bitmap. -/
@[extern "allegro_al_get_bitmap_format"]
opaque getBitmapFormat : UInt64 → IO UInt32

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

/-- Lock entire bitmap. Returns a LockedRegion handle (0 on failure). -/
@[extern "allegro_al_lock_bitmap"]
opaque lockBitmap : UInt64 → UInt32 → UInt32 → IO LockedRegion

/-- Lock a rectangular region. Returns a LockedRegion handle (0 on failure). -/
@[extern "allegro_al_lock_bitmap_region"]
opaque lockBitmapRegion : UInt64 → Int32 → Int32 → Int32 → Int32 → UInt32 → UInt32 → IO LockedRegion

/-- Unlock a locked bitmap. -/
@[extern "allegro_al_unlock_bitmap"]
opaque unlockBitmap : UInt64 → IO Unit

/-- Get the pixel format of a locked region. -/
@[extern "allegro_al_locked_region_get_format"]
opaque lockedRegionGetFormat : LockedRegion → IO UInt32

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

/-- Draw a bitmap at position (dx, dy) with the given flip flags. -/
@[extern "allegro_al_draw_bitmap"]
opaque drawBitmap : UInt64 → Float → Float → UInt32 → IO Unit

/-- Draw a scaled bitmap.
    `drawScaledBitmap bmp sx sy sw sh dx dy dw dh flags` -/
@[extern "allegro_al_draw_scaled_bitmap"]
opaque drawScaledBitmap : UInt64 → Float → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a region of a bitmap.
    `drawBitmapRegion bmp sx sy sw sh dx dy flags` -/
@[extern "allegro_al_draw_bitmap_region"]
opaque drawBitmapRegion : UInt64 → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a bitmap with rotation.
    `drawRotatedBitmap bmp cx cy dx dy angle flags` -/
@[extern "allegro_al_draw_rotated_bitmap"]
opaque drawRotatedBitmap : UInt64 → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a bitmap with scaling and rotation.
    `drawScaledRotatedBitmap bmp cx cy dx dy xscale yscale angle flags` -/
@[extern "allegro_al_draw_scaled_rotated_bitmap"]
opaque drawScaledRotatedBitmap : UInt64 → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a bitmap tinted with an RGB colour.
    `drawTintedBitmapRgb bmp r g b dx dy flags` -/
@[extern "allegro_al_draw_tinted_bitmap_rgb"]
opaque drawTintedBitmapRgb : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → UInt32 → IO Unit

/-- Draw a tinted, scaled bitmap.
    `drawTintedScaledBitmapRgb bmp r g b sx sy sw sh dx dy dw dh flags` -/
@[extern "allegro_al_draw_tinted_scaled_bitmap_rgb"]
opaque drawTintedScaledBitmapRgb : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a tinted, rotated bitmap.
    `drawTintedRotatedBitmapRgb bmp r g b cx cy dx dy angle flags` -/
@[extern "allegro_al_draw_tinted_rotated_bitmap_rgb"]
opaque drawTintedRotatedBitmapRgb : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → UInt32 → IO Unit

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

/-- Get the texture wrap mode (u, v) for newly created bitmaps. -/
@[extern "allegro_al_get_new_bitmap_wrap"]
opaque getNewBitmapWrap : IO (UInt32 × UInt32)

/-- Set the texture wrap mode (u, v) for newly created bitmaps. -/
@[extern "allegro_al_set_new_bitmap_wrap"]
opaque setNewBitmapWrap : UInt32 → UInt32 → IO Unit

-- ── Bitmap wrap mode constants ──

/-- Wrap mode: use the default (usually clamp). -/
def bitmapWrapDefault : UInt32 := 0
/-- Wrap mode: repeat the texture. -/
def bitmapWrapRepeat : UInt32 := 1
/-- Wrap mode: clamp to edge. -/
def bitmapWrapClamp : UInt32 := 2
/-- Wrap mode: mirror the texture. -/
def bitmapWrapMirror : UInt32 := 3

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
opaque getBitmapBlender : IO (UInt32 × UInt32 × UInt32)

/-- Set the per-bitmap blender.
    `setBitmapBlender op src dst` -/
@[extern "allegro_al_set_bitmap_blender"]
opaque setBitmapBlender : UInt32 → UInt32 → UInt32 → IO Unit

/-- Get the per-bitmap separate blender as `(op, src, dst, alphaOp, alphaSrc, alphaDst)`. -/
@[extern "allegro_al_get_separate_bitmap_blender"]
opaque getSeparateBitmapBlender : IO (UInt32 × UInt32 × UInt32 × UInt32 × UInt32 × UInt32)

/-- Set the per-bitmap separate blender.
    `setSeparateBitmapBlender op src dst alphaOp alphaSrc alphaDst` -/
@[extern "allegro_al_set_separate_bitmap_blender"]
opaque setSeparateBitmapBlender : UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

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

/-- Draw a tinted region of a bitmap.
    `drawTintedBitmapRegionRgb bmp r g b sx sy sw sh dx dy flags` -/
@[extern "allegro_al_draw_tinted_bitmap_region_rgb"]
opaque drawTintedBitmapRegionRgb : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a tinted, scaled, rotated bitmap.
    `drawTintedScaledRotatedBitmapRgb bmp r g b cx cy dx dy xscale yscale angle flags` -/
@[extern "allegro_al_draw_tinted_scaled_rotated_bitmap_rgb"]
opaque drawTintedScaledRotatedBitmapRgb : UInt64 → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

/-- Draw a tinted, scaled, rotated region of a bitmap.
    `drawTintedScaledRotatedBitmapRegionRgb bmp sx sy sw sh r g b cx cy dx dy xscale yscale angle flags` -/
@[extern "allegro_al_draw_tinted_scaled_rotated_bitmap_region_rgb"]
opaque drawTintedScaledRotatedBitmapRegionRgb : UInt64 → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO Unit

-- ── Block-aligned locking ──

/-- Lock a bitmap using block-aligned access. Returns a LockedRegion handle (0 on failure). -/
@[extern "allegro_al_lock_bitmap_blocked"]
opaque lockBitmapBlocked : UInt64 → UInt32 → IO LockedRegion

/-- Lock a block-aligned region of a bitmap. Returns a LockedRegion handle (0 on failure).
    `lockBitmapRegionBlocked bmp xBlock yBlock wBlock hBlock flags` -/
@[extern "allegro_al_lock_bitmap_region_blocked"]
opaque lockBitmapRegionBlocked : UInt64 → Int32 → Int32 → Int32 → Int32 → UInt32 → IO LockedRegion

-- ── Option-returning variants ──

/-- Create a bitmap, returning `none` on failure (OOM, invalid size, etc.). -/
def createBitmap? (w h : UInt32) : IO (Option Bitmap) := liftOption (createBitmap w h)

/-- Clone a bitmap, returning `none` on failure. -/
def cloneBitmap? (bmp : Bitmap) : IO (Option Bitmap) := liftOption (cloneBitmap bmp)

/-- Create a sub-bitmap, returning `none` on failure. -/
def createSubBitmap? (parent : Bitmap) (x y w h : Int32) : IO (Option Bitmap) :=
  liftOption (createSubBitmap parent x y w h)

/-- Lock a bitmap for direct pixel access, returning `none` on failure. -/
def lockBitmap? (bmp : Bitmap) (format flags : UInt32) : IO (Option LockedRegion) :=
  liftOption (lockBitmap bmp format flags)

/-- Lock a bitmap region, returning `none` on failure. -/
def lockBitmapRegion? (bmp : Bitmap) (x y w h : Int32) (format flags : UInt32) : IO (Option LockedRegion) :=
  liftOption (lockBitmapRegion bmp x y w h format flags)

/-- Lock a bitmap with block-aligned access, returning `none` on failure. -/
def lockBitmapBlocked? (bmp : Bitmap) (flags : UInt32) : IO (Option LockedRegion) :=
  liftOption (lockBitmapBlocked bmp flags)

/-- Lock a block-aligned bitmap region, returning `none` on failure. -/
def lockBitmapRegionBlocked? (bmp : Bitmap) (x y w h : Int32) (flags : UInt32) : IO (Option LockedRegion) :=
  liftOption (lockBitmapRegionBlocked bmp x y w h flags)

end Allegro
