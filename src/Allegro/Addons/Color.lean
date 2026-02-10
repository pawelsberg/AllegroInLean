/-!
# Color addon bindings

Colour-space conversions: HSV, HSL, CMYK, YUV, OkLab, linear sRGB,
named CSS colours, and HTML hex strings.

All conversions accept/return **0–255 integer RGB** on the Lean side.
Floating-point colour-space components (hue, saturation, etc.) are `Float`.

## HSV round-trip (tuple API)
```
let (r, g, b) ← Allegro.colorHsvToRgb 120.0 1.0 1.0
let (h, s, v) ← Allegro.colorRgbToHsv 0 255 0
```

## Named / HTML colours
```
let (r, g, b) ← Allegro.colorNameToRgb "dodgerblue"
let html ← Allegro.colorRgbToHtml 30 144 255   -- → "#1e90ff"
```

## OkLab perceptual space
```
let (l, a, b) ← Allegro.colorRgbToOklab 128 0 255
```
-/
namespace Allegro

-- ── Lifecycle ──

/-- Initialise the color addon. Currently a no-op, provided for consistency. -/
def initColorAddon : IO Unit := pure ()

-- ── Named / HTML helpers (non-tuple) ──

/-- Find the closest CSS colour name for the given RGB values. -/
@[extern "allegro_al_color_rgb_to_name"]
opaque colorRgbToName : UInt32 → UInt32 → UInt32 → IO String

/-- Convert RGB (0–255) to an HTML hex string like "#1e90ff". -/
@[extern "allegro_al_color_rgb_to_html"]
opaque colorRgbToHtml : UInt32 → UInt32 → UInt32 → IO String

-- ════════════════════════════════════════════════════════════════════
-- Tuple-returning conversions  (single FFI call → full result)
-- ════════════════════════════════════════════════════════════════════

-- ── HSV ↔ RGB ──

/-- Convert HSV (hue 0–360, s/v 0–1) to RGB (0–255) in one call. -/
@[extern "allegro_al_color_hsv_rgb"]
opaque colorHsvToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to HSV (hue 0–360, s/v 0–1) in one call. -/
@[extern "allegro_al_color_rgb_to_hsv"]
opaque colorRgbToHsv : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── HSL ↔ RGB ──

/-- Convert HSL (hue 0–360, s/l 0–1) to RGB (0–255) in one call. -/
@[extern "allegro_al_color_hsl_rgb"]
opaque colorHslToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to HSL (hue 0–360, s/l 0–1) in one call. -/
@[extern "allegro_al_color_rgb_to_hsl"]
opaque colorRgbToHsl : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── CMYK ↔ RGB ──

/-- Convert CMYK (all 0–1) to RGB (0–255) in one call. -/
@[extern "allegro_al_color_cmyk_rgb"]
opaque colorCmykToRgb : Float → Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to CMYK (all 0–1) in one call. -/
@[extern "allegro_al_color_rgb_to_cmyk"]
opaque colorRgbToCmyk : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float × Float)

-- ── YUV ↔ RGB ──

/-- Convert YUV to RGB (0–255) in one call. -/
@[extern "allegro_al_color_yuv_rgb"]
opaque colorYuvToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to YUV in one call. -/
@[extern "allegro_al_color_rgb_to_yuv"]
opaque colorRgbToYuv : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── Named CSS colours ──

/-- Get RGB (0–255) of a named colour (e.g. "dodgerblue") in one call. -/
@[extern "allegro_al_color_name_rgb"]
opaque colorNameToRgb : @& String → IO (UInt32 × UInt32 × UInt32)

-- ── HTML hex strings ──

/-- Parse an HTML colour string (e.g. "#1e90ff") and return (r, g, b) 0–255. -/
@[extern "allegro_al_color_html_rgb"]
opaque colorHtmlToRgb : @& String → IO (UInt32 × UInt32 × UInt32)

-- ── OkLab ↔ RGB ──

/-- Convert OkLab to RGB (0–255) in one call. -/
@[extern "allegro_al_color_oklab_rgb"]
opaque colorOklabToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to OkLab in one call. -/
@[extern "allegro_al_color_rgb_to_oklab"]
opaque colorRgbToOklab : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── Linear sRGB ↔ RGB ──

