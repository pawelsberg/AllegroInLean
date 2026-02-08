-- JoystickExtrasDemo — demonstrates gap-fill Joystick APIs.
-- Console-only — no display needed.
--
-- Showcases: getJoystickStickFlags, getJoystickGuid, getJoystickType,
--            setJoystickMappings, setJoystickMappingsF
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.installJoystick

  IO.println "── Joystick Extras Demo ──"

  let numJoy ← Allegro.getNumJoysticks
  IO.println s!"  getNumJoysticks = {numJoy}"

  if numJoy > 0 then
    let joy ← Allegro.getJoystick 0
    if joy != 0 then
      -- getJoystickStickFlags (stick index 0)
      let flags ← joy.stickFlags (0 : UInt32)
      IO.println s!"  getJoystickStickFlags(0) = {flags}"

      -- getJoystickGuid (5.2.11 UNSTABLE)
      let guid ← joy.guid
      IO.println s!"  getJoystickGuid = \"{guid}\""

      -- getJoystickType (5.2.11 UNSTABLE)
      let jtype ← joy.joystickType
      IO.println s!"  getJoystickType = {jtype}"
    else
      IO.println "  getJoystick(0) returned null — skipping per-stick queries"
  else
    IO.println "  No joysticks found — skipping per-stick queries"

  -- setJoystickMappings (from filename — file need not exist, just test call path)
  let mOk ← Allegro.setJoystickMappings "/nonexistent/gamecontrollerdb.txt"
  IO.println s!"  setJoystickMappings(nonexistent) = {mOk} (0 = file not found, OK)"

  -- setJoystickMappingsF (from ALLEGRO_FILE — use null to test call path safely)
  let mfOk ← Allegro.setJoystickMappingsF (0 : UInt64)
  IO.println s!"  setJoystickMappingsF(null) = {mfOk} (0 = expected)"

  Allegro.uninstallJoystick
  Allegro.uninstallSystem
  IO.println "── done ──"
