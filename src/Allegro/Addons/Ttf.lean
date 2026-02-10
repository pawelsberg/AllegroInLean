import Allegro.Core.System

/-!
# TTF addon bindings

Load TrueType / OpenType fonts via FreeType.

## Typical usage
```
let _ ← Allegro.initTtfAddon
let font ← Allegro.loadTtfFont "data/DejaVuSans.ttf" 24 0
-- draw with Allegro.drawTextRgb font ... --
Allegro.destroyFont font
Allegro.shutdownTtfAddon
```

## Stretched fonts
Load a font with separate width and height:
```
let font ← Allegro.loadTtfFontStretch "data/DejaVuSans.ttf" 32 48 0
```
-/
namespace Allegro

/-- Opaque handle to a TTF font (extends Font). -/
def TtfFont := UInt64

instance : BEq TtfFont := inferInstanceAs (BEq UInt64)
instance : Inhabited TtfFont := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq TtfFont := inferInstanceAs (DecidableEq UInt64)
instance : OfNat TtfFont 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString TtfFont := ⟨fun (h : UInt64) => s!"TtfFont#{h}"⟩
instance : Repr TtfFont := ⟨fun (h : UInt64) _ => .text s!"TtfFont#{repr h}"⟩

-- ── Lifecycle ──

/-- Initialise the TrueType font addon (requires the font addon). -/
@[extern "allegro_al_init_ttf_addon"]
opaque initTtfAddon : IO UInt32

/-- Shut down the TrueType font addon. -/
@[extern "allegro_al_shutdown_ttf_addon"]
opaque shutdownTtfAddon : IO Unit

/-- Returns true (1) if the TTF addon is initialised. -/
@[extern "allegro_al_is_ttf_addon_initialized"]
opaque isTtfAddonInitialized : IO UInt32

-- ── TTF loading flags ──

/-- Disable kerning. -/
def ttfNoKerning : UInt32 := 1

/-- Render glyphs monochrome (no anti-aliasing). -/
def ttfMonochrome : UInt32 := 2

/-- Disable auto-hinting. -/
def ttfNoAutohint : UInt32 := 4

-- ── Font loading ──

/-- Load a TrueType font at the given pixel size. -/
@[extern "allegro_al_load_ttf_font"]
opaque loadTtfFont : @& String → Int32 → UInt32 → IO TtfFont

/-- Load a TrueType font stretched to width `w` and height `h` pixels. -/
@[extern "allegro_al_load_ttf_font_stretch"]
opaque loadTtfFontStretch : @& String → Int32 → Int32 → UInt32 → IO TtfFont

-- ── Version ──

/-- Get the TTF addon version (packed as major·minor·revision·release). -/
@[extern "allegro_al_get_allegro_ttf_version"]
opaque getTtfVersion : IO UInt32

-- ── Option-returning variants ──

/-- Load a TrueType font, returning `none` on failure (file not found, FreeType error). -/
def loadTtfFont? (filename : String) (size : Int32) (flags : UInt32) : IO (Option TtfFont) :=
  liftOption (loadTtfFont filename size flags)

/-- Load a stretched TrueType font, returning `none` on failure. -/
def loadTtfFontStretch? (filename : String) (w h : Int32) (flags : UInt32) : IO (Option TtfFont) :=
  liftOption (loadTtfFontStretch filename w h flags)

-- ── File-based TTF loading ──

/-- Load a TTF font from an open `AllegroFile`. `name` is used for error messages. -/
@[extern "allegro_al_load_ttf_font_f"]
opaque loadTtfFontF : UInt64 → String → Int32 → UInt32 → IO TtfFont

/-- Load a stretched TTF font from an open `AllegroFile`. `name` is used for error messages. -/
@[extern "allegro_al_load_ttf_font_stretch_f"]
opaque loadTtfFontStretchF : UInt64 → String → Int32 → Int32 → UInt32 → IO TtfFont

def loadTtfFontF? (file : UInt64) (name : String) (size : Int32) (flags : UInt32) : IO (Option TtfFont) :=
  liftOption (loadTtfFontF file name size flags)

def loadTtfFontStretchF? (file : UInt64) (name : String) (w h : Int32) (flags : UInt32) : IO (Option TtfFont) :=
  liftOption (loadTtfFontStretchF file name w h flags)

end Allegro