/-- Convert linear-light RGB (0–1) to sRGB (0–255) in one call. -/
@[extern "allegro_al_color_linear_rgb"]
opaque colorLinearToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert sRGB (0–255) to linear-light RGB (0–1) in one call. -/
@[extern "allegro_al_color_rgb_to_linear"]
opaque colorRgbToLinear : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── Version ──

/-- Get the version of the colour addon (packed as major·minor·revision·release). -/
@[extern "allegro_al_get_allegro_color_version"]
opaque getColorVersion : IO UInt32

-- ── XYZ ↔ RGB ──

/-- Convert CIE XYZ to RGB (0–255) in one call. -/
@[extern "allegro_al_color_xyz_rgb"]
opaque colorXyzToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to CIE XYZ in one call. -/
@[extern "allegro_al_color_rgb_to_xyz"]
opaque colorRgbToXyz : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── L*a*b* ↔ RGB ──

/-- Convert CIE L*a*b* to RGB (0–255) in one call. -/
@[extern "allegro_al_color_lab_rgb"]
opaque colorLabToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to CIE L*a*b* in one call. -/
@[extern "allegro_al_color_rgb_to_lab"]
opaque colorRgbToLab : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── xyY ↔ RGB ──

/-- Convert CIE xyY to RGB (0–255) in one call. -/
@[extern "allegro_al_color_xyy_rgb"]
opaque colorXyyToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to CIE xyY in one call. -/
@[extern "allegro_al_color_rgb_to_xyy"]
opaque colorRgbToXyy : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── LCH ↔ RGB ──

/-- Convert CIE LCH to RGB (0–255) in one call. -/
@[extern "allegro_al_color_lch_rgb"]
opaque colorLchToRgb : Float → Float → Float → IO (UInt32 × UInt32 × UInt32)

/-- Convert RGB (0–255) to CIE LCH in one call. -/
@[extern "allegro_al_color_rgb_to_lch"]
opaque colorRgbToLch : UInt32 → UInt32 → UInt32 → IO (Float × Float × Float)

-- ── Colour distance ──

/-- Compute the CIEDE2000 perceptual distance between two RGB colours. -/
@[extern "allegro_al_color_distance_ciede2000"]
opaque colorDistanceCiede2000 : UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO Float

-- ── Colour validity ──

/-- Check if a colour (r, g, b, a in 0.0–1.0) has valid premultiplied alpha values.
    Returns 1 if valid. -/
@[extern "allegro_al_is_color_valid"]
opaque isColorValid : Float → Float → Float → Float → IO UInt32

-- ════════════════════════════════════════════════════════════════════
-- Convenience constructors  (colour-space → RGBA 0–255)
-- Each constructs an ALLEGRO_COLOR and decomposes it to (r, g, b, a).
-- ════════════════════════════════════════════════════════════════════

/-- Construct an RGBA colour from HSV (hue 0–360, s/v 0–1). -/
@[extern "allegro_al_color_hsv"]
opaque colorHsv : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from HSL (hue 0–360, s/l 0–1). -/
@[extern "allegro_al_color_hsl"]
opaque colorHsl : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from CMYK (all 0–1). -/
@[extern "allegro_al_color_cmyk"]
opaque colorCmyk : Float → Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from YUV. -/
@[extern "allegro_al_color_yuv"]
opaque colorYuv : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from a CSS colour name (e.g. "dodgerblue"). -/
@[extern "allegro_al_color_name_rgba"]
opaque colorName : @& String → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from an HTML hex string (e.g. "#1e90ff"). -/
@[extern "allegro_al_color_html_rgba"]
opaque colorHtml : @& String → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from CIE XYZ. -/
@[extern "allegro_al_color_xyz"]
opaque colorXyz : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from CIE L*a*b*. -/
@[extern "allegro_al_color_lab"]
opaque colorLab : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from CIE xyY. -/
@[extern "allegro_al_color_xyy"]
opaque colorXyy : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from CIE LCH. -/
@[extern "allegro_al_color_lch"]
opaque colorLch : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from OkLab. -/
@[extern "allegro_al_color_oklab"]
opaque colorOklab : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Construct an RGBA colour from linear-light RGB (0–1). -/
@[extern "allegro_al_color_linear"]
opaque colorLinear : Float → Float → Float → IO (UInt32 × UInt32 × UInt32 × UInt32)

end Allegro
