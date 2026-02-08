-- HapticDemo — demonstrates gap-fill Haptic (force-feedback) APIs.
-- Console-only — no display needed (joystick optional).
--
-- Showcases: installHaptic, uninstallHaptic, isHapticInstalled,
--            isMouseHaptic, isKeyboardHaptic, isJoystickHaptic,
--            isDisplayHaptic, isTouchInputHaptic,
--            getHapticFromMouse, getHapticFromKeyboard,
--            getHapticFromJoystick, getHapticFromDisplay,
--            getHapticFromTouchInput, releaseHaptic,
--            getHapticCapabilities, isHapticActive, getMaxHapticEffects,
--            setHapticGain, getHapticGain,
--            setHapticAutocenter, getHapticAutocenter,
--            rumbleHaptic, releaseHapticEffect
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  IO.println "── Haptic Demo ──"

  let okH ← Allegro.installHaptic
  if okH != 1 then
    IO.println "  installHaptic not available on this system — exiting"
    Allegro.uninstallSystem; return

  let inst ← Allegro.isHapticInstalled
  IO.println s!"  isHapticInstalled = {inst}"

  -- Check device haptic support
  let mh ← Allegro.isMouseHaptic
  IO.println s!"  isMouseHaptic = {mh}"
  let kh ← Allegro.isKeyboardHaptic
  IO.println s!"  isKeyboardHaptic = {kh}"
  let th ← Allegro.isTouchInputHaptic
  IO.println s!"  isTouchInputHaptic = {th}"

  -- Try joystick
  let _ ← Allegro.installJoystick
  let nJoy ← Allegro.getNumJoysticks
  IO.println s!"  joysticks available = {nJoy}"

  if nJoy > 0 then
    let joy ← Allegro.getJoystick 0
    if joy != 0 then
      let jh ← Allegro.isJoystickHaptic joy
      IO.println s!"  isJoystickHaptic(0) = {jh}"
      if jh == 1 then
        let hap ← Allegro.getHapticFromJoystick joy
        IO.println s!"  getHapticFromJoystick = {hap}"
        if hap != 0 then
          let caps ← hap.capabilities
          IO.println s!"  getHapticCapabilities = {caps}"
          let active ← hap.isActive
          IO.println s!"  isHapticActive = {active}"
          let maxFx ← hap.maxEffects
          IO.println s!"  getMaxHapticEffects = {maxFx}"

          -- Gain
          let _ ← hap.setGain 0.8
          let gain ← hap.getGain
          IO.println s!"  setHapticGain(0.8) → getHapticGain = {gain}"

          -- Autocenter
          let _ ← hap.setAutocenter 0.5
          let ac ← hap.getAutocenter
          IO.println s!"  setHapticAutocenter(0.5) → getHapticAutocenter = {ac}"

          -- Rumble (short vibration)
          let effectId ← hap.rumble 0.5 0.2
          IO.println s!"  rumbleHaptic(0.5, 0.2s) → effectId={effectId}"
          if effectId != 0 then
            Allegro.rest 0.3
            let _ ← effectId.release
            IO.println "  releaseHapticEffect — OK"

          let _ ← hap.release
          IO.println "  releaseHaptic — OK"
      joy.release

  Allegro.uninstallJoystick
  Allegro.uninstallHaptic
  IO.println "  uninstallHaptic — OK"

  Allegro.uninstallSystem
  IO.println "── done ──"
