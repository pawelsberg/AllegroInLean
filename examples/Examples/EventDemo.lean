-- Event system demo.
--
-- Opens a window and displays a live scrolling log of every event
-- received from the event queue. Demonstrates the expanded event
-- system: keyboard, mouse, display, timer, joystick, touch, and
-- user-defined events, together with timestamps and event fields.
--
-- A custom user event is emitted once per second via a user event
-- source to illustrate the user-event workflow.
--
-- Press Escape or close the window to quit.
--
-- Showcases: Event queue, all event type constants, event field
--   accessors, user event source (init/emit/destroy), timed wait,
--   peek, flush, queue pause/resume, joystick + touch event sources.
import Allegro

open Allegro

/-- Maximum number of log lines displayed on screen. -/
def maxLogLines : Nat := 28

/-- Format a Float timestamp to 2 decimal places. -/
def fmtTime (t : Float) : String :=
  let s := (t * 100.0).round / 100.0
  s!"{s}"

/-- Check whether `needle` appears anywhere inside `haystack`. -/
def hasSubstr (haystack needle : String) : Bool :=
  let h := haystack.toList
  let n := needle.toList
  let nLen := n.length
  if nLen == 0 then true
  else Id.run do
    let mut i := 0
    let hLen := h.length
    while i + nLen <= hLen do
      if (h.drop i).take nLen == n then return true
      i := i + 1
    return false

