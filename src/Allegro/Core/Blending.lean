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

/-- Allegro blend operation (how source and destination are combined). -/
structure BlendOp where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace BlendOp
/-- Blend operation: `result = src + dest`. -/
def add : BlendOp := ⟨0⟩
/-- Blend operation: `result = src − dest`. -/
def srcMinusDest : BlendOp := ⟨1⟩
/-- Blend operation: `result = dest − src`. -/
def destMinusSrc : BlendOp := ⟨2⟩
end BlendOp

-- Backward-compatible aliases
def blendAdd := BlendOp.add
def blendSrcMinusDest := BlendOp.srcMinusDest
def blendDestMinusSrc := BlendOp.destMinusSrc

-- ── Blend factors ──

/-- Allegro blend factor (what each side is multiplied by). -/
structure BlendFactor where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace BlendFactor
/-- Blend factor: multiply by zero. -/
def zero : BlendFactor := ⟨0⟩
/-- Blend factor: multiply by one (no change). -/
def one : BlendFactor := ⟨1⟩
/-- Blend factor: multiply by source alpha. -/
def alpha : BlendFactor := ⟨2⟩
/-- Blend factor: multiply by (1 − source alpha). -/
def inverseAlpha : BlendFactor := ⟨3⟩
/-- Blend factor: multiply by source colour. -/
def srcColor : BlendFactor := ⟨4⟩
/-- Blend factor: multiply by destination colour. -/
def destColor : BlendFactor := ⟨5⟩
/-- Blend factor: multiply by (1 − source colour). -/
def inverseSrcColor : BlendFactor := ⟨6⟩
/-- Blend factor: multiply by (1 − destination colour). -/
def inverseDestColor : BlendFactor := ⟨7⟩
/-- Blend factor: multiply by the constant colour set with `setBlendColor`. -/
def constColor : BlendFactor := ⟨8⟩
/-- Blend factor: multiply by (1 − constant colour). -/
def inverseConstColor : BlendFactor := ⟨9⟩
end BlendFactor

-- Backward-compatible aliases
def blendZero := BlendFactor.zero
def blendOne := BlendFactor.one
def blendAlpha := BlendFactor.alpha
def blendInverseAlpha := BlendFactor.inverseAlpha
def blendSrcColor := BlendFactor.srcColor
def blendDestColor := BlendFactor.destColor
def blendInverseSrcColor := BlendFactor.inverseSrcColor
def blendInverseDestColor := BlendFactor.inverseDestColor
def blendConstColor := BlendFactor.constColor
def blendInverseConstColor := BlendFactor.inverseConstColor

-- ════════════════════════════════════════════════════════════════════
-- Draw flip flags  (defined here so both Blending and Bitmap can use)
-- ════════════════════════════════════════════════════════════════════

/-- Allegro bitmap flip flags for drawing (bitfield). -/
structure FlipFlags where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

instance : OrOp FlipFlags where or a b := ⟨a.val ||| b.val⟩
instance : AndOp FlipFlags where and a b := ⟨a.val &&& b.val⟩

namespace FlipFlags
/-- No flipping. -/
def none : FlipFlags := ⟨0⟩
/-- Flip the bitmap horizontally when drawing. -/
def horizontal : FlipFlags := ⟨1⟩
/-- Flip the bitmap vertically when drawing. -/
def vertical : FlipFlags := ⟨2⟩
end FlipFlags

-- Backward-compatible aliases
def flipHorizontalFlag := FlipFlags.horizontal
def flipVerticalFlag := FlipFlags.vertical

-- ── Set / Get blender ──

/-- Set the blender used for the current target bitmap.
    `setBlender op src dest` -/
@[extern "allegro_al_set_blender"]
private opaque setBlenderRaw : UInt32 → UInt32 → UInt32 → IO Unit

@[inline] def setBlender (op : BlendOp) (src dst : BlendFactor) : IO Unit :=
  setBlenderRaw op.val src.val dst.val

/-- Set a separate blender for colour and alpha channels.
    `setSeparateBlender op src dst alphaOp alphaSrc alphaDst` -/
@[extern "allegro_al_set_separate_blender"]
private opaque setSeparateBlenderRaw : UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

@[inline] def setSeparateBlender (op : BlendOp) (src dst : BlendFactor)
    (aop : BlendOp) (asrc adst : BlendFactor) : IO Unit :=
  setSeparateBlenderRaw op.val src.val dst.val aop.val asrc.val adst.val

-- ── RGBA helpers ──

/-- Clear the target bitmap with an RGBA colour. -/
@[extern "allegro_al_clear_to_color_rgba"]
opaque clearToColorRgba : UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

/-- Draw a bitmap tinted with an RGBA colour. -/
@[extern "allegro_al_draw_tinted_bitmap_rgba"]
private opaque drawTintedBitmapRgbaRaw : UInt64 → UInt32 → UInt32 → UInt32 → UInt32 → Float → Float → UInt32 → IO Unit

@[inline] def drawTintedBitmapRgba (bmp : UInt64) (r g b a : UInt32)
    (dx dy : Float) (flags : FlipFlags) : IO Unit :=
  drawTintedBitmapRgbaRaw bmp r g b a dx dy flags.val

-- ════════════════════════════════════════════════════════════════════
-- Tuple-returning queries  (single FFI call → full result)
-- ════════════════════════════════════════════════════════════════════

/-- Get the current blender as `(op, src, dest)` in one call. -/
@[extern "allegro_al_get_blender"]
private opaque getBlenderRaw : IO (UInt32 × UInt32 × UInt32)

@[inline] def getBlender : IO (BlendOp × BlendFactor × BlendFactor) := do
  let (op, src, dst) ← getBlenderRaw
  return (⟨op⟩, ⟨src⟩, ⟨dst⟩)

/-- Get the current separate blender as `(op, src, dst, alphaOp, alphaSrc, alphaDst)`. -/
@[extern "allegro_al_get_separate_blender"]
private opaque getSeparateBlenderRaw : IO (UInt32 × UInt32 × UInt32 × UInt32 × UInt32 × UInt32)

@[inline] def getSeparateBlender : IO (BlendOp × BlendFactor × BlendFactor × BlendOp × BlendFactor × BlendFactor) := do
  let (op, src, dst, aop, asrc, adst) ← getSeparateBlenderRaw
  return (⟨op⟩, ⟨src⟩, ⟨dst⟩, ⟨aop⟩, ⟨asrc⟩, ⟨adst⟩)

/-- Get the current blend colour as `(r, g, b, a)` with components in 0.0…1.0.
    This is the constant colour used by `blendConstColor` / `blendInverseConstColor`. -/
@[extern "allegro_al_get_blend_color"]
opaque getBlendColor : IO (Float × Float × Float × Float)

/-- Set the blend colour (constant colour blending).
    `setBlendColor r g b a` where each component is in 0.0…1.0. -/
@[extern "allegro_al_set_blend_color"]
opaque setBlendColor : Float → Float → Float → Float → IO Unit

end Allegro
