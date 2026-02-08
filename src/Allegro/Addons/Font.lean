import Allegro.Core.System

/-!
# Font addon bindings

Font loading, text drawing, glyph queries, and metrics for Allegro 5.

## Text alignment
Use the alignment constants directly (pure values, no IO needed):
```
Allegro.drawTextRgb font 255 255 255 (screenW / 2) 10 Allegro.alignCentre "Centred!"
```

## Multiline text
```
Allegro.drawMultilineTextRgb font 200 200 200 10 10 300 0 0 "Long text\nwith newlines..."
```

## Glyph queries
```
let w ← Allegro.getGlyphWidth font 65   -- width of 'A'
let adv ← Allegro.getGlyphAdvance font 65 66 -- advance from 'A' to 'B'
```
-/
namespace Allegro

/-- Opaque handle to a loaded font. -/
def Font := UInt64

instance : BEq Font := inferInstanceAs (BEq UInt64)
instance : Inhabited Font := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Font := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Font 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Font := ⟨fun (h : UInt64) => s!"Font#{h}"⟩
instance : Repr Font := ⟨fun (h : UInt64) _ => .text s!"Font#{repr h}"⟩

/-- The null font handle. -/
def Font.null : Font := (0 : UInt64)

-- ── Lifecycle ──

/-- Initialise the font addon. -/
@[extern "allegro_al_init_font_addon"]
opaque initFontAddon : IO Unit

/-- Shut down the font addon. -/
@[extern "allegro_al_shutdown_font_addon"]
opaque shutdownFontAddon : IO Unit

/-- Returns true (1) if the font addon is initialised. -/
@[extern "allegro_al_is_font_addon_initialized"]
opaque isFontAddonInitialized : IO UInt32

-- ── Alignment constants ──

/-- Left-align text (default). Value: 0. -/
def alignLeft : UInt32 := 0

/-- Centre-align text. Value: 1. -/
def alignCentre : UInt32 := 1

/-- Right-align text. Value: 2. -/
def alignRight : UInt32 := 2

/-- Snap text drawing to integer coordinates. Combine with `|||`. Value: 4. -/
def alignInteger : UInt32 := 4

-- ── Font creation / loading / destruction ──

/-- Create the built-in 8×8 monospace font (always available, no file needed). -/
@[extern "allegro_al_create_builtin_font"]
opaque createBuiltinFont : IO Font

/-- Load a font from a file at the given pixel size. Returns null on failure. -/
@[extern "allegro_al_load_font"]
opaque loadFont : String → Int32 → UInt32 → IO Font

/-- Load a bitmap font (image with glyphs). -/
@[extern "allegro_al_load_bitmap_font"]
opaque loadBitmapFont : String → IO Font

/-- Load a bitmap font with flags (e.g. ALLEGRO_NO_PREMULTIPLIED_ALPHA). -/
@[extern "allegro_al_load_bitmap_font_flags"]
opaque loadBitmapFontFlags : String → UInt32 → IO Font

/-- Destroy a font and free its resources. -/
@[extern "allegro_al_destroy_font"]
opaque destroyFont : Font → IO Unit

-- ── Text drawing ──

/-- Draw text at (x, y) with an RGB colour and alignment flags. -/
@[extern "allegro_al_draw_text_rgb"]
opaque drawTextRgb : Font → UInt32 → UInt32 → UInt32 → Float → Float → UInt32 → String → IO Unit

/-- Draw text at (x, y) with an RGBA colour and alignment flags. -/
@[extern "allegro_al_draw_text_rgba"]
opaque drawTextRgba : Font → UInt32 → UInt32 → UInt32 → UInt32 → Float → Float → UInt32 → String → IO Unit

/-- Draw a ALLEGRO_USTR with an RGB colour. -/
@[extern "allegro_al_draw_ustr_rgb"]
opaque drawUstrRgb : Font → UInt32 → UInt32 → UInt32 → Float → Float → UInt32 → UInt64 → IO Unit

/-- Draw justified (stretched) text between x1 and x2. -/
@[extern "allegro_al_draw_justified_text_rgb"]
opaque drawJustifiedTextRgb : Font → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → UInt32 → String → IO Unit

/-- Draw multiline text, wrapping at maxWidth pixels.
    Set lineHeight to 0 to use the font's default line height. -/
@[extern "allegro_al_draw_multiline_text_rgb"]
opaque drawMultilineTextRgb : Font → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → UInt32 → String → IO Unit

-- ── Glyph drawing ──

/-- Draw a single glyph (Unicode codepoint) at (x, y). -/
@[extern "allegro_al_draw_glyph_rgb"]
opaque drawGlyphRgb : Font → UInt32 → UInt32 → UInt32 → Float → Float → Int32 → IO Unit

/-- Get the width of a single glyph. -/
@[extern "allegro_al_get_glyph_width"]
opaque getGlyphWidth : Font → Int32 → IO UInt32

/-- Get the advance distance between two consecutive glyphs.
    Pass 0 for codepoint2 to get the advance for a glyph at the end of text. -/
@[extern "allegro_al_get_glyph_advance"]
opaque getGlyphAdvance : Font → Int32 → Int32 → IO UInt32

