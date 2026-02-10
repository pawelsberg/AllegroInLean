-- Joystick explorer demo.
--
-- Installs the joystick subsystem and displays connected joystick
-- information. When a joystick is present, shows live axis positions
-- as crosshairs and button states as coloured indicators.
--
-- Press Escape or close the window to quit.
--
-- Showcases: Joystick subsystem, joystick enumeration, joystick
--   properties, joystick state polling, joystick event handling,
--   reconfiguration events.
import Allegro

open Allegro

/-- Clamp a Float into [lo, hi]. -/
def clampF (lo hi x : Float) : Float :=
  if x < lo then lo else if x > hi then hi else x

def main : IO Unit := do
  -- ── Initialisation ──
  let okInit ← Allegro.init
  if okInit == 0 then IO.eprintln "al_init failed"; return

  let _ ← Allegro.installKeyboard
  let _ ← Allegro.initPrimitivesAddon
  Allegro.initFontAddon

  let okJoy ← Allegro.installJoystick
  if okJoy == 0 then
    IO.eprintln "warning: joystick driver not available"

  let _ ← Allegro.createDisplay 720 480
  let display : Display ← Allegro.getCurrentDisplay
  display.setTitle "AllegroInLean – Joystick Demo"

  let timer ← Allegro.createTimer (1.0 / 30.0)
  let queue ← Allegro.createEventQueue
  queue.registerSource (← display.eventSource)
  queue.registerSource (← Allegro.getKeyboardEventSource)
  queue.registerSource (← timer.eventSource)

  -- Register joystick event source (if driver active)
  let joyInstalled ← Allegro.isJoystickInstalled
  if joyInstalled != 0 then
    queue.registerSource (← Allegro.getJoystickEventSource)

  timer.start

  -- Event type constants
  let evDisplayClose := Allegro.eventTypeDisplayClose
  let evKeyDown := Allegro.eventTypeKeyDown
  let evTimer := Allegro.eventTypeTimer
  let evJoyAxis := Allegro.eventTypeJoystickAxis
  let evJoyBtnDown := Allegro.eventTypeJoystickButtonDown
  let evJoyBtnUp := Allegro.eventTypeJoystickButtonUp
  let evJoyConfig := Allegro.eventTypeJoystickConfiguration
  let kEsc := Allegro.keyEscape

  let event ← Allegro.createEvent
  let font : Font ← Allegro.createBuiltinFont

  -- Mutable state
  let doneRef ← IO.mkRef false
  let statusRef ← IO.mkRef "Waiting for joystick events…"
  let needsRedrawRef ← IO.mkRef true

  -- We'll keep a joystick state snapshot around
  let joyState : JoystickState ← Allegro.createJoystickState

  while true do
    let done ← doneRef.get
    if done then break

    queue.waitFor event
    let evType ← event.type

    if evType == evDisplayClose then
      doneRef.set true

    else if evType == evKeyDown then do
      let key : KeyCode := ⟨← event.keyboardKeycode⟩
      if key == kEsc then doneRef.set true

    else if evType == evJoyConfig then do
      -- A joystick was added or removed – reconfigure
      let _ ← Allegro.reconfigureJoysticks
      let n ← Allegro.getNumJoysticks
      statusRef.set s!"Joystick configuration changed – {n} joystick(s) connected"
      needsRedrawRef.set true

    else if evType == evJoyAxis then do
      let stick ← event.joystickStick
      let axis ← event.joystickAxis
      let pos ← event.joystickPos
      statusRef.set s!"Axis  stick={stick} axis={axis} pos={pos}"
      needsRedrawRef.set true

    else if evType == evJoyBtnDown then do
      let btn ← event.joystickButton
      statusRef.set s!"Button {btn} DOWN"
      needsRedrawRef.set true

    else if evType == evJoyBtnUp then do
      let btn ← event.joystickButton
      statusRef.set s!"Button {btn} UP"
      needsRedrawRef.set true

    else if evType == evTimer then do
      needsRedrawRef.set true

    -- ── Redraw when the queue is drained ──
    let empty ← queue.isEmpty
    let needsRedraw ← needsRedrawRef.get
    if empty != 0 && needsRedraw then do
      needsRedrawRef.set false
      Allegro.clearToColorRgb 25 30 40

      let numJoys ← Allegro.getNumJoysticks
      if numJoys == 0 then do
        font.drawTextRgb 220 220 220 20.0 20.0 TextAlign.left
          "No joystick detected."
        font.drawTextRgb 160 160 160 20.0 40.0 TextAlign.left
          "Connect a gamepad / joystick and it will appear here."
      else do
        -- Show info for joystick 0
        let joy : Joystick ← Allegro.getJoystick 0
        let active ← joy.isActive
        if active != 0 then do
          let name ← joy.name
          let numSticks ← joy.numSticks
          let numButtons ← joy.numButtons
          font.drawTextRgb 220 220 220 20.0 20.0 TextAlign.left
            s!"Joystick: {name}   sticks={numSticks}  buttons={numButtons}"

          -- Snapshot current state
          joy.getState joyState

          -- Draw each stick as a crosshair box
          let mut boxX : Float := 20.0
          let boxSize : Float := 120.0
          let boxY : Float := 60.0
          for si in List.range numSticks.toNat do
            let stickIdx := UInt32.ofNat si
            let numAxes ← joy.numAxes stickIdx
            let sName ← joy.stickName stickIdx

            -- Draw box outline
            Allegro.drawRectangleRgb boxX boxY (boxX + boxSize) (boxY + boxSize)
              80 80 80 1.0

            -- Label
            font.drawTextRgb 140 140 140 boxX (boxY + boxSize + 4.0) TextAlign.left
              s!"{sName} ({numAxes} axes)"

            -- Read axis values and draw crosshair
            let cx := boxX + boxSize / 2.0
            let cy := boxY + boxSize / 2.0
            let halfBox := boxSize / 2.0 - 4.0

            let axisX ← if numAxes > 0 then
              joyState.axis stickIdx 0
            else pure 0.0
            let axisY ← if numAxes > 1 then
              joyState.axis stickIdx 1
            else pure 0.0

            let dotX := cx + clampF (-1.0) 1.0 axisX * halfBox
            let dotY := cy + clampF (-1.0) 1.0 axisY * halfBox

            -- Centre cross (faint)
            Allegro.drawLineRgb cx (boxY + 2.0) cx (boxY + boxSize - 2.0) 50 50 50 1.0
            Allegro.drawLineRgb (boxX + 2.0) cy (boxX + boxSize - 2.0) cy 50 50 50 1.0

            -- Position dot
            Allegro.drawFilledCircleRgb dotX dotY 6.0 80 220 120

            -- Show raw numbers below stick name
            let axStr := if numAxes > 1 then s!"x={axisX} y={axisY}"
                          else if numAxes > 0 then s!"val={axisX}"
                          else "(no axes)"
            font.drawTextRgb 100 100 100 boxX (boxY + boxSize + 18.0) TextAlign.left axStr

            boxX := boxX + boxSize + 20.0

          -- Draw buttons as coloured squares
          let btnY : Float := boxY + boxSize + 50.0
          font.drawTextRgb 180 180 180 20.0 btnY TextAlign.left "Buttons:"

          let mut bx : Float := 90.0
          for bi in List.range numButtons.toNat do
            let btnIdx := UInt32.ofNat bi
            let pressed ← joyState.button btnIdx
            if pressed != 0 then
              Allegro.drawFilledRectangleRgb bx (btnY - 1.0) (bx + 18.0) (btnY + 13.0)
                80 220 120
            else
              Allegro.drawRectangleRgb bx (btnY - 1.0) (bx + 18.0) (btnY + 13.0)
                60 60 60 1.0
            font.drawTextRgb 200 200 200 (bx + 2.0) btnY TextAlign.left s!"{bi}"
            bx := bx + 24.0

          joy.release
        else
          font.drawTextRgb 220 180 60 20.0 20.0 TextAlign.left "Joystick inactive."

      -- Status line at the bottom
      let status ← statusRef.get
      font.drawTextRgb 160 160 160 20.0 460.0 TextAlign.left status

      Allegro.flipDisplay

  -- ── Cleanup ──
  joyState.destroy
  font.destroy
  event.destroy
  queue.destroy
  timer.destroy
  if joyInstalled != 0 then
    Allegro.uninstallJoystick
  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownFontAddon
  Allegro.uninstallSystem