def main : IO Unit := do
  -- ── Initialisation ──
  let okInit ← Allegro.init
  if okInit == 0 then IO.eprintln "al_init failed"; return

  let _ ← Allegro.installKeyboard
  let _ ← Allegro.installMouse
  let _ ← Allegro.initPrimitivesAddon
  Allegro.initFontAddon

  -- Optional subsystems (may fail on headless / desktop without hardware)
  let joyOk ← Allegro.installJoystick
  let touchOk ← Allegro.installTouchInput

  let _ ← Allegro.createDisplay 800 600
  let display : Display ← Allegro.getCurrentDisplay
  display.setTitle "AllegroInLean – Event Demo"

  let timer ← Allegro.createTimer (1.0 / 30.0)
  let queue ← Allegro.createEventQueue

  -- Register all available event sources
  queue.registerSource (← display.eventSource)
  queue.registerSource (← Allegro.getKeyboardEventSource)
  queue.registerSource (← Allegro.getMouseEventSource)
  queue.registerSource (← timer.eventSource)

  if joyOk != 0 then
    queue.registerSource (← Allegro.getJoystickEventSource)

  if touchOk != 0 then
    queue.registerSource (← Allegro.getTouchInputEventSource)

  -- Create a user event source and register it
  let userSrc : EventSource ← Allegro.initUserEventSource
  queue.registerSource userSrc

  timer.start

  -- ── Cache event type constants ──
  let evDisplayClose := Allegro.EventType.displayClose
  let evDisplayResize := Allegro.EventType.displayResize
  let evDisplayExpose := Allegro.EventType.displayExpose
  let evDisplaySwitchOut := Allegro.EventType.displaySwitchOut
  let evDisplaySwitchIn := Allegro.EventType.displaySwitchIn
  let evKeyDown := Allegro.EventType.keyDown
  let evKeyUp := Allegro.EventType.keyUp
  let evKeyChar := Allegro.EventType.keyChar
  let evMouseAxes := Allegro.EventType.mouseAxes
  let evMouseBtnDown := Allegro.EventType.mouseButtonDown
  let evMouseBtnUp := Allegro.EventType.mouseButtonUp
  let evMouseEnter := Allegro.EventType.mouseEnterDisplay
  let evMouseLeave := Allegro.EventType.mouseLeaveDisplay
  let evTimer := Allegro.EventType.timer
  let evJoyAxis := Allegro.EventType.joystickAxis
  let evJoyBtnDown := Allegro.EventType.joystickButtonDown
  let evJoyBtnUp := Allegro.EventType.joystickButtonUp
  let evJoyConfig := Allegro.EventType.joystickConfiguration
  let evTouchBegin := Allegro.EventType.touchBegin
  let evTouchEnd := Allegro.EventType.touchEnd
  let evTouchMove := Allegro.EventType.touchMove
  let kEsc := Allegro.KeyCode.escape

  let event ← Allegro.createEvent
  let font : Font ← Allegro.createBuiltinFont

  -- Mutable state
  let doneRef ← IO.mkRef false
  let logRef ← IO.mkRef (Array.mkEmpty maxLogLines : Array String)
  let needsRedrawRef ← IO.mkRef true
  let eventCountRef ← IO.mkRef (0 : Nat)
  let userTickRef ← IO.mkRef (0 : Nat)
  let lastUserEmitRef ← IO.mkRef (0.0 : Float)

  -- Helper to append a line to the scrolling log
  let addLog := fun (msg : String) => do
    logRef.modify fun lines =>
      let lines := lines.push msg
      if lines.size > maxLogLines then
        lines.extract 1 lines.size
      else lines

  addLog "Event demo started. All events will appear here."
  addLog s!"Joystick driver: {if joyOk != 0 then "OK" else "unavailable"}"
  addLog s!"Touch driver: {if touchOk != 0 then "OK" else "unavailable"}"
  addLog "A user event fires every ~1 s.  Press Esc to quit."
  addLog "─────────────────────────────────────────────"

  while true do
    let done ← doneRef.get
    if done then break

    queue.waitFor event
    let evType ← event.type
    let ts ← event.timestamp
    let tsStr := fmtTime ts
    eventCountRef.modify (· + 1)

    -- ── Classify and log the event ──

    if evType == evDisplayClose then do
      addLog s!"[{tsStr}] DISPLAY_CLOSE"
      doneRef.set true

    else if evType == evDisplayResize then do
      let w ← event.displayWidth
      let h ← event.displayHeight
      addLog s!"[{tsStr}] DISPLAY_RESIZE  {w}×{h}"
      needsRedrawRef.set true

    else if evType == evDisplayExpose then do
      addLog s!"[{tsStr}] DISPLAY_EXPOSE"
      needsRedrawRef.set true

    else if evType == evDisplaySwitchOut then do
      addLog s!"[{tsStr}] DISPLAY_SWITCH_OUT"
      needsRedrawRef.set true

    else if evType == evDisplaySwitchIn then do
      addLog s!"[{tsStr}] DISPLAY_SWITCH_IN"
      needsRedrawRef.set true

    else if evType == evKeyDown then do
      let key ← event.keyboardKeycode
      let name ← Allegro.keycodeToName key
      addLog s!"[{tsStr}] KEY_DOWN  keycode={key.val} ({name})"
      if key == kEsc then doneRef.set true
      needsRedrawRef.set true

    else if evType == evKeyUp then do
      let key ← event.keyboardKeycode
      let name ← Allegro.keycodeToName key
      addLog s!"[{tsStr}] KEY_UP  keycode={key.val} ({name})"
      needsRedrawRef.set true

    else if evType == evKeyChar then do
      let key ← event.keyboardKeycode
      let uc ← event.keyboardUnichar
      let mods ← event.keyboardModifiers
      let rep ← event.keyboardRepeat
      addLog s!"[{tsStr}] KEY_CHAR  key={key.val} unichar={uc} mods={mods} repeat={rep}"
      needsRedrawRef.set true

    else if evType == evMouseAxes then do
      let mx ← event.mouseX
      let my ← event.mouseY
      let mz ← event.mouseZ
      addLog s!"[{tsStr}] MOUSE_AXES  x={mx} y={my} z(wheel)={mz}"
      needsRedrawRef.set true

    else if evType == evMouseBtnDown then do
      let btn ← event.mouseButton
      let mx ← event.mouseX
      let my ← event.mouseY
      addLog s!"[{tsStr}] MOUSE_BUTTON_DOWN  btn={btn} at ({mx},{my})"
      needsRedrawRef.set true

    else if evType == evMouseBtnUp then do
      let btn ← event.mouseButton
      addLog s!"[{tsStr}] MOUSE_BUTTON_UP  btn={btn}"
      needsRedrawRef.set true

    else if evType == evMouseEnter then do
      addLog s!"[{tsStr}] MOUSE_ENTER_DISPLAY"
      needsRedrawRef.set true

    else if evType == evMouseLeave then do
      addLog s!"[{tsStr}] MOUSE_LEAVE_DISPLAY"
      needsRedrawRef.set true

    else if evType == evJoyAxis then do
      let stick ← event.joystickStick
      let axis ← event.joystickAxis
      let pos ← event.joystickPos
      addLog s!"[{tsStr}] JOYSTICK_AXIS  stick={stick} axis={axis} pos={pos}"
      needsRedrawRef.set true

    else if evType == evJoyBtnDown then do
      let btn ← event.joystickButton
      addLog s!"[{tsStr}] JOYSTICK_BUTTON_DOWN  btn={btn}"
      needsRedrawRef.set true

    else if evType == evJoyBtnUp then do
      let btn ← event.joystickButton
      addLog s!"[{tsStr}] JOYSTICK_BUTTON_UP  btn={btn}"
      needsRedrawRef.set true

    else if evType == evJoyConfig then do
      let _ ← Allegro.reconfigureJoysticks
      let n ← Allegro.getNumJoysticks
      addLog s!"[{tsStr}] JOYSTICK_CONFIGURATION  ({n} connected)"
      needsRedrawRef.set true

    else if evType == evTouchBegin then do
      let tid ← event.touchId
      let tx ← event.touchX
      let ty ← event.touchY
      addLog s!"[{tsStr}] TOUCH_BEGIN  id={tid} ({tx},{ty})"
      needsRedrawRef.set true

    else if evType == evTouchEnd then do
      let tid ← event.touchId
      addLog s!"[{tsStr}] TOUCH_END  id={tid}"
      needsRedrawRef.set true

    else if evType == evTouchMove then do
      let tid ← event.touchId
      let tx ← event.touchX
      let ty ← event.touchY
      addLog s!"[{tsStr}] TOUCH_MOVE  id={tid} ({tx},{ty})"
      needsRedrawRef.set true

    else if evType == evTimer then do
      -- Emit a user event roughly every second (every 30 timer ticks)
      let now ← Allegro.getTime
      let lastEmit ← lastUserEmitRef.get
      if now - lastEmit >= 1.0 then do
        userTickRef.modify (· + 1)
        let tick ← userTickRef.get
        let _ ← userSrc.emit tick.toUInt64 42 0 0
        lastUserEmitRef.set now
      needsRedrawRef.set true

    else do
      -- Unknown or user event
      -- User events have type ≥ 512 (ALLEGRO_GET_EVENT_TYPE('A','L','U','S'))
      if evType.val >= 512 then do
        let d1 ← event.userData1
        let d2 ← event.userData2
        addLog s!"[{tsStr}] USER_EVENT  type={evType.val} data1={d1} data2={d2}"
        needsRedrawRef.set true
      else do
        addLog s!"[{tsStr}] event type={evType.val}"
        needsRedrawRef.set true

    -- ── Redraw when the queue is drained ──
    let empty ← queue.isEmpty
    let needsRedraw ← needsRedrawRef.get
    if empty != 0 && needsRedraw then do
      needsRedrawRef.set false
      Allegro.clearToColorRgb 18 22 30

      -- Header bar
      Allegro.drawFilledRectangleRgb 0.0 0.0 800.0 22.0 35 42 58
      let evCount ← eventCountRef.get
      font.drawTextRgb 200 210 230 10.0 6.0 TextAlign.left
        s!"Event Monitor   │   events received: {evCount}   │   Esc=quit"

      -- Scrolling log
      let lines ← logRef.get
      let mut y : Float := 30.0
      for line in lines do
        -- Colour-code by keyword
        let (r, g, b) :=
          if hasSubstr line "KEY_" then (220, 200, 100)
          else if hasSubstr line "MOUSE_" then (120, 200, 255)
          else if hasSubstr line "DISPLAY_" then (255, 140, 100)
          else if hasSubstr line "JOYSTICK_" then (100, 220, 160)
          else if hasSubstr line "TOUCH_" then (220, 120, 220)
          else if hasSubstr line "USER_EVENT" then (180, 255, 180)
          else (160, 160, 160)
        font.drawTextRgb r g b 10.0 y TextAlign.left line
        y := y + 18.0

      -- Footer
      Allegro.drawFilledRectangleRgb 0.0 576.0 800.0 600.0 35 42 58
      let joyStr := if joyOk != 0 then "joy:ON" else "joy:off"
      let touchStr := if touchOk != 0 then "touch:ON" else "touch:off"
      font.drawTextRgb 140 140 140 10.0 582.0 TextAlign.left
        s!"{joyStr}  {touchStr}  user-src:ON  timer@30Hz"

      Allegro.flipDisplay

  -- ── Cleanup ──
  queue.unregisterSource userSrc
  userSrc.destroy
  font.destroy
  event.destroy
  queue.destroy
  timer.destroy
  if touchOk != 0 then Allegro.uninstallTouchInput
  if joyOk != 0 then Allegro.uninstallJoystick
  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownFontAddon
  Allegro.uninstallSystem
