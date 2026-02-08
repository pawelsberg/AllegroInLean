/-!
Blending mode control for Allegro 5.

Set the blending mode that controls how new pixels are combined with
existing pixels in the target bitmap. Allegro's default is
`ADD / ONE / INVERSE_ALPHA` (pre-multiplied alpha).

## Constants

### Blend operations
* `blendAdd` — `src + dest`
* `blendDestMinusSrc` — `dest − src`
* `blendSrcMinusDest` — `src − dest`

### Blend factors
* `blendZero`, `blendOne`
* `blendAlpha`, `blendInverseAlpha`
* `blendSrcColor`, `blendDestColor`
* `blendInverseSrcColor`, `blendInverseDestColor`
* `blendConstColor`, `blendInverseConstColor`

## Typical usage
```
Allegro.setBlender Allegro.blendAdd Allegro.blendAlpha Allegro.blendInverseAlpha
-- draw semi-transparent geometry --
```
-/
namespace Allegro

-- ── Blend operations ──

/-- Blend operation: `result = src + dest`. -/
def blendAdd : UInt32 := 0
/-- Blend operation: `result = dest − src`. -/
def blendDestMinusSrc : UInt32 := 2
/-- Blend operation: `result = src − dest`. -/
def blendSrcMinusDest : UInt32 := 1

-- ── Blend factors ──

/-- Blend factor: multiply by zero. -/
def blendZero : UInt32 := 0
/-- Blend factor: multiply by one (no change). -/
def blendOne : UInt32 := 1
/-- Blend factor: multiply by source alpha. -/
def blendAlpha : UInt32 := 2
/-- Blend factor: multiply by (1 − source alpha). -/
def blendInverseAlpha : UInt32 := 3
/-- Blend factor: multiply by source colour. -/
def blendSrcColor : UInt32 := 4
/-- Blend factor: multiply by destination colour. -/
def blendDestColor : UInt32 := 5
/-- Blend factor: multiply by (1 − source colour). -/
def blendInverseSrcColor : UInt32 := 6
/-- Blend factor: multiply by (1 − destination colour). -/
def blendInverseDestColor : UInt32 := 7
/-- Blend factor: multiply by the constant colour set with `setBlendColor`. -/
def blendConstColor : UInt32 := 8
/-- Blend factor: multiply by (1 − constant colour). -/
def blendInverseConstColor : UInt32 := 9

-- ── Set / Get blender ──

/-- Set the blender used for the current target bitmap.
    `setBlender op src dest` -/
@[extern "allegro_al_set_blender"]
opaque setBlender : UInt32 → UInt32 → UInt32 → IO Unit

/-- Set a separate blender for colour and alpha channels.
    `setSeparateBlender op src dst alphaOp alphaSrc alphaDst` -/
@[extern "allegro_al_set_separate_blender"]
opaque setSeparateBlender : UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

-- ── RGBA helpers ──

/-- Clear the target bitmap with an RGBA colour. -/
@[extern "allegro_al_clear_to_color_rgba"]
opaque clearToColorRgba : UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

/-- Draw a bitmap tinted with an RGBA colour. -/
@[extern "allegro_al_draw_tinted_bitmap_rgba"]
opaque drawTintedBitmapRgba : UInt64 → UInt32 → UInt32 → UInt32 → UInt32 → Float → Float → UInt32 → IO Unit

-- ════════════════════════════════════════════════════════════════════
-- Tuple-returning queries  (single FFI call → full result)
-- ════════════════════════════════════════════════════════════════════

/-- Get the current blender as `(op, src, dest)` in one call. -/
@[extern "allegro_al_get_blender"]
opaque getBlender : IO (UInt32 × UInt32 × UInt32)

/-- Get the current separate blender as `(op, src, dst, alphaOp, alphaSrc, alphaDst)`. -/
@[extern "allegro_al_get_separate_blender"]
opaque getSeparateBlender : IO (UInt32 × UInt32 × UInt32 × UInt32 × UInt32 × UInt32)

/-- Get the current blend colour as `(r, g, b, a)` with components in 0.0…1.0.
    This is the constant colour used by `blendConstColor` / `blendInverseConstColor`. -/
@[extern "allegro_al_get_blend_color"]
opaque getBlendColor : IO (Float × Float × Float × Float)

/-- Set the blend colour (constant colour blending).
    `setBlendColor r g b a` where each component is in 0.0…1.0. -/
@[extern "allegro_al_set_blend_color"]
opaque setBlendColor : Float → Float → Float → Float → IO Unit

end Allegro
