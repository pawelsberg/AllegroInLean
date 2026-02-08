-- Color addon demo.
--
-- Exercises colour-space conversions (HSV, HSL, CMYK, YUV, OkLab, linear sRGB),
-- named CSS colours, and HTML hex strings.  Console-only — no display needed.
--
-- Showcases: colorHsvToRgb, colorRgbToHsv, colorHslToRgb, colorCmykToRgb,
--            colorYuvToRgb, colorNameToRgb, colorRgbToName, colorRgbToHtml,
--            colorHtmlToRgb, colorOklabToRgb, colorRgbToOklab,
--            colorLinearToRgb, colorRgbToLinear.
import Allegro.Core.System
import Allegro.Addons.Color

open Allegro

def main : IO Unit := do
  let okInit ← Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"; return

  IO.println "── Color Demo ──"

  -- HSV → RGB round-trip
  let (r, g, b) ← Allegro.colorHsvToRgb 120.0 1.0 1.0
  IO.println s!"  HSV(120,1,1)  → RGB({r},{g},{b})"
  let (h, s, v) ← Allegro.colorRgbToHsv r g b
  IO.println s!"  RGB→HSV       → ({h},{s},{v})"

  -- HSL → RGB
  let (r2, g2, b2) ← Allegro.colorHslToRgb 240.0 1.0 0.5
  IO.println s!"  HSL(240,1,0.5)→ RGB({r2},{g2},{b2})"
  let (h2, s2, l2) ← Allegro.colorRgbToHsl r2 g2 b2
  IO.println s!"  RGB→HSL       → ({h2},{s2},{l2})"

  -- CMYK → RGB
  let (rc, gc, bc) ← Allegro.colorCmykToRgb 0.0 1.0 1.0 0.0
  IO.println s!"  CMYK(0,1,1,0) → RGB({rc},{gc},{bc})"
  let (c, m, y, k) ← Allegro.colorRgbToCmyk 255 0 0
  IO.println s!"  RGB(255,0,0)  → CMYK({c},{m},{y},{k})"

  -- YUV → RGB
  let (ry, gy, by_) ← Allegro.colorYuvToRgb 0.5 0.0 0.0
  IO.println s!"  YUV(0.5,0,0)  → RGB({ry},{gy},{by_})"
  let (yy, uy, vy) ← Allegro.colorRgbToYuv 128 128 128
  IO.println s!"  RGB(128,128,128)→YUV({yy},{uy},{vy})"

  -- Named CSS colour
  let (rn, gn, bn) ← Allegro.colorNameToRgb "dodgerblue"
  IO.println s!"  \"dodgerblue\"  → RGB({rn},{gn},{bn})"
  let name ← Allegro.colorRgbToName 30 144 255
  IO.println s!"  RGB(30,144,255)→ \"{name}\""

  -- HTML hex
  let html ← Allegro.colorRgbToHtml 30 144 255
  IO.println s!"  RGB→HTML      → {html}"
  let (rh, gh, bh) ← Allegro.colorHtmlToRgb "#1e90ff"
  IO.println s!"  \"#1e90ff\"     → RGB({rh},{gh},{bh})"

  -- OkLab round-trip
  let (lo, ao, bo_) ← Allegro.colorRgbToOklab 128 0 255
  IO.println s!"  RGB(128,0,255)→ OkLab({lo},{ao},{bo_})"
  let (ro, go, bo2) ← Allegro.colorOklabToRgb lo ao bo_
  IO.println s!"  OkLab→RGB     → ({ro},{go},{bo2})"

  -- Linear sRGB round-trip
  let (ll, al, bl) ← Allegro.colorRgbToLinear 200 100 50
  IO.println s!"  RGB(200,100,50)→linear({ll},{al},{bl})"
  let (rl, gl, bl2) ← Allegro.colorLinearToRgb ll al bl
  IO.println s!"  linear→RGB    → ({rl},{gl},{bl2})"

  Allegro.uninstallSystem
  IO.println "── done ──"
