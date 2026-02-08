-- ColorExtrasDemo — demonstrates gap-fill Colour-space conversion APIs.
-- Console-only — no display needed.
--
-- Showcases: getColorVersion, colorXyzToRgb, colorRgbToXyz,
--            colorLabToRgb, colorRgbToLab, colorXyyToRgb, colorRgbToXyy,
--            colorLchToRgb, colorRgbToLch, colorDistanceCiede2000,
--            isColorValid, colorHsv, colorHsl, colorCmyk, colorYuv,
--            colorName, colorHtml, colorXyz, colorLab, colorXyy,
--            colorLch, colorOklab, colorLinear
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  IO.println "── Color Extras Demo ──"

  -- Addon version
  let ver ← Allegro.getColorVersion
  IO.println s!"  getColorVersion = {ver}"

  -- CIE XYZ round-trip
  let (xr, xg, xb) ← Allegro.colorXyzToRgb 0.4124 0.2126 0.0193
  IO.println s!"  colorXyzToRgb(0.41,0.21,0.02) = ({xr}, {xg}, {xb})"
  let (xx, xy, xz) ← Allegro.colorRgbToXyz xr xg xb
  IO.println s!"  colorRgbToXyz round-trip = ({xx}, {xy}, {xz})"

  -- CIE L*a*b*
  let (lr, lg, lb) ← Allegro.colorLabToRgb 50.0 20.0 (-10.0)
  IO.println s!"  colorLabToRgb(50,20,-10) = ({lr}, {lg}, {lb})"
  let (ll, la, lab_b) ← Allegro.colorRgbToLab lr lg lb
  IO.println s!"  colorRgbToLab round-trip = ({ll}, {la}, {lab_b})"

  -- CIE xyY
  let (yr, yg, yb) ← Allegro.colorXyyToRgb 0.3127 0.3290 1.0
  IO.println s!"  colorXyyToRgb(0.31,0.33,1.0) = ({yr}, {yg}, {yb})"
  let (yx, yy_v, yY) ← Allegro.colorRgbToXyy yr yg yb
  IO.println s!"  colorRgbToXyy round-trip = ({yx}, {yy_v}, {yY})"

  -- CIE LCH
  let (cr, cg, cb) ← Allegro.colorLchToRgb 60.0 30.0 1.0
  IO.println s!"  colorLchToRgb(60,30,1.0) = ({cr}, {cg}, {cb})"
  let (cl, cc, ch) ← Allegro.colorRgbToLch cr cg cb
  IO.println s!"  colorRgbToLch round-trip = ({cl}, {cc}, {ch})"

  -- CIEDE2000 distance between red and blue
  let dist ← Allegro.colorDistanceCiede2000 255 0 0 0 0 255
  IO.println s!"  colorDistanceCiede2000(red, blue) = {dist}"

  -- isColorValid
  let v1 ← Allegro.isColorValid 0.5 0.5 0.5 1.0
  IO.println s!"  isColorValid(0.5,0.5,0.5,1.0) = {v1} (expected 1)"
  let v2 ← Allegro.isColorValid 2.0 0.0 0.0 1.0
  IO.println s!"  isColorValid(2.0,0,0) = {v2} (expected 0)"

  -- ALLEGRO_COLOR-returning convenience constructors (decomposed to RGBA)
  let (hr, hg, hb, ha) ← Allegro.colorHsv 120.0 1.0 1.0
  IO.println s!"  colorHsv(120,1,1) = ({hr},{hg},{hb},{ha})"

  let (hr2, hg2, hb2, ha2) ← Allegro.colorHsl 240.0 1.0 0.5
  IO.println s!"  colorHsl(240,1,0.5) = ({hr2},{hg2},{hb2},{ha2})"

  let (kr, kg, kb, ka) ← Allegro.colorCmyk 0.0 1.0 1.0 0.0
  IO.println s!"  colorCmyk(0,1,1,0) = ({kr},{kg},{kb},{ka})"

  let (ur, ug, ub, ua) ← Allegro.colorYuv 0.5 0.0 0.0
  IO.println s!"  colorYuv(0.5,0,0) = ({ur},{ug},{ub},{ua})"

  let (nr, ng, nb, na) ← Allegro.colorName "dodgerblue"
  IO.println s!"  colorName(\"dodgerblue\") = ({nr},{ng},{nb},{na})"

  let (tr, tg, tb, ta) ← Allegro.colorHtml "#FF6600"
  IO.println s!"  colorHtml(\"#FF6600\") = ({tr},{tg},{tb},{ta})"

  let (zr, zg, zb, za) ← Allegro.colorXyz 0.4 0.2 0.05
  IO.println s!"  colorXyz(0.4,0.2,0.05) = ({zr},{zg},{zb},{za})"

  let (abr, abg, abb, aba) ← Allegro.colorLab 50.0 20.0 (-10.0)
  IO.println s!"  colorLab(50,20,-10) = ({abr},{abg},{abb},{aba})"

  let (yr2, yg2, yb2, ya2) ← Allegro.colorXyy 0.31 0.33 0.5
  IO.println s!"  colorXyy(0.31,0.33,0.5) = ({yr2},{yg2},{yb2},{ya2})"

  let (lhr, lhg, lhb, lha) ← Allegro.colorLch 60.0 30.0 1.0
  IO.println s!"  colorLch(60,30,1) = ({lhr},{lhg},{lhb},{lha})"

  let (okr, okg, okb, oka) ← Allegro.colorOklab 0.5 0.1 (-0.1)
  IO.println s!"  colorOklab(0.5,0.1,-0.1) = ({okr},{okg},{okb},{oka})"

  let (linr, ling, linb, lina) ← Allegro.colorLinear 0.5 0.5 0.5
  IO.println s!"  colorLinear(0.5,0.5,0.5) = ({linr},{ling},{linb},{lina})"

  Allegro.uninstallSystem
  IO.println "── done ──"
