-- BitmapExtrasDemo — demonstrates gap-fill Bitmap APIs.
-- Graphical — needs a display for bitmap operations.
--
-- Showcases: getNewBitmapDepth, setNewBitmapDepth, getNewBitmapSamples,
--            setNewBitmapSamples, getNewBitmapWrap, setNewBitmapWrap,
--            getBitmapDepth, getBitmapSamples, getBitmapX, getBitmapY,
--            convertMaskToAlpha, getBitmapBlender, setBitmapBlender,
--            getSeparateBitmapBlender, setSeparateBitmapBlender,
--            getBitmapBlendColor, setBitmapBlendColor, resetBitmapBlender,
--            drawTintedBitmapRegion, drawTintedScaledRotatedBitmap,
--            drawTintedScaledRotatedBitmapRegion,
--            lockBitmapBlocked, lockBitmapRegionBlocked
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.initImageAddon

  IO.println "── Bitmap Extras Demo ──"

  -- New bitmap settings
  Allegro.setNewBitmapDepth 16
  let d ← Allegro.getNewBitmapDepth
  IO.println s!"  setNewBitmapDepth(16) → getNewBitmapDepth = {d}"
  Allegro.setNewBitmapDepth 0  -- reset

  Allegro.setNewBitmapSamples 4
  let s ← Allegro.getNewBitmapSamples
  IO.println s!"  setNewBitmapSamples(4) → getNewBitmapSamples = {s}"
  Allegro.setNewBitmapSamples 0

  Allegro.setNewBitmapWrap (⟨1⟩ : BitmapWrapMode) (⟨1⟩ : BitmapWrapMode)  -- REPEAT, REPEAT
  let wrapResult ← Allegro.getNewBitmapWrap
  let wu : Allegro.BitmapWrapMode := wrapResult.1
  let wv : Allegro.BitmapWrapMode := wrapResult.2
  IO.println s!"  setNewBitmapWrap(1,1) → getNewBitmapWrap = ({wu.val},{wv.val})"
  Allegro.setNewBitmapWrap (⟨0⟩ : BitmapWrapMode) (⟨0⟩ : BitmapWrapMode)

  -- Create display + bitmap
  Allegro.setNewDisplayFlags ⟨0⟩
  let display ← Allegro.createDisplay 320 200
  if display == 0 then
    IO.eprintln "  createDisplay failed"; Allegro.uninstallSystem; return

  let bmp : Bitmap ← Allegro.createBitmap 64 64
  if bmp == 0 then
    IO.eprintln "  createBitmap failed"; display.destroy
    Allegro.uninstallSystem; return

  let bd ← bmp.depth
  IO.println s!"  getBitmapDepth = {bd}"
  let bs ← bmp.samples
  IO.println s!"  getBitmapSamples = {bs}"

  -- Sub-bitmap offset
  let sub : Bitmap ← Allegro.createSubBitmap bmp 10 20 32 32
  if sub != 0 then
    let bx ← sub.x
    let by_ ← sub.y
    IO.println s!"  sub-bitmap getX={bx}, getY={by_} (expected 10,20)"
    sub.destroy

  -- convertMaskToAlpha (magenta → alpha)
  bmp.setAsTarget
  Allegro.clearToColorRgba 255 0 255 255  -- magenta
  bmp.convertMaskToAlpha 255 0 255
  IO.println "  convertMaskToAlpha — OK"

  -- Per-bitmap blender
  Allegro.setBitmapBlender ⟨1⟩ ⟨4⟩ ⟨5⟩  -- ADD, SRC_ALPHA, INV_SRC_ALPHA
  let (op, src, dst) ← Allegro.getBitmapBlender
  IO.println s!"  setBitmapBlender → getBitmapBlender = ({op.val},{src.val},{dst.val})"

  Allegro.setSeparateBitmapBlender ⟨1⟩ ⟨4⟩ ⟨5⟩ ⟨1⟩ ⟨1⟩ ⟨1⟩
  let (op2, s2, d2, aop, asrc, adst) ← Allegro.getSeparateBitmapBlender
  IO.println s!"  getSeparateBitmapBlender = ({op2.val},{s2.val},{d2.val},{aop.val},{asrc.val},{adst.val})"

  Allegro.setBitmapBlendColor 1.0 0.5 0.25 0.78
  let (cr, cg, cb, ca) ← Allegro.getBitmapBlendColor
  IO.println s!"  setBitmapBlendColor → getBitmapBlendColor = ({cr},{cg},{cb},{ca})"

  Allegro.resetBitmapBlender
  IO.println "  resetBitmapBlender — OK"

  -- Tinted drawing variants (draw onto the display backbuffer)
  Allegro.setTargetBitmap (← display.backbuffer)

  -- drawTintedBitmapRegionRgb
  bmp.drawTintedRegionRgb 255 255 255 0 0 32 32 10 10 FlipFlags.none
  IO.println "  drawTintedBitmapRegionRgb — OK"

  -- drawTintedScaledRotatedBitmapRgb
  bmp.drawTintedScaledRotatedRgb 255 255 255 32 32 160 100 1.0 1.0 0.0 FlipFlags.none
  IO.println "  drawTintedScaledRotatedBitmapRgb — OK"

  -- drawTintedScaledRotatedBitmapRegionRgb
  bmp.drawTintedScaledRotatedRegionRgb 0 0 64 64 255 255 255 32 32 160 100 1.0 1.0 0.0 FlipFlags.none
  IO.println "  drawTintedScaledRotatedBitmapRegionRgb — OK"

  -- lockBitmapBlocked (may fail for non-block formats)
  let lbk ← bmp.lockBlocked LockMode.readwrite
  IO.println s!"  lockBitmapBlocked = {lbk}"
  if lbk != 0 then
    bmp.unlock

  bmp.destroy
  display.destroy
  Allegro.shutdownImageAddon
  Allegro.uninstallSystem
  IO.println "── done ──"
