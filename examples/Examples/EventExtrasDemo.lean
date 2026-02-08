-- EventExtrasDemo — demonstrates gap-fill Event, Timer, Input APIs.
-- Console-only — no display needed.
--
-- Showcases: waitForEventUntil, isEventSourceRegistered,
--            getEventSourceData, setEventSourceData, unrefUserEvent,
--            resumeTimer, getTimerStarted, setTimerCount, addTimerCount,
--            isKeyboardInstalled, uninstallKeyboard, canSetKeyboardLeds,
--            setKeyboardLeds, clearKeyboardState,
--            isMouseInstalled, uninstallMouse, getMouseNumAxes,
--            setMouseZ, setMouseW, setMouseAxis,
--            canGetMouseCursorPosition, getMouseWheelPrecision,
--            getBlendColor, setBlendColor,
--            installTouchInput, getTouchInputState
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.installKeyboard
  let _ ← Allegro.installMouse

  IO.println "── Event Extras Demo ──"

  -- ── Timer extras ──
  let timer ← Allegro.createTimer (1.0 / 30.0)
  if timer != 0 then
    timer.start
    let started ← timer.isStarted
    IO.println s!"  getTimerStarted = {started} (expected 1)"

    timer.stop
    timer.resume
    IO.println "  resumeTimer — OK"

    timer.setCount 100
    let cnt ← timer.count
    IO.println s!"  setTimerCount(100) → getTimerCount = {cnt}"

    timer.addCount 50
    let cnt2 ← timer.count
    IO.println s!"  addTimerCount(50) → getTimerCount = {cnt2}"
    timer.stop

    -- ── Event queue extras ──
    let queue ← Allegro.createEventQueue
    if queue != 0 then
      let timerSrc ← timer.eventSource
      queue.registerSource timerSrc

      -- isEventSourceRegistered
      let reg ← queue.isSourceRegistered timerSrc
      IO.println s!"  isEventSourceRegistered = {reg} (expected 1)"

      -- getEventSourceData / setEventSourceData
      timerSrc.setData 12345
      let esd ← timerSrc.getData
      IO.println s!"  setEventSourceData(12345) → getEventSourceData = {esd}"

      -- waitForEventUntilData — with an already-expired timeout (returns immediately)
      let timeout ← Allegro.createTimeout
      Allegro.initTimeout timeout 0.0  -- already expired
      let (got, _evData) ← Allegro.waitForEventUntilData queue timeout
      IO.println s!"  waitForEventUntilData(expired) = {got} (0 = timed out)"
      Allegro.destroyTimeout timeout
      queue.destroy

    -- ── User event unref ──
    let userSrc : EventSource ← Allegro.initUserEventSource
    let _ ← userSrc.emit 42 0 0 0
    -- unrefUserEvent — pass raw event pointer (0 = null, safe no-op)
    Allegro.unrefUserEvent (0 : UInt64)
    IO.println "  unrefUserEvent(0) — OK"
    userSrc.destroy

    timer.destroy

  -- ── Keyboard extras ──
  let kbInst ← Allegro.isKeyboardInstalled
  IO.println s!"  isKeyboardInstalled = {kbInst}"

  let canLed ← Allegro.canSetKeyboardLeds
  IO.println s!"  canSetKeyboardLeds = {canLed}"
  let _ ← Allegro.setKeyboardLeds 0  -- turn off all LEDs
  IO.println "  setKeyboardLeds(0) — OK"

  -- clearKeyboardState — pass 0 (null display) to clear for all displays
  Allegro.clearKeyboardState (0 : UInt64)
  IO.println "  clearKeyboardState(0) — OK"

  -- ── Mouse extras ──
  let mInst ← Allegro.isMouseInstalled
  IO.println s!"  isMouseInstalled = {mInst}"

  let axes ← Allegro.getMouseNumAxes
  IO.println s!"  getMouseNumAxes = {axes}"

  let canPos ← Allegro.canGetMouseCursorPosition
  IO.println s!"  canGetMouseCursorPosition = {canPos}"

  let prec ← Allegro.getMouseWheelPrecision
  IO.println s!"  getMouseWheelPrecision = {prec}"

  let _ ← Allegro.setMouseZ (0 : UInt32)
  IO.println "  setMouseZ(0) — OK"
  let _ ← Allegro.setMouseW (0 : UInt32)
  IO.println "  setMouseW(0) — OK"
  let _ ← Allegro.setMouseAxis 2 0  -- axis 2 = Z
  IO.println "  setMouseAxis(2,0) — OK"

  -- ── Blending extras ──
  Allegro.setBlendColor 1.0 0.5 0.25 0.78
  let (br, bg, bb, ba) ← Allegro.getBlendColor
  IO.println s!"  setBlendColor → getBlendColor = ({br},{bg},{bb},{ba})"

  -- ── Touch input ──
  let okTouch ← Allegro.installTouchInput
  if okTouch == 1 then
    IO.println "  installTouchInput — OK"
    -- getTouchInputState — fill a pre-allocated state struct
    let tstate ← Allegro.createTouchInputState
    Allegro.getTouchInputState tstate
    IO.println "  getTouchInputState — OK"
    Allegro.uninstallTouchInput
  else
    IO.println "  installTouchInput not available — skipping"

  -- Cleanup
  Allegro.uninstallMouse
  IO.println "  uninstallMouse — OK"
  Allegro.uninstallKeyboard
  IO.println "  uninstallKeyboard — OK"
  Allegro.uninstallSystem
  IO.println "── done ──"
