-- SystemExtrasDemo — headless demo of gap-fill System, Time, Monitor, and Render State APIs.
-- Console-only — no display needed.
--
-- Showcases: isSystemInstalled, getSystemId, getSystemDriver, setExeName,
--            initTimeout, getMonitorRefreshRate,
--            getRenderState, setRenderState
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  IO.println "── System Extras Demo ──"

  -- isSystemInstalled
  let inst ← Allegro.isSystemInstalled
  IO.println s!"  isSystemInstalled = {inst} (expected 1)"

  -- getSystemId — platform-specific value (e.g. 4 for Linux)
  let sysId ← Allegro.getSystemId
  IO.println s!"  getSystemId = {sysId}"

  -- getSystemDriver — low-level pointer, non-zero when running
  let drv ← Allegro.getSystemDriver
  IO.println s!"  getSystemDriver = {drv} (non-zero expected)"

  -- setExeName
  Allegro.setExeName "MyCustomApp"
  IO.println "  setExeName \"MyCustomApp\" — OK"

  -- initTimeout — allocate a timeout struct and init it
  let to ← Allegro.createTimeout
  Allegro.initTimeout to 2.0
  IO.println s!"  createTimeout + initTimeout(2.0) = {to} (non-zero expected)"

  -- Monitor refresh rate (may return 0 on headless)
  let rate ← Allegro.getMonitorRefreshRate (0 : UInt32)
  IO.println s!"  getMonitorRefreshRate(0) = {rate}"

  -- Render state (headless = no-op but shouldn't crash)
  let rs ← Allegro.getRenderState (0 : UInt32)
  IO.println s!"  getRenderState(ALPHA_TEST) = {rs}"
  Allegro.setRenderState (0 : UInt32) (0 : UInt32)
  IO.println "  setRenderState — OK"

  -- clearDepthBuffer (needs a display context — skipped in headless)
  IO.println "  clearDepthBuffer — skipped (needs display)"

  -- waitForVsync (needs a display context — skipped in headless)
  IO.println "  waitForVsync — skipped (needs display)"

  Allegro.uninstallSystem
  IO.println "── done ──"
