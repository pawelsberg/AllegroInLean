-- FontExtrasDemo — demonstrates gap-fill Font and TTF APIs.
-- Graphical — needs a display + font for text measurement.
--
-- Showcases: doMultilineText, doMultilineUstr, getGlyph,
--            getTtfVersion, loadTtfFontF, loadTtfFontStretchF
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.initImageAddon
  Allegro.initFontAddon
  let _ ← Allegro.initTtfAddon

  IO.println "── Font Extras Demo ──"

  Allegro.setNewDisplayFlags ⟨0⟩
  let display ← Allegro.createDisplay 640 480
  if display == 0 then
    IO.eprintln "  createDisplay failed"; Allegro.uninstallSystem; return

  -- TTF version
  let ttfVer ← Allegro.getTtfVersion
  IO.println s!"  getTtfVersion = {ttfVer}"

  -- Load a TTF font the normal way
  let font : Font ← Allegro.loadTtfFont "data/DejaVuSans.ttf" 20 0
  if font == 0 then
    IO.eprintln "  loadTtfFont failed (data/DejaVuSans.ttf not found?)"
    Allegro.destroyDisplay display; Allegro.uninstallSystem; return

  -- doMultilineText — split text into lines that fit a max width
  let lines : Array String ← font.doMultiline 200.0
    "This is a long paragraph that should be split across multiple lines when rendered within a 200-pixel width constraint."
  IO.println s!"  doMultilineText → {lines.size} lines:"
  let mut lineNum : Nat := 0
  for line in lines do
    IO.println s!"    [{lineNum}] \"{line}\""
    lineNum := lineNum + 1

  -- doMultilineUstr
  let u ← Allegro.ustrNew "Short text for USTR multiline test."
  if u != 0 then
    let ulines ← font.doMultilineUstr 300.0 u
    IO.println s!"  doMultilineUstr → {ulines.size} lines"
    u.free

  -- getGlyph — glyph bounding box info
  let glyph ← font.glyph 65  -- 'A'
  IO.println s!"  getGlyph('A') = {glyph}"

  -- loadTtfFontF — load from an ALLEGRO_FILE handle
  let ff ← Allegro.fopen "data/DejaVuSans.ttf" "r"
  if ff != 0 then
    let fontF : Font ← Allegro.loadTtfFontF ff "" 18 (0 : UInt32)
    -- Note: fclose not needed on success (file is owned by the font)
    if fontF != 0 then
      IO.println "  loadTtfFontF — OK"
      fontF.destroy
    else
      IO.println "  loadTtfFontF returned null"

  -- loadTtfFontStretchF
  let ff2 ← Allegro.fopen "data/DejaVuSans.ttf" "r"
  if ff2 != 0 then
    let fontS : Font ← Allegro.loadTtfFontStretchF ff2 "" 24 16 (0 : UInt32)
    if fontS != 0 then
      IO.println "  loadTtfFontStretchF — OK"
      fontS.destroy
    else
      IO.println "  loadTtfFontStretchF returned null"

  -- Draw multiline text on screen
  Allegro.clearToColorRgb 30 30 50
  let mut yPos : Float := 20.0
  for line in lines do
    font.drawTextRgb 255 255 200 20.0 yPos Allegro.TextAlign.left line
    yPos := yPos + 22.0
  Allegro.flipDisplay
  IO.println "  Rendered multiline text — visible for 1 second"
  Allegro.rest 1.0

  font.destroy
  display.destroy
  Allegro.shutdownTtfAddon
  Allegro.shutdownFontAddon
  Allegro.shutdownImageAddon
  Allegro.uninstallSystem
  IO.println "── done ──"