-- ── Text / font metrics ──

/-- Get the width in pixels of a text string rendered in the given font. -/
@[extern "allegro_al_get_text_width"]
opaque getTextWidth : Font → String → IO UInt32

/-- Get the line height (pixel distance between baselines) of the font. -/
@[extern "allegro_al_get_font_line_height"]
opaque getFontLineHeight : Font → IO UInt32

/-- Get the maximum ascent (pixels above the baseline) of the font. -/
@[extern "allegro_al_get_font_ascent"]
opaque getFontAscent : Font → IO UInt32

/-- Get the maximum descent (pixels below the baseline) of the font. -/
@[extern "allegro_al_get_font_descent"]
opaque getFontDescent : Font → IO UInt32

/-- Get the number of Unicode ranges in the font. -/
@[extern "allegro_al_get_font_ranges"]
opaque getFontRanges : Font → Int32 → IO UInt32

/-- Get the width in pixels of a ustr rendered in the given font. -/
@[extern "allegro_al_get_ustr_width"]
opaque getUstrWidth : Font → UInt64 → IO UInt32

/-- Get the full text bounding box as `(x, y, w, h)` in one call. -/
@[extern "allegro_al_get_text_dimensions"]
opaque getTextDimensions : Font → String → IO (UInt32 × UInt32 × UInt32 × UInt32)

-- ── Fallback font ──

/-- Set a fallback font for missing glyphs. Pass 0 to clear. -/
@[extern "allegro_al_set_fallback_font"]
opaque setFallbackFont : Font → Font → IO Unit

/-- Get the current fallback font (0 if none). -/
@[extern "allegro_al_get_fallback_font"]
opaque getFallbackFont : Font → IO Font

-- ── Option-returning variants ──

/-- Load a font file, returning `none` on failure (file not found, bad format). -/
def loadFont? (filename : String) (size : Int32) (flags : UInt32) : IO (Option Font) :=
  liftOption (loadFont filename size flags)

/-- Load a bitmap font, returning `none` on failure. -/
def loadBitmapFont? (filename : String) : IO (Option Font) := liftOption (loadBitmapFont filename)

/-- Load a bitmap font with flags, returning `none` on failure. -/
def loadBitmapFontFlags? (filename : String) (flags : UInt32) : IO (Option Font) :=
  liftOption (loadBitmapFontFlags filename flags)

/-- Get the fallback font, returning `none` if none is set. -/
def getFallbackFont? (font : Font) : IO (Option Font) := liftOption (getFallbackFont font)

-- ── Additional queries ──

/-- Get the full ustr bounding box as `(x, y, w, h)` in one call. -/
@[extern "allegro_al_get_ustr_dimensions"]
opaque getUstrDimensions : Font → UInt64 → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Get the bounding box for a single glyph as `(x, y, w, h)`.
    Returns `(0,0,0,0)` if the glyph is not in the font. -/
@[extern "allegro_al_get_glyph_dimensions"]
opaque getGlyphDimensions : Font → Int32 → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Draw justified (stretched) text from a USTR between x1 and x2. -/
@[extern "allegro_al_draw_justified_ustr_rgb"]
opaque drawJustifiedUstrRgb : Font → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → UInt32 → UInt64 → IO Unit

/-- Draw multiline text from a USTR, wrapping at maxWidth pixels. -/
@[extern "allegro_al_draw_multiline_ustr_rgb"]
opaque drawMultilineUstrRgb : Font → UInt32 → UInt32 → UInt32 → Float → Float → Float → Float → UInt32 → UInt64 → IO Unit

/-- Create a font from a bitmap with specified Unicode ranges.
    `ranges` is a flat array of pairs `[start₁, end₁, start₂, end₂, …]`.
    Each pair maps consecutive glyph images left-to-right in the bitmap. -/
@[extern "allegro_al_grab_font_from_bitmap"]
opaque grabFontFromBitmap : UInt64 → Array UInt32 → IO Font

/-- Return the version of the font addon (packed integer). -/
@[extern "allegro_al_get_allegro_font_version"]
opaque getFontVersion : IO UInt32

-- ── Glyph info (UNSTABLE) ──

/-- Retrieve glyph information for a codepoint. Returns a tuple:
    `(bitmap, x, y, w, h, kerning, offset_x, offset_y, advance)`
    where `bitmap` is a Bitmap handle (UInt64), all others are UInt32.
    Returns all-zeros if the font or glyph is invalid. -/
@[extern "allegro_al_get_glyph"]
opaque getGlyph : Font → UInt32 → IO (UInt64 × UInt32 × UInt32 × UInt32 × UInt32 × UInt32 × UInt32 × UInt32 × UInt32)

-- ── Multiline text iteration (callback-collecting) ──

/-- Split text into lines for a given font and max pixel width.
    Returns all line fragments as an `Array String`. -/
@[extern "allegro_al_do_multiline_text"]
opaque doMultilineText : Font → Float → String → IO (Array String)

/-- Split USTR text into lines for a given font and max pixel width.
    Returns all line fragments as an `Array String`. -/
@[extern "allegro_al_do_multiline_ustr"]
opaque doMultilineUstr : Font → Float → UInt64 → IO (Array String)

end Allegro
