-- DisplayExtrasDemo — demonstrates gap-fill Display APIs.
-- Graphical — creates a display to test display properties.
--
-- Showcases: setNewDisplayRefreshRate, getNewDisplayRefreshRate,
--            setNewWindowTitle, getNewWindowTitle, setNewDisplayAdapter,
--            getNewDisplayAdapter, setNewWindowPosition, getNewWindowPosition,
--            getDisplayFormat, getDisplayRefreshRate, getDisplayOrientation,
--            getDisplayAdapter, getWindowBorders, getWindowConstraints,
--            applyWindowConstraints, setDisplayOption, setDisplayIcons,
--            isCompatibleBitmap, backupDirtyBitmaps,
--            clearDepthBuffer, waitForVsync
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.initImageAddon

  IO.println "── Display Extras Demo ──"

  -- New display settings (before display creation)
  Allegro.setNewDisplayRefreshRate 60
  let rr ← Allegro.getNewDisplayRefreshRate
  IO.println s!"  setNewDisplayRefreshRate(60) → getNewDisplayRefreshRate = {rr}"

  Allegro.setNewWindowTitle "Display Extras"
  let wt ← Allegro.getNewWindowTitle
  IO.println s!"  setNewWindowTitle → getNewWindowTitle = \"{wt}\""

  Allegro.setNewDisplayAdapter 0
  let da ← Allegro.getNewDisplayAdapter
  IO.println s!"  setNewDisplayAdapter(0) → getNewDisplayAdapter = {da}"

  Allegro.setNewWindowPosition 100 100
  let (wx, wy) ← Allegro.getNewWindowPosition
  IO.println s!"  setNewWindowPosition(100,100) → getNewWindowPosition = ({wx},{wy})"

  -- Create a display to test runtime properties
  Allegro.setNewDisplayFlags 0
  let display ← Allegro.createDisplay 320 200
  if display == 0 then
    IO.eprintln "  createDisplay failed (headless?); skipping runtime tests"
    Allegro.uninstallSystem; return

  let fmt ← display.pixelFormat
  IO.println s!"  getDisplayFormat = {fmt}"

  let rr2 ← display.refreshRate
  IO.println s!"  getDisplayRefreshRate = {rr2}"

  let orient ← display.orientation
  IO.println s!"  getDisplayOrientation = {orient}"

  let adapter ← display.adapter
  IO.println s!"  getDisplayAdapter = {adapter}"

  let borders ← display.windowBorders
  IO.println s!"  getWindowBorders = {borders}"

  let constr ← display.getConstraints
  IO.println s!"  getWindowConstraints = {constr}"

  -- Apply constraints (0 = don't apply)
  display.applyConstraints (0 : UInt32)
  IO.println "  applyWindowConstraints(0) — OK"

  -- setDisplayOptionLive (option 0 = RED_SIZE, value 8)
  display.setOptionLive (0 : UInt32) 8
  IO.println "  setDisplayOptionLive — OK"

  -- isCompatibleBitmap — with a small memory bitmap
  let bmp : Bitmap ← Allegro.createBitmap 16 16
  if bmp != 0 then
    let compat ← bmp.isCompatible
    IO.println s!"  isCompatibleBitmap = {compat}"
    bmp.destroy

  -- backupDirtyBitmaps (no-op typically, shouldn't crash)
  display.backupDirtyBitmaps
  IO.println "  backupDirtyBitmaps — OK"

  -- setDisplayIcons (empty array — just tests the call)
  display.setIcons (#[] : Array UInt64)
  IO.println "  setDisplayIcons(empty) — OK"

  -- clearDepthBuffer (needs display context — we have one now)
  Allegro.clearDepthBuffer 1.0
  IO.println "  clearDepthBuffer(1.0) — OK"

  -- waitForVsync
  let vs ← Allegro.waitForVsync
  IO.println s!"  waitForVsync = {vs}"

  display.destroy
  Allegro.shutdownImageAddon
  Allegro.uninstallSystem
  IO.println "── done ──"
